/*generate_est is a function written in procedural PostgreSQL that generates certain number of establishments and distributes them in state, county, NAICS categories based on fafcbp table. fafcbp is the combination of FAF and CBP datasets. */
/*Usage:
generate_est(Sample_size, Source_table, Value_CV, Weight_CV, Mile_CV)
Example: 
SELECT * FROM generate_est(100000, 'fafcbp, 0.1, 0.1. 0.1);
*/

drop function if exists generate_est(integer,text,numeric,numeric,numeric);
drop type if exists returntype;

create type returntype as(
state smallint,
county smallint,
cfs12 char(19),
naics char(4),
estno smallint,
value real,
weight real,
miles real);

CREATE OR REPLACE FUNCTION generate_est(_psize int = 1000, _source text = 'fafcbp', _ValCV numeric = 0.1 , _WgtCV numeric= 0.1, _MilCV numeric = 0.1)
  RETURNS SETOF returntype AS
$func$
DECLARE
	r returntype%rowtype;
	_rec record;
	_est_index int:=1;
	_est_county int:=0;
	_total_est int:=0;
	_tbl_size int:=0; 
	
BEGIN
	EXECUTE 'SELECT SUM(est) FROM '||$2 INTO _total_est;
	EXECUTE 'SELECT COUNT(*) FROM '||$2 _tbl_size;
	FOR _rec IN EXECUTE 'select * from ' || $2 ||' ORDER BY cfsid,county,naics' LOOP
		_est_county = round((_rec.est*_psize*1.0)/_total_est);
		IF _est_county >=1 THEN
			FOR _est_index IN 1.._est_county LOOP
				r.estno = _est_index;
				r.state = _rec.state;
				r.county = _rec.county;
				r.cfs12 = _rec.cfsid;
				r.naics = _rec.naics;
				r.value = abs(normal_rand(1,_rec.value, _rec.value*_ValCV));
				r.weight  = abs(normal_rand(1,_rec.weight, _rec.weight*_WgtCV));
				r.miles = abs(normal_rand(1,_rec.miles, _rec.miles*_MilCV));
				RETURN next r;
			END LOOP;
		END IF;			
	END LOOP;		
	RETURN;
END
$func$  
LANGUAGE plpgsql;