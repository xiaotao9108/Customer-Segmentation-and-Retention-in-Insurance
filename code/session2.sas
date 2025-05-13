/*Date Validation for Rate(premium)*/

proc freq data=f.rate;
table business_section cover_type subscription_year driver_training;
run;

proc freq data=f.rate;
table cover_type*client_class/ list out=cov_dri missing;
run;

/*use sql to detect unique values of client record*/
proc sql;
select distinct CLIENT_RECORD, count(*) as cnt
from f.rate
group by client_record;
quit;

proc sql;
select distinct cover_type, count(*) as cnt
from f.rate
group by cover_type;
quit;

proc sql;
select distinct area_type, count(*) as cnt
from f.rate
group by area_type;
quit;

/*print out all invalid value*/
/*1155 obs*/
proc print data=f.rate;
where upcase(substr(POSTAL_CODE, 1, 1)) not in ("K" "L" "M" "N" "P");
run;

data f.rate2;
set f.rate;
if upcase(substr(POSTAL_CODE, 1, 1)) not in ("K" "L" "M" "N" "P") then delete;
run;


/*check outliers*/
/*method1: use proc univariate*/
ods select extremeobs;

proc univariate data=f.rate;
title "CHECK EXTREME VALUES";
id subscription_number vehicle_number;
var coverage_rate;
run;

/*negative premium can be premium rebate or refund*/

/*method2: SQL*/
proc sql outobs=5;
select *
from f.rate
order by coverage_rate;
select *
from f.rate
order by descending coverage_rate;
quit;






/**************************************************/
/*Numeric Meausres:             */ 
/*check if number is resonable by comparing with historical report*/

/*method1: proc mean*/
proc means data=f.rate2 missing n nmiss nway noprint;
class business_section subscription_year cover_type;
var coverage_rate;
output out=f.sum_rate_yr_covty sum=sum_premium mean=avg_premium;
run;

/*method2: proc summary*/
proc summary data=f.rate2 nway;
class business_section subscription_year cover_type;
var coverage_rate;
output out=sum_rate_summary sum=sum_premium mean=avg_premium;
run;

/*method3: SQL*/
proc sql;
select business_section, subscription_year, cover_type,
sum(coverage_rate) as sum_premium,
avg(coverage_rate) as avg_premium
from f.rate2
group by business_section, subscription_year, cover_type;
quit;

/*method4: data step*/
proc sort data= f.rate2;
by business_section subscription_year cover_type;
run;

data sum_rate_d_step (keep = business_section subscription_year cover_type sum_premium avg_premium);
set f.rate2;
by business_section subscription_year cover_type;
if first.cover_type then do;
sum_premium = 0;
count = 0;
avg_premium = 0;
end;
sum_premium + coverage_rate;
count+1;
if last.cover_type then do;
avg_premium = sum_premium/count;
output;
end;
run;

/*count policy over years*/
proc sql;
create table f.count_policy_year as
select subscription_year, count(distinct SUBSCRIPTION_NUMBER)
from f.rate2
group by subscription_year;
quit;


/***********total of TERM UNIT********************************/
data f.term_unit;
set f.rate2;
term_unit = round(intck("day", input(EFFECTIVE_DATE,yymmdd8.), input(EXPIRY_DATE,yymmdd8.))/365.25, .1);
run;

proc sql;
select distinct term_unit
from f.term_unit;
quit;

/*total exposure*/
/*under policy level*/
proc sql noprint;
create table f.expo as
select sum(term_unit) as expo
from (select distinct subscription_number, effective_date,expiry_date,term_unit from f.term_unit);
run; 

/*under vehicle level*/
proc sql;
create table f.veh_expo as
select sum(term_unit) as veh_expo
from (select distinct subscription_number, vehicle_number, effective_date, expiry_date, term_unit from f.term_unit);
quit;


data uniq_term1 (keep=byvar term_unit);
set f.term_unit;
byvar=business_section||subscription_year||subscription_number||vehicle_number;
run;

proc sort data=uniq_term1;
by byvar;
run;

data uniq_term1;
set uniq_term1;
by byvar;
if first.byvar then output;
run;



 /***********NUMERIC VALUES SUMMARY ***********/
proc sql;
create table f.sum_rate_policy_veh_date as
select SUBSCRIPTION_NUMBER, VEHICLE_NUMBER, EFFECTIVE_DATE,
EXPIRY_DATE,SUM(COVERAGE_RATE) AS COVERAGE_RATE
from f.rate2
group by 1,2,3,4;
quit;


