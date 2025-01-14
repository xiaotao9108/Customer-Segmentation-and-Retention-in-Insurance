libname f "C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\repractice 20241225\file";

/*read files with filename*/


/*read RI(credit ordering) files*/
%let path = C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\RI;

filename ri ("&path\RI_1.txt"
			"&path\RI_2.txt"
			"&path\RI_3.txt"
			"&path\RI_4.txt");

%put &path;

data f.ri;
infile ri truncover;
INPUT  
    subscriber_number   $  1-10
       province $ 11-12
	  PCOD $ 13-18
	 CITY_name $  19-33
	 ADDRESS $  34-63
	 FIRST_NAME $  64-93
	 LAST_NAME $  94-123
	 CLIENT_ID  $ 124-125
	 client_Birhdate 126-130;
run;




/*******************************/
/*Data validation*/
/******************************/

proc sort data=f.ri nodup;
by subscriber_number;
run; 


proc freq data=f.ri;
table province;
run;


/*with SQL*/
proc sql;
select province, count(*) as cnt
from f.ri
group by province;
quit;

/*with data step*/
proc sort data=f.ri;
by province;
run;

data _null_;
set f.ri;
by province;
if first.province then cnt = 0;
cnt+1;
if last.province then do;
put province;
put cnt;
end;
run;


/*data manipulation*/
data f.ri2;
set f.ri (rename = (pcod = postcode)
			where = (not missing(subscriber_number)));
business_section = "AIO";
FSA = substr(postcode, 1, 3);
cli_id = input(client_id,2.);
bdate = put(client_Birhdate, monyy7.);
if substr(FIRST_NAME,1,1) in ("1", "2", "3", "4", "5", "6", "7", "8", "9", "0") then delete;

/*only keep part before &/AND if have any &/AND*/
p1 = find(first_name, "&");
p2 = find(upcase(first_name), "AND");

if p1=0 and p2>0  then p=p2;
else if p1>0 and p2=0 then p=p1;
else if p1>0 and p2>0 then p=min(p1,p2);
else p=0;

if p=0 then fname = first_name;
else if upcase(first_name)=:"AND" and p1=0 then fname=first_name;
else fname = substr(first_name, 1, p-1);

midname = "   ";
spous_name = "   ";
addr = "    ";
run;

/*keep main driver for every policy number*/
proc sort data=f.ri2 out=f.ri3;
by business_section subscriber_number descending cli_id;
run;

data f.ri_f;
set f.ri3;
by business_section subscriber_number descending cli_id;
if first.subscriber_number;
run;


/*credit order file built*/
data f._null_;
set f.ri_f end=eof;
file "C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\repractice 20241225\file\crdt_re.txt";
IF _N_ =1 THEN 
PUT 'THIS IS THE HEADER OF THE TEXT FILE';
put @1  business_section /*assign a value, each policy number belongs to which sub-company*/
    @4 subscription_number 
	@8 last_name
	@33 first_name
	@48 midname
	@59 spous_name
	@70 SIN
	@79 bdate
	@85 addr
	@126 province;
if eof then put "THIS IS THE FOOTER OF THE TEXT FILE";
run;



/*import geo file*/
data f.geo;
infile "C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\area_infor.txt" dlm=";" missover;
input pcd : $6. 
      DIVISTION_name:  $2. 
      DIVISION_number: 8.2 
;
run ;




/*read premium data*/
filename rate 
("C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\Rate\RATE_95.txt"
"C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\Rate\RATE_96.txt"
"C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\Rate\RATE_97.txt");

data f.rate;
infile rate dsd missover;
input BUSINESS_SECTION : $CHAR3.
VEHICLE_NUMBER :  $CHAR3.
EFFECTIVE_DATE : $CHAR8.
EXPIRY_DATE: $CHAR8. 
TRANSACTION_DATE: $CHAR8.
VEHICLE_MODEL_YEAR: 5.0 
CLIENT_CLASS : $CHAR1. 
CLIENT_RECORD : 3.0
CLIENT_DATE_OF_BIRTH : $CHAR2.
DRIVER_TRAINING : $CHAR1. 
LICENSE_DATE : 4.0 
TRANSACTION_TYPE:  $CHAR20. 
SUBSCRIPTION_YEAR : 4.0
AREA_TYPE : $CHAR8. 
DISCOUNT1 : $CHAR4. 
DISCOUNT2 : $CHAR4. 
DISCOUNT3 : $CHAR4. 
DISCOUNT4 : $CHAR4. 
CONVCTION : $CHAR2.
COVER_TYPE : $CHAR4.
COVERAGE_RATE : 8.2
POSTAL_CODE : $CHAR6. 
LEASE_BUY : $CHAR2.
SUBSCRIPTION_NUMBER : $CHAR14.
CARNUM: $char10.
manu_yr: $char4.
;
run;

