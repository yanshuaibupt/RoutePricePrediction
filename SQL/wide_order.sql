select
dep_city as dep_city,
arr_city as arr_city,
dep_date as dep_date,
search_date as search_date,
total_price as total_price
from
(select
dep_city as dep_city,
arr_city as arr_city,
dep_date as dep_date,
search_date as search_date,
min(total_price) as total_price
from
(select
dep_city as dep_city,
arr_city as arr_city,
substr(dep_date,1,10) as dep_date,
substr(create_time,1,10) as search_date,
total_price as total_price
from f_wide.wide_order)
group by dep_city,arr_city,dep_date,search_date)
where dep_city = '三亚' and arr_city = '哈尔滨' and total_price >8000 and search_date = '2018-02-07'
limit 10;
