
drop table if exists tmp.low_price_predict_20180404_1;
create table tmp.low_price_predict_20180404_1
as
select substr(logdata,1,10) as logdata,
dep_date,
dep_city,
arr_city,
flightno,
min(min_price) as min_price,
delta
from
(select
logdata,
dep_date,
dep_city,
arr_city,
split(regexp_replace(regexp_extract(get_json_object(flight,'$.params.goFlightBaseLog'),'\\[(.*)\\]',1),'\\"',''),',') as flightno_s,
get_json_object(flight,'$.params.goFlightBaseLog'),
get_json_object(flight,'$.params.minPrice') as min_price,
datediff(substr(dep_date,1,10),substr(logdata,1,10)) as delta
from(
select
logdata,
get_json_object(hotdog_json,'$.begin') as dep_city,
get_json_object(hotdog_json,'$.end') as arr_city,
get_json_object(hotdog_json,'$.date') as dep_date,
get_json_object(hotdog_json,'$.lowestPrice') as lowestPrice,
udf.json_array(get_json_object(hotdog_json,'$.flights')) as flights
from(
select
  logdata,
  regexp_replace(hotdog_json,'\\\\','') as hotdog_json
from
  f_statis_middle.etl_client_flight
where dt>='2016-08-09' and dt<='2018-04-03' and process='search' and action='QueryFMixwayList'
)A 
where get_json_object(hotdog_json,'$.isInter')=0 and get_json_object(hotdog_json,'$.flights[0]') is not null
)A LATERAL VIEW explode(flights) flights AS flight
)A LATERAL VIEW explode(flightno_s) flightno_s AS flightno
where delta>0 and dep_date!='' and dep_date is not null and dep_city is not null and dep_city!='' and arr_city!='' and  arr_city is not null and flightno is not null and flightno!=''
group by logdata,
dep_date,
dep_city,
arr_city,
flightno,
delta
;

drop table if exists tmp.low_price_predict_20180404_2;
create table tmp.low_price_predict_20180404_2
as
select logdata, 
dep_city,
arr_city,
dep_date,
dt_d,
search_cnt,
dt,
concat_ws('-',cast (cast (substr(dep_date,0,4) as int)+1 as string),substr(dep_date,6,2),substr(dep_date,9,2)) as l_dep_date,
lowestPrice,
sum(search_cnt) over (partition by dep_city,arr_city,dep_date order by dt_d range between 30 preceding and 0 following) - search_cnt as search_cnt_l_30,
sum(search_cnt) over (partition by dep_city,arr_city,dep_date order by dt_d range between 15 preceding and 0 following) - search_cnt as search_cnt_l_15,
sum(search_cnt) over (partition by dep_city,arr_city,dep_date order by dt_d range between 7 preceding and 0 following) - search_cnt as search_cnt_l_7,
sum(search_cnt) over (partition by dt,dep_city) as search_cnt_dep_city,
sum(search_cnt) over (partition by dt,arr_city) as search_cnt_arr_city
from
(select
logdata,
get_json_object(hotdog_json,'$.begin') as dep_city,
get_json_object(hotdog_json,'$.end') as arr_city,
get_json_object(hotdog_json,'$.date') as dep_date,
datediff(concat_ws('-',substr(dt,0,4),substr(dt,6,2),substr(dt,9,2)),'1900-01-01') as dt_d,
dt,
count(1) as search_cnt,
min(get_json_object(hotdog_json,'$.lowestPrice')) as lowestPrice
from(
select
  logdata,
  regexp_replace(hotdog_json,'\\\\','') as hotdog_json,
  dt
from
  f_statis_middle.etl_client_flight
where dt>='2016-08-09' and dt<='2018-04-03' and process='search' and action='QueryFMixwayList'
)A 
where get_json_object(hotdog_json,'$.isInter')=0 and get_json_object(hotdog_json,'$.flights[0]') is not null
group by logdata,
get_json_object(hotdog_json,'$.begin'),
get_json_object(hotdog_json,'$.end'),
get_json_object(hotdog_json,'$.date'),
datediff(concat_ws('-',substr(dt,0,4),substr(dt,6,2),substr(dt,9,2)),'1900-01-01'),
dt
)A;

