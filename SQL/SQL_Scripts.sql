//Create cbp table for county business pattern data
create table cbp(
state smallint, 
county smallint, 
naics char(6),
empflag char(1),
empnf char(1),
emp int,
qp1_nf char(1),
qp1 int,
ap_nf char(1),
ap int,
est int,
n1_4 int,
n5_9 int,
n10_9 int,
n20_49 int,
n50_99 int,
n100_249 int,
n250_499 int,
n500_999 int,
n1000 int,
n1000_1 int,
n1000_2 int,
n1000_3 int,
n1000_4 int,
censtate int,
cencty int);

//create cfs12 table for CFS areas data
create table cfs12(
state smallint, 
county smallint, 
cfsid char(19),
cfsname varchar(100)
)

//Create sctgnaics table for SCTG NAICS mapping data
create table sctgnaics(
sctg char(2),
context varchar(50),
naics char(4));

//Create faf16 table for FAF 2016 data
create table faf16(
orig char(3),
dest char(3),
sctg char(2),
ton real,
value real,
tmile real,
curval real, 
wgtdist real);

//Aggregate value, weight, and mile by state in faf16 tables
//Then replace sctg with naics based on the mapping defined in sctgnaics table
//store the results in faf16s table
with faf16s as (select substring(orig,1,2) as state, sctg, sum(ton) as weight, sum(value) as value, sum(tmile) as miles from faf16 group by 1,2)
select state, naics, sum(weight) as weight, sum(value) as value, sum(miles) as miles into faf16s from faf16s inner join sctgnaics on faf16s.sctg = sctgnaics.sctg group by state, naics;

//Remove total rows from cbp data (naics codes with - or /)
//Aggregate NAICS code according to the 2017 CFS sample design spec(Table 1 - Pages 7 and 8)
with cbps as (select state, county, naics, ap, est from cbp where naics not similar to '%(-|/)%'), 
cbpt as ((select state, county, substring(naics,1,4) as naics, sum(ap) as ap, sum(est) as est from cbps where substring(naics,1,4) in ('2121','2122','2123','4231','4232','4233','4234','4235','4236','4237','4238',
'4239','4241','4242','4243','4244','4245','4246','4247','4248','4249','4541','4543','5111') group by 1,2,3) union all (select state, county, substring(naics,1,3) as naics, sum(ap) as ap, sum(est) as est from cbps where substring(naics,1,3) in ('311','312','313','314','315','316','321','322','323','324','325','326','327','331',
'332','333','334','335','336','337','339') group by 1,2,3));

//Create fafbp table with weight, value, miles, and total number of establishments per state/NAICS 
with sbp as (select state, naics, sum(ap) as ap, sum(est) as est from cbpf group by 1,2)
select sbp.state, sbp.naics, weight, value, miles, ap, est into fafbp from faf16s inner join sbp on faf16s.naics = sbp.naics and faf16s.state::smallint = sbp.state;  

//Estimate weight, value, and miles for each county and storing the results in fafcbp table
select cbpf.state, cbpf.county, cfs12.cfsid, cbpf.naics, (cbpf.est*fafbp.weight)/fafbp.est as weight, (cbpf.est*fafbp.value)/fafbp.est as value, 
(cbpf.est*fafbp.miles)/fafbp.est as miles, cbpf.ap as ap, cbpf.est as est into fafcbp from cbpf 
inner join fafbp on cbpf.state = fafbp.state and fafbp.naics = cbpf.naics inner join cfs12 on cbpf.state = cfs12.state and cbpf.county = cfs12.county;