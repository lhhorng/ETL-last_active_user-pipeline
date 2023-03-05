---- What we have: date 2017-06-28 is the record on user online hours ----
---- Our purpose: to upsert (2017-06-28) to customer_active_hour tbl for the updated time of daily online user ----

CREATE TEMPORARY TABLE IF NOT EXISTS temp_tbl AS (
select
date,
t1.id,
age,
gender,
online_hours

from(
select 
*
from customer_active_hour o 
) t1
LEFT JOIN customer_info o1 ON t1.id = o1.id -- JOIN with customer_active_hour tbl record 
--WHERE o1.date > '2017-06-27' ---- daily record
order by date desc

) 
;

INSERT INTO public.customer_processing
SELECT * FROM temp_tbl 

ON CONFLICT (id) DO UPDATE 
SET
date = EXCLUDED.date 
id = EXCLUDED.id 
gender = EXCLUDED.gender 
age = EXCLUDED.age
number_of_kids = EXCLUDED.number_of_kids 
online_hour = EXCLUDED.online_hours
update_time = EXCLUDED.update_time

;
DROP TABLE temp_table;