/*method2: using wildcard*/

filename rate "C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\Rate\*.txt";

data f.rate;
infile rate dsd missover;
input BUSINESS_SECTION : $CHAR3.
VEHICLE_NUMBER :  $CHAR3.
EFFECTIVE_DATE : $CHAR8.
EXPIRY_DATE: $CHAR8. 
TRANSACTION_DATE: $CHAR8.
VEHICLE_MODEL_YEAR: 5.0 
CLIENT_CLASS : $CHAR1. 
CLIENT_RECORD : 3.0
CLIENT_DATE_OF_BIRTH : $CHAR2.
DRIVER_TRAINING : $CHAR1. 
LICENSE_DATE : 4.0 
TRANSACTION_TYPE:  $CHAR20. 
SUBSCRIPTION_YEAR : 4.0
AREA_TYPE : $CHAR8. 
DISCOUNT1 : $CHAR4. 
DISCOUNT2 : $CHAR4. 
DISCOUNT3 : $CHAR4. 
DISCOUNT4 : $CHAR4. 
CONVCTION : $CHAR2.
COVER_TYPE : $CHAR4.
COVERAGE_RATE : 8.2
POSTAL_CODE : $CHAR6. 
LEASE_BUY : $CHAR2.
SUBSCRIPTION_NUMBER : $CHAR14.
CARNUM: $char10.
manu_yr: $char4.
;
run;


/*method3: using macro*/
%macro read_file (input, output);
data f.&output;
infile &input dsd missover;
input BUSINESS_SECTION : $CHAR3.
VEHICLE_NUMBER :  $CHAR3.
EFFECTIVE_DATE : $CHAR8.
EXPIRY_DATE: $CHAR8. 
TRANSACTION_DATE: $CHAR8.
VEHICLE_MODEL_YEAR: 5.0 
CLIENT_CLASS : $CHAR1. 
CLIENT_RECORD : 3.0
CLIENT_DATE_OF_BIRTH : $CHAR2.
DRIVER_TRAINING : $CHAR1. 
LICENSE_DATE : 4.0 
TRANSACTION_TYPE:  $CHAR20. 
SUBSCRIPTION_YEAR : 4.0
AREA_TYPE : $CHAR8. 
DISCOUNT1 : $CHAR4. 
DISCOUNT2 : $CHAR4. 
DISCOUNT3 : $CHAR4. 
DISCOUNT4 : $CHAR4. 
CONVCTION : $CHAR2.
COVER_TYPE : $CHAR4.
COVERAGE_RATE : 8.2
POSTAL_CODE : $CHAR6. 
LEASE_BUY : $CHAR2.
SUBSCRIPTION_NUMBER : $CHAR14.
CARNUM: $char10.
manu_yr: $char4.
;
run;

proc append data=f.&output out=f.all force;
run;
%mend;

%read_file("C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\Rate\RATE_95.txt",rate95);
%read_file("C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\Rate\RATE_96.txt",rate96);
%read_file("C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\Rate\RATE_97.txt",rate97);




/*read credit return file*/
data f.credit_r;
infile "C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\crdt_r.txt" LRECL=2000;
input @1     credit 6.2
      @21     subscriber_number  $8.;
run;



/*read claim data*/
/*change data structure in ACCESS first to reduce capacity taken */
proc import table="claim_s" out=f.claim dbms=access replace;
database="C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\car description and loss data.mdb";
run;

/*read auto file*/
proc import table="auto_s" out=f.auto dbms=access replace;
database="C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\car description and loss data.mdb";
run;


/**************finish importing files**************/