drop table if exists tmp.low_price_predict_20180404_4;
create table tmp.low_price_predict_20180404_4
as
select logdata, 
dep_city,
arr_city,
dep_date,
dt_d,
booking_count,
dt,
concat_ws('-',cast (cast (substr(dep_date,0,4) as int)+1 as string),substr(dep_date,6,2),substr(dep_date,9,2)) as l_dep_date,
lowestPrice,
sum(booking_count) over(partition by dep_city,arr_city,dep_date order by dt_d range BETWEEN 30 preceding AND 0 following) - booking_count as booking_cnt_l_30,
sum(booking_count) over(partition by dep_city,arr_city,dep_date order by dt_d range BETWEEN 15 preceding AND 0 following) - booking_count as booking_cnt_l_15,
sum(booking_count) over(partition by dep_city,arr_city,dep_date order by dt_d range BETWEEN 7 preceding AND 0 following) - booking_count as booking_cnt_l_7
from
(select
logdata,
get_json_object(hotdog_json,'$.begin') as dep_city,
get_json_object(hotdog_json,'$.end') as arr_city,
get_json_object(hotdog_json,'$.date') as dep_date,
datediff(concat_ws('-',substr(dt,0,4),substr(dt,6,2),substr(dt,9,2)),'1900-01-01') as dt_d,
dt,
count(1) as booking_count,
min(get_json_object(hotdog_json,'$.lowestPrice')) as lowestPrice
from(
select
  logdata,
  regexp_replace(hotdog_json,'\\\\','') as hotdog_json,
  dt
from
  f_statis_middle.etl_client_flight
where dt>='2016-08-09' and dt<='2018-04-03' and process='booking' and action='QueryFMixwayList'
)C 
where get_json_object(hotdog_json,'$.isInter')=0 and get_json_object(hotdog_json,'$.flights[0]') is not null
group by logdata,
get_json_object(hotdog_json,'$.begin'),
get_json_object(hotdog_json,'$.end'),
get_json_object(hotdog_json,'$.date'),
datediff(concat_ws('-',substr(dt,0,4),substr(dt,6,2),substr(dt,9,2)),'1900-01-01'),
dt
)C;


drop table if exists tmp.low_price_predict_20180404_5;
create table tmp.low_price_predict_20180404_5
as
select logdata, 
dep_city,
arr_city,
dep_date,
dt_d,
order_count,
dt,
concat_ws('-',cast (cast (substr(dep_date,0,4) as int)+1 as string),substr(dep_date,6,2),substr(dep_date,9,2)) as l_dep_date,
lowestPrice,
sum(order_count) over(partition by dep_city,arr_city,dep_date order by dt_d range BETWEEN 30 preceding AND 0 following) - order_count as order_cnt_l_30,
sum(order_count) over(partition by dep_city,arr_city,dep_date order by dt_d range BETWEEN 15 preceding AND 0 following) - order_count as order_cnt_l_15,
sum(order_count) over(partition by dep_city,arr_city,dep_date order by dt_d range BETWEEN 7 preceding AND 0 following) - order_count as order_cnt_l_7
from
(select
logdata,
get_json_object(hotdog_json,'$.begin') as dep_city,
get_json_object(hotdog_json,'$.end') as arr_city,
get_json_object(hotdog_json,'$.date') as dep_date,
datediff(concat_ws('-',substr(dt,0,4),substr(dt,6,2),substr(dt,9,2)),'1900-01-01') as dt_d,
dt,
count(1) as order_count,
min(get_json_object(hotdog_json,'$.lowestPrice')) as lowestPrice
from(
select
  logdata,
  regexp_replace(hotdog_json,'\\\\','') as hotdog_json,
  dt
from
  f_statis_middle.etl_client_flight
where dt>='2016-08-09' and dt<='2018-04-03' and process='order' and action='QueryFMixwayList'
)D 
where get_json_object(hotdog_json,'$.isInter')=0 and get_json_object(hotdog_json,'$.flights[0]') is not null
group by logdata,
get_json_object(hotdog_json,'$.begin'),
get_json_object(hotdog_json,'$.end'),
get_json_object(hotdog_json,'$.date'),
datediff(concat_ws('-',substr(dt,0,4),substr(dt,6,2),substr(dt,9,2)),'1900-01-01'),
dt
)D;


