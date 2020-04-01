LIBNAME HW1 'C:\Users\TXA180029\Desktop\HW-1';

PROC IMPORT OUT= HW1.Sales
			DATAFILE="C:\Users\TXA180029\Desktop\HW-1\Sales.csv"
			DBMS=CSV REPLACE;
	GETNAMES=YES;
	DATAROW=2;
RUN;

PROC IMPORT OUT= HW1.Sales_test
			DATAFILE="C:\Users\TXA180029\Desktop\HW-1\Sales_test.csv"
			DBMS=CSV REPLACE;
	GETNAMES=YES;
	DATAROW=2;
RUN;

data sales; 
	set HW1.sales; 
run; 

data sales_test; 
	set HW1.sales_test; 
run; 

/*Generate new variables*/ 
data Sales; 
 set Sales; 
 price_2 = Price**2; 
 ad_2= AdvertisingSpending**2; 
run; 

data Sales_test; 
 set Sales_test; 
 price_2 = Price**2; 
 ad_2= AdvertisingSpending**2; 
run; 

data Sales_test;
 set Sales_test;
 if Design=1 AND Quality=1 then Product_Type =1; 
 if Design=1 AND Quality=2 then Product_Type =2; 
 if Design=2 AND Quality=1 then Product_Type =3; 
 if Design=2 AND Quality=2 then Product_Type =4; 
run;

data sales;
 set sales;
 if Design= 1 AND Quality= 1 then Product_Type=1; 
 run; 

 data sales;
 set sales;
 if Design= 1 AND Quality= 2 then Product_Type=2; 
 run; 

  data sales;
 set sales;
 if Design= 2 AND Quality= 1 then Product_Type=3; 
 run; 

  data sales;
 set sales;
 if Design= 2 AND Quality= 2 then Product_Type=4; 
 run; 
 
proc tabulate data=Sales; 
 class Location Season; 
 table Location*Season; 
 title 'Frequences of Stores By Location & Season'; 
run;

/**** STOP CODE HERE***/ 
/* Hitogram Plot*/ 
proc sgplot data= Sales;
 histogram SalesUnit / binstart = 0 binwidth = 1000 ; 
 density SalesUnit / type = kernel; 
 density SalesUnit /type = normal;
 title 'Distribution of Sales Unit';
run;

proc sgplot data= Sales;
 histogram Price / binstart = 0 binwidth = 10 ; 
 density Price / type = kernel; 
 density Price /type = normal;
 title 'Distribution of Price';
run;

proc sgplot data= Sales;
 histogram AdvertisingSpending / binstart = 0 binwidth = 100; 
 density AdvertisingSpending / type = kernel; 
 density AdvertisingSpending /type = normal;
 title 'Distribution of Advertising Spending';
run;

/*Summary Statistic*/ 
proc means data= Sales n mean stddev min p25 median p75 max maxdec= 2;
var SalesUnit Price AdvertisingSpending;
 title 'General Summary Statistics';
run;

/*Summary Statistics By Season*/ 
proc sort data=Sales;
by Season;
run;

proc means data= Sales; 
var SalesUnit Price AdvertisingSpending;
 title 'Summary Statistics By Season';
 by Season;
run;

/*Anova Hypothesis: 
	Ho: The average of Sales Unit is the same across all 4 seasons 
	H1: At least the average of Sales Unit in 1 season is different from others */ 

proc glm data=Sales; 
class Season; 
model SalesUnit = Season; 
run;


/*Anova Hypothesis: 
	Ho: The average of advertising spending is the same across all 4 seasons 
	H1: At least the average of advertising spending in 1 season is different from others */

proc glm data=Sales; 
class Season; 
model AdvertisingSpending = Season; 
run;

/*Anova Hypothesis: 
	Ho: The average of Price is the same across all 4 seasons 
	H1: At least the average of price in 1 season is different from others */

proc glm data=Sales; 
class Season; 
model Price = Season; 
run;


/*T-test Hypothesis*
	Ho: There is no difference in the avarage of sales unit btw N.A & Europe
	H1: Average of sales unit in N.A is different from Average of sales unit in europe */ 

proc ttest data=Sales; 
class Location; 
 var SalesUnit; 
 title 'T-Test Sales Unit by location'; 
run;

/*T-test Hypothesis*
	Ho: There is no difference in the avarage of price between N.A & Europe 
	H1: Average of price in N.a is different from average of price in Europe */ 
/* Note - strange result for variance hypothesis testing*/ 

proc ttest data=Sales; 
class Location; 
 var Price; 
 title 'T-Test Price by Location'; 
run; 

/*T-test Hypothesis*
	Ho: There is no difference in the advertising spending btw N.A & Europe
	H1: Advertising spending in N.A is different from ad spending in Europe*/ 

