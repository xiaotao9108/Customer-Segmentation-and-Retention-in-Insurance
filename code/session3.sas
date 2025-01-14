/*analysis for discount combo*/
/***MERGE THE LOSS WITH THE DISC COMBINATION***/

proc sql;
create table f.disc_loss as
select a.*, b. disc_comb
from f.claim2 a left join f.disc_f b
on a.subscription_number = b.subscription_number and
a.vehicle_number = b.vehicle_number and 
a.effective_date = b.effective_date;
quit;

proc sql;
create table f.disc_earn as
select a.*, b.disc_comb
from f.rate_earned a left join f.disc_f b
on a.subscription_number = b.subscription_number and
a.vehicle_number = b.vehicle_number and 
a.effective_date = b.effective_date;
quit;

proc sql;
create table f.disc_loss2 as
select disc_comb, sum(losspayment) as loss
from f.disc_loss 
group by disc_comb
having not missing(disc_comb) ;
quit;

proc sql;
create table f.disc_earn2 as
select disc_comb, sum(earned_rate) as earned
from f.disc_earn 
group by disc_comb
having not missing(disc_comb) ;
quit;

proc sql;
create table f.disc_earn_loss as
select coalesce(a.disc_comb, b.disc_comb) as disc_comb,
       a.*, 
       b.*
from f.disc_earn2 as a
full join f.disc_loss2 as b
on a.disc_comb = b.disc_comb;
quit;

data f.disc_earn_loss_long;
   set f.disc_earn_loss;
   Category = "Earned"; Value = earned; output;
   Category = "Loss"; Value = loss; output;
   keep disc_comb Category Value;
run;


/*analysis for Age*/


PROC SQL;
CREATE TABLE f.UNIQ_AGE_RANGE AS 
SELECT DISTINCT subscription_number,VEHICLE_NUMBER,EFFECTIVE_DATE,
MAX(age_range)  AS age_range, 
FROM f.rate_age
GROUP BY subscription_number,VEHICLE_NUMBER,EFFECTIVE_DATE;
QUIT ;



proc sql;
create table f.rate_e as
select A.subscription_number,A.VEHICLE_NUMBER,A.EFFECTIVE_DATE,
B.age_range,SUM(EARNED_RATE) AS E_RATE  
FROM f.RATE_EARNED AS A LEFT JOIN f.UNIQ_AGE_RANGE AS B 
ON A.subscription_number=B.subscription_number AND 
   A.VEHICLE_NUMBER=B.VEHICLE_NUMBER AND 
   A.EFFECTIVE_DATE=B.EFFECTIVE_DATE 
GROUP BY A.subscription_number,A.VEHICLE_NUMBER,A.EFFECTIVE_DATE,B.age_range;
QUIT ; 




data f.rate_with_loss_driver;
length losspayment 3;
if _n_=1 then do;
if 0 then;
Declare Hash MyLkup(HashExp:8,Dataset:'f.claim2'); /*hashexp: define hash size store dataset, ????,????,???memory??,??8?16???*/
MyLkup.DefineKey('SUBSCRIPTION_NUMBER','VEHICLE_NUMBER','EFFECTIVE_DATE');
MyLkup.DefineData('LOSSPAYMENT');/*??loss payment?earned table,???character variable????????length*/
MyLkup.DefineDone();
End;
call missing(LOSSPAYMENT); /*assign missing value to PDV*/
Set f.rate_e ; /*master data*/
Rc = MyLkup.Find(); /*function; MATCH and return value to check if value in Claim and Rate_E is matched*/
run; 



PROC SQL;
CREATE TABLE f.RATE_LOSS_BY_AGE AS 
SELECT age_range,SUM(E_RATE) AS E_RATE,
        SUM(LOSSPAYMENT) AS LOSSPAYMENT,
       SUM(LOSSPAYMENT)/SUM(E_RATE) FORMAT=PERCENT7.2 AS RATIO 
FROM f.rate_with_loss_driver
GROUP BY age_range;
QUIT ;




/*to car age*/

PROC SQL;
CREATE TABLE f.UNIQ_car_AGE_RANGE AS 
SELECT DISTINCT subscription_number,VEHICLE_NUMBER,EFFECTIVE_DATE,
MAX(car_age_range)  AS car_age_range 
FROM f.rate_car_age
GROUP BY subscription_number,VEHICLE_NUMBER,EFFECTIVE_DATE;
QUIT ;



proc sql;
create table f.car_rate_e as
select A.subscription_number,A.VEHICLE_NUMBER,A.EFFECTIVE_DATE,
B.car_age_range,SUM(EARNED_RATE) AS E_RATE  
FROM f.RATE_EARNED AS A LEFT JOIN f.UNIQ_car_AGE_RANGE AS B 
ON A.subscription_number=B.subscription_number AND 
   A.VEHICLE_NUMBER=B.VEHICLE_NUMBER AND 
   A.EFFECTIVE_DATE=B.EFFECTIVE_DATE 
