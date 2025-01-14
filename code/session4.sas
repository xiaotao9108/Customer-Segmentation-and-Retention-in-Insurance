ods pdf file="C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\repractice 20241225\output.pdf";
ods listing gpath = "C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\repractice 20241225\";

/*loss and earn for diffent disc comb*/
ods graphics /imagename="disc_comb" imagefmt=png;
proc sgplot data=f.disc_earn_loss_long;
   vbar disc_comb / response=Value group=Category groupdisplay=cluster datalabel;
   xaxis label="Discount Combination";
   yaxis label="Value (Rate and Loss)";
   title "Earned Premium and Loss by Discount Combination";
run;

/*Rate and ratio by age range*/
ods graphics /imagename="rate_loss_age" imagefmt=png;

proc sgplot data=f.rate_loss_by_age;
   vbar age_range / response= e_rate datalabel;
   vline age_range / response= ratio y2axis;
   xaxis label="Age Range of Driver";
   yaxis label="Earned Premium";
   y2axis label = "Loss Ratio";
   title "Earned Premium and Loss Ratio by Age Group";
run;


/*Rate and ratio by car age range*/
ods graphics /imagename="rate_loss_car_age" imagefmt=png;

proc sgplot data=f.rate_loss_by_car_age;
   vbar car_age_range / response= e_rate datalabel;
   vline car_age_range / response= ratio y2axis;
   xaxis label="Age Range of Car";
   yaxis label="Earned Premium";
   y2axis label = "Loss Ratio";
   title "Earned Premium and Loss Ratio by Car Age Group";
run;



/*Rate and ratio by Area*/
ods graphics /imagename="rate_loss_geo" imagefmt=png;

proc sgplot data=f.rate_loss_ratio_geo;
   vbar fsa / response= e_rate datalabel;
   vline fsa / response= ratio y2axis;
   xaxis label="Forward Sortation Area(FSA)";
   yaxis label="Earned Premium";
   y2axis label = "Loss Ratio";
   title "Earned Premium and Loss Ratio in Different Area";
run;


/*graph for terminate account*/
ods listing close;
ods html path="C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\repractice 20241225\" body = "rate_terminated.html";

axis1 label=("Year and Month");
axis2 label=("Premium");
axis3 label=("Total Terminated Account");

proc gbarline data = f.terminate_sum ;
title h=10pt f=swiss "Profits and Cancelled Counts by Year Month"  ;
bar  yrmon/maxis=axis1 raxis=axis2 sumvar=sum_rate type=sum  cframe=white;
plot /sumvar=terminate_account raxis=axis3 type=sum;
run;
quit;




/*Churn Rate Report*/
ods html path="C:\Users\18144\OneDrive\Desktop\SAS\SAS course\Finance\repractice 20241225\" body = "churn rate.html";

proc report data=f.account_churn nowd split="/";
column yr_mon credit_group active terminated churn_rate;
define yr_mon/"Month" left ;
define credit_group/"Credit Group" center ;
define active/"Active /Account Count" right ;
define terminated/"Cancelled /Account Count" right ;
define churn_rate/"Churn Rate" center format=percent11.2;
title "Churn Rate Report in 1996";
run;
ods html off;