/*net income*/


proc sort data=f.rate_earned nodup;
by subscription_number VEHICLE_NUMBER EFFECTIVE_DATE;
run;

proc sql;
create table f.net_income as
select substr(TRANSACTION_DATE,1,4) as year, sum(earned_rate) as total_income
from f.rate_earned
group by year
having year in ("1995" "1996" "1997");
quit;


/*Loss ratio*/
data f.claim2;
set f.claim;
subscription_number = '98076'||substr(Subscriber_number,5);
run;

proc sql;
create table f. loss_by_year as
select substr(effective_date,1,4) as year, sum(losspayment) as loss
from f.claim2
group by year;
quit;

proc sql;
create table f.loss_ratio as
select a.*, b.loss, round(b.loss/a.total_income,.2) as loss_ratio
from f.net_income a left join f.loss_by_year b
on a.year = b.year;
quit;





/*for analysis in terms of age*/


proc sql;
select max(input(CLIENT_DATE_OF_BIRTH,3.)), min(input(CLIENT_DATE_OF_BIRTH, 3.))
from f.rate2;
quit;

proc sql;
select distinct vehicle_number, VEHICLE_MODEL_YEAR
from f.rate2;
quit;


data f.rate_age;
set f.rate2;
if input(CLIENT_DATE_OF_BIRTH,3.)< 35 then delete; /*remove those with age > 90*/

client_age = SUBSCRIPTION_year - input(('19'||COMPRESS(CLIENT_DATE_OF_BIRTH)),4.);
length  age_range $ 20;
if client_age lt 26 then age_range='25 and less';
else if  client_age lt 35 then age_range='26-34';
else if  client_age lt 45 then age_range='35-44';
else if  client_age lt 55 then age_range='45-54';
else if  client_age lt 65 then age_range='55-64';
else if  client_age lt 75 then age_range='less than 75';
else age_range='75 and older';

/*veh age*/
IF  VEHICLE_MODEL_YEAR IN (-2,-3) THEN  DELETE;
car_age = SUBSCRIPTION_YEAR - input(('19'||put(VEHICLE_MODEL_YEAR,2.)),4.);
if VEHICLE_NUMBER='*' then delete ;
run;


proc sql;
select distinct car_age, count(*) as cnt
from f.rate_age
group by car_age;
quit;

data f.rate_car_age;
set f.rate_age;
length  car_age_range $ 20;
if car_age lt 10 then car_age_range='< 10';
else if  car_age lt 20 then car_age_range='10-19';
else if  car_age lt 30 then car_age_range='20-29';
else if  car_age lt 40 then car_age_range='30-39';
else if  car_age lt 50 then car_age_range='40-49';
else car_age_range='50 and older';
run;




/*discount combo*/
proc sql;
create table f.disc1 as 
select subscription_number, vehicle_number, subscription_year, effective_date /*to define term*/,
max(discount1) as DISC1,
max(discount2) as DISC2,
max(discount3) as DISC3,
max(discount4) as DISC4
from f.rate2
group by subscription_number, vehicle_number, subscription_year, effective_date;
quit;

data f.disc2 (drop = i disc1-disc4);
length disc $4;
set f.disc1;
array discs(*) $ disc1-disc4;
do i=1 to 4;
if not missing(discs(i)) then do;
disc = discs(i);
output;
end;
end;
run;


/*remove duplicated records*/
/*unique comb under SUBSCRIPTION_NUMBER VEHICLE_NUMBER SUBSCRIPTION_YEAR EFFECTIVE_DATE*/

proc sort data=f.disc2 out=f.disc2_2 noduprecs;
by subscription_number vehicle_number subscription_year effective_date disc;
run;

proc transpose data=f.disc2_2 out=f.disc3;
var disc;
by subscription_number vehicle_number subscription_year effective_date;
run;


/*method1*/
data f.disc_f;
set f.disc3;
disc = catx(" ", col1, col2, col3, col4); /*needs to be named explicitly*/
drop _name_ col1-col4; 
run;

/*method2*/
data f.disc_f;
set f.disc3;
array col(*) col1-col4;
disc = catx(" ", of col[*]);
drop _name_ col1-col4; 
run;

/*method3*/
data f.disc_f;
set f.disc3;
disc = catx(" ", of col1-col4);
drop _name_ col1-col4; 
run;

/*method4*/
data f.disc_f;
set f.disc3;
DISC_COMB=COL1||" "||COL2||" "||COL3||" "||COL4;
drop _name_ col1-col4; 
run;