proc ttest data=Sales; 
class Location; 
 var AdvertisingSpending; 
 title 'T-Test Price by Ads Spend'; 
run; 

/* Correlation */ 
/* a. Pearson Correlation - Interesting Result Btw: increase in ad -> decresae in Sales Unit */  
proc corr data=Sales; 
 var SalesUnit Price AdvertisingSpending; 
 title 'Pearson Correlation'; 
run;

/* b. Spearman Correlation*- Same interesting result as above*/ 
proc corr data=Sales spearman; 
 var SalesUnit Price AdvertisingSpending; 
 title 'Spearman Correlation'; 
run;

/* Scatterplot - Plot shows non-linear relationship for both Price & Advertising*/ 
proc sgscatter data= Sales;
 matrix SalesUnit price advertisingspending/ diagonal= (histogram);
 title 'Relation between price advertising spend and sales unit';
run;

/* Linear Regression*/ 
proc reg data = Sales; 
 model SalesUnit = Price; 
 title 'Regression of Price on Sales Unit'; 
run;

/* Regression Model with Price^2*/ 
proc reg data = Sales; 
 model SalesUnit = Price price_2; 
 title 'Regression of Price & Price^2 on Sales Unit'; 
run;

/* Linear Regression*/ 
proc reg data = Sales; 
 model SalesUnit = AdvertisingSpending; 
 title 'Regression of Ad Spend on Sales Unit'; 
run;

/* Regression Model with Ad^2*/
proc reg data = Sales; 
 model SalesUnit = AdvertisingSpending ad_2; 
 title 'Regression of Ad & Ad^2 on Sales Unit';  
run;

/* Optimal Regression*/ 
proc reg data = Sales; 
 model SalesUnit = Price price_2 AdvertisingSpending ad_2; 
 title 'Regression pf Ad Spend & Ad Spend^2 on Sales Unit'; 
run;

/* Cook's D & Influential Point with 2 factors*/ 
proc reg data = Sales;
 model SalesUnit = Price price_2 AdvertisingSpending ad_2;
 title 'Dectection of inlfuential points - 2 factors'; 
output out = regdata1 cookd = cookd student=sresiduals; 
run;

proc print data=regdata1 ;
 var _ALL_;
 where Cookd > 4 / 1200;
run;

proc reg data=regdata1;
model SalesUnit = Price price_2 AdvertisingSpending ad_2;
where Cookd < 4 / 1200;

/* Multicollinearity Detection*/ 

proc reg data = Sales;
 model SalesUnit = Price Price_2 AdvertisingSpending ad_2/ collinoint vif; 
 title 'Detect multicollineary with 4 factors'; 
run;

/* DROP Price^2 out of the model*/ 
proc reg data = Sales;
 model SalesUnit = Price AdvertisingSpending ad_2/ collinoint vif; 
 title 'model without price^2'; 
run;

proc reg data = Sales;
 model SalesUnit = Price AdvertisingSpending / collinoint vif; 
 title 'model without ad_2'; 
run;

/* Q4 - Impact of Price & Location on Sales */
proc glm data = sales; 
class Location (ref='Europe'); 
 model SalesUnit = Price price_2 Location Price*Location / Solution; 
 title 'Impact of Price And Location on Sales'; 
 run;

proc glm data = sales; 
class Promotion (ref='NoPromotion') Location (ref='Europe'); 
 model SalesUnit = Promotion Location Promotion*Location / Solution; 
title 'Impact of Promotion & Location on Sales'; 
run;  

/*Q5 - New Variable - Product Type */ 
proc sort data=Sales;
by Product_Type;
run;

PROC BOXPLOT data= sales; 
 PLOT SalesUnit*Product_type; 
 title 'Average Sales of Each Product Type'; 
 run; 

PROC SGPLOT data= sales; 
vbox salesunit/ group=Product_Type category=Location; 
run;
proc glm data=sales;
class location producttype(ref='1');   
model salesunit=price price_2 location product_type location*product_type/ solution;   
run;


ODS RTF FILE ='Question 6.rtf'; 
/*Product Type By Season Box Plot*/ 
PROC SGPLOT data= sales; 
vbox salesunit/ group=Season; 
title 'boxplot for sales by sesason'; 
run;

PROC SGPLOT data= sales; 
vbox salesunit/ group=Product_Type category=Season; 
title 'boxplot for sales of product type by sesason'; 
run;

proc glm data=sales;
class season(ref='2Spring') producttype;
model salesunit=price price*price season producttype season*producttype/ solution;
run;

ODS RTF Close; 

