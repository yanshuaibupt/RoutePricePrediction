select 
dep_city as dep_city
,arr_city as arr_city
,dep_date as dep_date
,search_date as search_date
,minprice as minprice
from 
(select 
dep_city as dep_city
,arr_city as arr_city
,dep_date as dep_date
,search_date as search_date
,min(minprice) as minprice
from f_analysis.flight_price_20180514 
group by dep_city,arr_city,search_date,dep_date ) a
join 
(select 
dep_city as dep_city_b
,arr_city as arr_city_b
,sum(total_order_num) as total_order_num
from f_analysis.flight_price_20180514 
where dep_date >='2018-04-01' and dep_date <= '2018-04-30' 
group by dep_city,arr_city
order by total_order_num DESC
limit 500) b
on a.dep_city = b.dep_city_b and a.arr_city = b.arr_city_b