drop table if exists tmp.low_price_predict_20180404_6;
create table tmp.low_price_predict_20180404_6
as
select logdata, 
dep_city,
arr_city,
dep_date,
dt_d,
search_cnt,
dt,
l_dep_date,
lowestPrice,
search_cnt_l_30,
search_cnt_l_15,
search_cnt_l_7,
booking_cnt_l_30,
booking_cnt_l_15,
booking_cnt_l_7,
order_cnt_l_30,
order_cnt_l_15,
order_cnt_l_7,
search_cnt_dep_city,
search_cnt_arr_city
from tmp.low_price_predict_20180404_2 b
join 
tmp.low_price_predict_20180404_4 c
on b.dep_city = c.dep_city and b.arr_city = c.arr_city
join
tmp.low_price_predict_20180404_5 d
on b.dep_city = d.dep_city and b.arr_city = d.arr_city


drop table if exists tmp.low_price_predict_20180404_3;
create table tmp.low_price_predict_20180404_3
as
select a.logdata as order_date,
a.dep_date,
a.dep_city,
a.arr_city,
a.delta,
a.dep_flight_no_cnt,
a.dep_carrier_cnt,
b.lowestPrice,
b.search_cnt_l_30,
b.search_cnt_l_15,
b.search_cnt_l_7,
b.booking_cnt_l_30,
b.booking_cnt_l_15,
b.booking_cnt_l_7,
b.order_cnt_l_30,
b.order_cnt_l_15,
b.order_cnt_l_7,
b.search_cnt_dep_city,
b.search_cnt_arr_city,
b.last_min_price
from
(select logdata,
dep_date,
dep_city,
arr_city,
delta,
dep_flight_no_cnt,
dep_carrier_cnt
from
(select logdata,
dep_date,
dep_city,
arr_city,
flightno,
delta,
count(distinct flightno) over(partition by dep_date,dep_city,arr_city) as dep_flight_no_cnt,
count(distinct substr(flightno,0,2)) over(partition by dep_date,dep_city,arr_city) as dep_carrier_cnt,
from tmp.low_price_predict_20180404_1
)a
group by logdata,
dep_date,
dep_city,
arr_city,
delta,
dep_flight_no_cnt,
dep_carrier_cnt
) a
join
(select b.logdata, 
b.dep_city,
b.arr_city,
b.dep_date,
b.dt_d,
b.search_cnt,
b.dt,
b.l_dep_date,
b.lowestPrice,
b.search_cnt_l_30,
b.search_cnt_l_15,
b.search_cnt_l_7,
b.booking_cnt_l_30,
b.booking_cnt_l_15,
b.booking_cnt_l_7,
b.order_cnt_l_30,
b.order_cnt_l_15,
b.order_cnt_l_7,
b.search_cnt_dep_city,
b.search_cnt_arr_city,
c.min_price as last_min_price
from
(select logdata, 
dep_city,
arr_city,
dep_date,
dt_d,
search_cnt,
dt,
l_dep_date,
lowestPrice,
search_cnt_l_30,
search_cnt_l_15,
search_cnt_l_7,
search_cnt_dep_city,
search_cnt_arr_city
from tmp.low_price_predict_20180404_2
) b
left join
(select dep_city,
arr_city,
dep_date,
min(lowestPrice) as min_price,
from tmp.low_price_predict_20180404_2
group by dep_city,
arr_city,
dep_date
)c
on b.dep_city=c.dep_city and b.arr_city=c.arr_city and b.l_dep_date=c.dep_date
) b
on a.logdata=b.logdata and a.dep_city=b.logdata and a.arr_city=b.logdata;