ODS RTF File ='Question 7.rtf'; 
/*Product Type By Season Box Plot*/ 
PROC SGPLOT data= sales; 
vbox salesunit/ group=SalesforceExperience;  
title 'boxplot for sales by Salesforce Experience'; 
run;

PROC SGPLOT data= sales; 
vbox salesunit/ group=SalesforceExperience category= Product_Type;  
title 'boxplot for sales by Salesforce Experience and Product Type'; 
run;

PROC SGPLOT data= sales; 
vbox salesunit/ group=Product_Type category= SalesforceExperience;  
title 'boxplot for sales by Salesforce Experience and Product Type'; 
run;

 proc glm data=sales;
class salesforceexperience (ref='High') producttype;
model salesunit=price price*price  producttype Salesforceexperience producttype*salesforceexperience/ solution;
run;
ODS RTF Close; 

 /*Ques 8*/ 
/*Glmod - Prog Reg to find best regression move on sales.csv*/ 
proc glmmod data=sales outdesign=sales_ver2 noprint; 
 class Product_Type Promotion SalesforceExperience Location Season;
 model salesunit = price price_2 AdvertisingSpending ad_2 Product_Type Promotion SalesforceExperience Location Season  / noint;
run;

proc glmmod data=sales_test outdesign=sales_test_ver2 noprint; 
 class Product_Type Promotion SalesforceExperience Location Season;
 model salesunit = price price_2 AdvertisingSpending ad_2 Product_Type Promotion SalesforceExperience Location Season  / noint;
run;

proc contents data=sales_ver2; 
run;

proc reg data=sales_ver2 outest= result1  plots=all;
 model salesunit = col1-col19 /selection=cp adjrsq aic bic best=1;
run;
quit; 

proc score data=sales_test_ver2 score=result1 Type=parms  predict out=predicted_data1;
 var col1-col19;
run;

data predicted_data1;
set  predicted_data1;
residula_2 = (salesunit-model1)**2;
run;

proc means data = predicted_data1 mean ; /* MSE TEST*/ 
var residula_2; 
run;

/*Foreward algorithm*/
proc glmselect data=sales testdata=sales_test  plots=all;
 class Product_Type(split)  Promotion(split) SalesforceExperience(split) location(split) season(split);
model salesunit = price|price_2|advertisingspending|ad_2|Product_Type|promotion|salesforceexperience|location|season @2
  /selection=forward(select=cp) hierarchy=single showpvalues;
 performance buildsscp=incremental;
 title 'Model Using Forward Algorithm'; 
run;

/*Backward selection*/
proc glmselect data=sales testdata=sales_test  plots=all;
 class Product_Type(split)  Promotion(split) SalesforceExperience(split) location(split) season(split);
model salesunit = price|price_2|advertisingspending|ad_2|Product_type|promotion|salesforceexperience|location|season @2
  /selection=backward(select=cp) hierarchy=single showpvalues;
 performance buildsscp=incremental;
 title 'Model Using Backward Algorithm'; 
run;

/*stepwise algorithm*/ 
proc glmselect data=sales testdata=sales_test  plots=all;
 class Product_Type(split)  Promotion(split) SalesforceExperience(split) location(split) season(split);
model salesunit = price|price_2|advertisingspending|ad_2|Product_type|promotion|salesforceexperience|location|season @2
  /selection=stepwise(select=cp) hierarchy=single showpvalues;
 performance buildsscp=incremental;
 title 'Model Using Stepwise Algorithm'; 
run;

/*Question 9* - Cross Validation - 10 folds*/
proc glmselect data=sales testdata=sales_test seed = 2  plots=all;
 class Product_Type(split)  Promotion(split) SalesforceExperience(split) location(split) season(split);
model salesunit = price|price_2|advertisingspending|ad_2|Product_type|promotion|salesforceexperience|location|season @2
  /selection=forward(select=cv) hierarchy=single cvmethod=random(10)showpvalues ;
 performance buildsscp=incremental;
 title 'Foward Algorithm with 10-folds Cross Validation'; 
run;
 
proc glmselect data=sales testdata=sales_test seed = 2  plots=all;
 class Product_Type(split)  Promotion(split) SalesforceExperience(split) location(split) season(split);
model salesunit = price|price_2|advertisingspending|ad_2|Product_type|promotion|salesforceexperience|location|season @2
  /selection=backward(select=cv) hierarchy=single cvmethod=random(10)showpvalues ;
 performance buildsscp=incremental;
 title 'Backward Algorithm with 10-folds Cross Validation'; 
run;

proc glmselect data=sales testdata=sales_test seed = 2  plots=all;
 class Product_Type(split)  Promotion(split) SalesforceExperience(split) location(split) season(split);
