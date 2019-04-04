/*generate_est is a function written in procedural PostgreSQL that generates certain number of establishments and distributes them in state, county, NAICS categories based on fafcbp table. fafcbp is the combination of FAF and CBP datasets. */
/*Usage:
generate_est(Sample_size, Source_table, Value_CV, Wgt_CV, Mile_CV)
Example: 
SELECT * FROM generate_est(100000, 'fafcbp', 0.1, 0.1, 0.1);
*/

drop function if exists generate_est(integer,text,numeric,numeric,numeric);
drop type if exists returntype;

create type returntype as(
estno int,
state smallint,
county smallint,
naics char(4),
value real,
weight real,
miles real);

CREATE OR REPLACE FUNCTION generate_est(_psize int = 1000, _source text = 'fafcbp', _ValCV numeric = 0.1 , _WgtCV numeric= 0.1, _MilCV numeric = 0.1)
  RETURNS SETOF returntype AS
$func$
DECLARE
	r returntype%rowtype;
	_rec record;
	_est_counter int:=1;
	_est_index int:=1;
	_est_county int:=0;
	_total_est int:=0;	
	
BEGIN
	EXECUTE 'SELECT SUM(est) FROM '||$2 INTO _total_est;	
	FOR _rec IN EXECUTE 'select * from ' || $2 ||' ORDER BY 1,2,3' LOOP
		_est_county = round((_rec.est*_psize*1.0)/_total_est);
		IF _est_county >=1 THEN
			FOR _est_index IN 1.._est_county LOOP
				r.estno = _est_counter;
				r.state = _rec.state;
				r.county = _rec.county;
				r.naics = _rec.naics;
				r.value = abs(normal_rand(1,_rec.value, _rec.value*_ValCV));
				r.weight  = abs(normal_rand(1,_rec.weight, _rec.weight*_WgtCV));
				r.miles = abs(normal_rand(1,_rec.miles, _rec.miles*_MilCV));
				_est_counter = _est_counter+1;
				RETURN next r;
			END LOOP;
		END IF;			
	END LOOP;		
	RETURN;
END
$func$  
LANGUAGE plpgsql;
