sudo -uflightbigdata /home/q/big_hive/apache-hive-1.0.0-bin/bin/hive -e "
set mapred.reduce.tasks = 500;
set mapred.reduce.slowstart.completed.maps=0.9;
set hive.cli.print.header=true;
set hive.resultset.use.unique.column.names=false;
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
">/home/q/ys.yan/top500_airroute_data.csv



sudo mc cp /home/q/ys.yan/bs_ctrip_20180514.csv data_analyse/testcode/ys.yan/Complaint_User_Analysis/datasets