model salesunit = price|price_2|advertisingspending|ad_2|Product_type|promotion|salesforceexperience|location|season @2
  /selection=stepwise(select=cv) hierarchy=single cvmethod=random(10)showpvalues ;
 performance buildsscp=incremental;
 title 'Stepwise Algorithm with 10-folds Cross Validation'; 
run;

/*Question 10 - LASSO & ELSATIC NET*/ 
proc glmselect data=sales testdata=sales_test seed = 2  plots=all;
 class Product_Type(split)  Promotion(split) SalesforceExperience(split) location(split) season(split);
model salesunit = price|price_2|advertisingspending|ad_2|Product_type|promotion|salesforceexperience|location|season @2
    /selection=lasso(choose=cv stop=none) hierarchy=single cvmethod=random(10) showpvalues;
 performance buildsscp=incremental;
 title 'LASSO model with 10-folds Cross Validation'; 
run;

proc glmselect data=sales testdata=sales_test seed = 2  plots=all;
 class Product_Type(split)  Promotion(split) SalesforceExperience(split) location(split) season(split);
model salesunit = price|price_2|advertisingspending|ad_2|Product_type|promotion|salesforceexperience|location|season @2
    /selection=elasticnet(choose=cv stop=none) hierarchy=single cvmethod=random(10) showpvalues;
 performance buildsscp=incremental;
 title 'ELASTIC NET model with 10-folds Cross Validation'; 
run;

/*Question 11*/ 
proc glmselect data=sales testdata=sales_test seed = 2  plots=all;
 class Product_Type(split)  Promotion(split) SalesforceExperience(split) location(split) season(split);
model salesunit = price|price_2|advertisingspending|ad_2|Product_type|promotion|salesforceexperience|location|season @2
  /selection=stepwise(select=cv) hierarchy=single cvmethod=random(10) showpvalues;
 modelaverage nsamples=100 tables=(ParmEst(all));
 performance buildsscp=incremental;
 score data=sales_test out=test_performance residual=res;
 score data=sales out=insample_performance residual=res;
run;

data test_performance; 
 set test_performance; 
 sq_res = res*res;
run;

proc means data=test_performance mean; 
 var sq_res;
run;

data insample_performance; 
 set insample_performance; 
 sq_res = res*res;
run;

proc means data=insample_performance mean; 
 var sq_res;
run;

/*Question 12* - Work In Progress*/ 
proc append base=sales_increasing_ad data=sales;
run; 

proc append base=sales_increasing_expertise data=sales;
run; 

data sales_increasing_ad; 
 set sales_increasing_ad; 
 new_ad = advertisingspending*1.1; 
 new_ad_2 = (advertisingspending*1.1)**2; 
run; 

proc sort data=sales_increasing_expertise;
by salesforceexperience;
run;

DATA sales_increasing_expertise;
    SET sales_increasing_expertise;
    IF salesforceexperience = 'Low' THEN new_salesexperience = 'Average';
    IF salesforceexperience = 'Average' THEN new_salesexperience = 'High';
	IF salesforceexperience = 'High' THEN new_salesexperience = 'High';
RUN;

/*Sales Before Each Strategy*/ 
proc means data=sales sum;
var salesunit;
run;

/*Predicted sales volume when ad increase*/ 
proc glmselect data=sales_increasing_ad seed = 2  plots=all;
 class Product_Type(split)  Promotion(split) SalesforceExperience(split) location(split) season(split);
model salesunit = price|price_2|new_ad|new_ad_2|Product_type|promotion|salesforceexperience|location|season @2
  /selection=stepwise(select=cv) hierarchy=single cvmethod=random(10) showpvalues;
 modelaverage nsamples=100 tables=(ParmEst(all));
 performance buildsscp=incremental; 
 score data=sales_increasing_ad out=ad_strategy residual=res;
run;

data ad_strategy; 
 set ad_strategy; 
 predicted_sales_1 = salesunit - res; 
run; 

proc means data=ad_strategy sum;
var predicted_sales_1;
run;

/* Predicted sales volume when expertise changed from low- average, & average to high*/ 
proc glmselect data=sales_increasing_expertise seed = 2  plots=all;
 class Product_Type(split)  Promotion(split) new_SalesExperience(split) location(split) season(split);
model salesunit = price|price_2|advertisingspending|ad_2|Product_type|promotion|new_SalesExperience|location|season @2
  /selection=stepwise(select=cv) hierarchy=single cvmethod=random(10) showpvalues;
 modelaverage nsamples=100 tables=(ParmEst(all));
 performance buildsscp=incremental; 
  score data=sales_increasing_expertise out=exp_strategy residual=res;
run; 

data exp_strategy; 
 set exp_strategy; 
 predicted_sales_2 = salesunit - res; 
run;

proc means data=exp_strategy sum;
var predicted_sales_2;
run;