GROUP BY A.subscription_number,A.VEHICLE_NUMBER,A.EFFECTIVE_DATE,B.car_age_range;
QUIT ; 




data f.rate_with_loss_car;
length losspayment 3;
if _n_=1 then do;
if 0 then;
Declare Hash MyLkup(HashExp:8,Dataset:'f.claim2'); /*hashexp: define hash size store dataset, ????,????,???memory??,??8?16???*/
MyLkup.DefineKey('SUBSCRIPTION_NUMBER','VEHICLE_NUMBER','EFFECTIVE_DATE');
MyLkup.DefineData('LOSSPAYMENT');/*??loss payment?earned table,???character variable????????length*/
MyLkup.DefineDone();
End;
call missing(LOSSPAYMENT); /*assign missing value to PDV*/
Set f.car_rate_e ; /*master data*/
Rc = MyLkup.Find(); /*function; MATCH and return value to check if value in Claim and Rate_E is matched*/
run; 



PROC SQL;
CREATE TABLE f.RATE_LOSS_BY_CAR_AGE AS 
SELECT car_age_range,SUM(E_RATE) AS E_RATE,
        SUM(LOSSPAYMENT) AS LOSSPAYMENT,
       SUM(LOSSPAYMENT)/SUM(E_RATE) FORMAT=PERCENT7.2 AS RATIO 
FROM f.rate_with_loss_car
GROUP BY car_age_range;
QUIT ;







/*area/Geo analysis*/
data f.rate_geo;
set f.rate2;
fsa=substr(postal_code,1,3);
run;


proc sql;
create table f.rate_geo_earn as
select A.subscription_number,A.VEHICLE_NUMBER,A.EFFECTIVE_DATE,
B.fsa,SUM(EARNED_RATE) AS E_RATE  
FROM f.RATE_EARNED AS A LEFT JOIN f.rate_geo AS B 
ON A.subscription_number=B.subscription_number AND 
   A.VEHICLE_NUMBER=B.VEHICLE_NUMBER AND 
   A.EFFECTIVE_DATE=B.EFFECTIVE_DATE 
GROUP BY A.subscription_number,A.VEHICLE_NUMBER,A.EFFECTIVE_DATE,B.fsa;
QUIT ; 


proc sort data=f.claim2;
by subscription_number VEHICLE_NUMBER EFFECTIVE_DATE;
run;


proc sort data=f.rate_geo_earn;
by subscription_number VEHICLE_NUMBER EFFECTIVE_DATE;
run;


data f.rate_with_loss_geo;
merge f.rate_geo_earn(in=a) f.claim2(in=b);
by subscription_number VEHICLE_NUMBER EFFECTIVE_DATE;
if a;
run;


PROC SQL;
CREATE TABLE f.RATE_LOSS_ratio_geo AS 
SELECT fsa,SUM(E_RATE) AS E_RATE,
        SUM(LOSSPAYMENT) AS LOSSPAYMENT,
       SUM(LOSSPAYMENT)/SUM(E_RATE) FORMAT=PERCENT7.2 AS RATIO 
FROM f.rate_with_loss_geo
GROUP BY fsa;
QUIT ;






/*terminated policy number and rate in 1996*/
proc sql;
create table f.terminate_sum as 
select substr(transaction_date,1,6) as yrmon,
		sum(coverage_rate)*(-1) as sum_rate,
		count(distinct subscription_number) as terminate_account
from f.rate2
where transaction_type = "TERMINATED" and
		substr(transaction_date,1,4) = "1996"
group by yrmon;
quit;







/*Churn rate analysis*/
data f.crdt;
set f.credit_r;
subscription_number = '98076'||subscriber_number;
run;


data f.rate_credit;
length credit 3;
if _N_=1 then do;
if 0 then;
Declare Hash MyLkup(HashExp:8,Dataset:'f.crdt');
MyLkup.DefineKey("subscription_number");
MyLKUP.DefineData("credit");
MyLkup.DefineDone();
call missing(credit);
End;
set f.rate2;
Rc = MyLkup.Find();
run;


data f.rate_credit2;
set f.rate_credit;
length credit_group $15;
where credit ne .;
if credit le 580 then credit_group = "0-580";
else if credit le 650 then credit_group = "581-650";
else credit_group = "651 and above";
yr_mon = put(input(transaction_date,yymmdd8.),monyy7.);
run;

proc sql;
create table f.rate_credit3 as
select distinct yr_mon, transaction_type, credit_group,
count(distinct subscription_number) as account_count
from f.rate_credit2
where substr(transaction_date,1,4) = "1996"
group by yr_mon, transaction_type, credit_group;
quit;

proc sort data = f.rate_credit3 out = f.rate_credit3_v2;
by yr_mon credit_group transaction_type ;
run;

proc transpose data = f.rate_credit3_v2 out = f.rate_credit3_v3;
by yr_mon credit_group;
id transaction_type;
var account_count;
run;

data f.account_churn;
set f.rate_credit3_v3;
churn_rate = round(terminated/active, 0.01);
format churn_rate percent7.2;
label churn_rate = "Churn Rate";
run;
