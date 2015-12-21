/**************************************************************************
 Program:  Regression.sas
 Library:  DHCD
 Project:  DC Rent Control Database
 Author:   A. Williams
 Created:  11/18/10
 Version:  SAS 9.1
 Environment:  Windows
 Description:  Regression to estimate unit counts for SSLs
 Modifications:

Note: NEED TO RUN ADDRESS_UNITS PROGRAM FIRST

**************************************************************************/


%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
	%DCData_lib( DHCD )
	%DCData_lib( RealProp )
	%DCData_lib( MAR )

/**************************************************
**************************************************
REGRESSION PREP
**************************************************/;

data reg1;
		set dhcd.parcel_unit_geo_merge;
		/*log_units=log(active_res);*/
		*Ward;
			/*%macro Ward;
			%do i=1 %to 8;
			if ward2002="&i." then dWard&i.=1; else dWard&i.=0;
			%end;

			%do i=10 %to 39;
			if cluster2000="&i." then dCluster&i.=1; else dCluster&i.=0;
			%end;
			if cluster2000="01" then dcluster01=1; else dcluster01=0;
			if cluster2000="02" then dcluster02=1; else dcluster02=0;
			if cluster2000="03" then dcluster03=1; else dcluster03=0;
			if cluster2000="04" then dcluster04=1; else dcluster04=0;
			if cluster2000="05" then dcluster05=1; else dcluster05=0;
			if cluster2000="06" then dcluster06=1; else dcluster06=0;
			if cluster2000="07" then dcluster07=1; else dcluster07=0;
			if cluster2000="08" then dcluster08=1; else dcluster08=0;
			if cluster2000="09" then dcluster09=1; else dcluster09=0;

			if cluster2000="99" then dcluster99=1; else dcluster99=0;

			%mend;
			%Ward;*/
				If usecode='021' then dusecode021=1; else dusecode021=0;
				If usecode='022' then dusecode022=1; else dusecode022=0;
				If usecode='023' then dusecode023=1; else dusecode023=0;
				If usecode='024' then dusecode024=1; else dusecode024=0;
				If usecode='025' then dusecode025=1; else dusecode025=0;
				If usecode='029' then dusecode029=1; else dusecode029=0;

				where ui_proptype = "13" and ssl ne "" and in_last_ownerpt = 1;

		run;
options mprint symbolgen;

%let varlst=  dusecode021 dusecode022 dusecode023 dusecode024 dusecode025  ;
%let varExcludeLst=  dusecode029;


proc means data=reg1;
var &varlst.  &varExcludeLst. ; 
run;

/**************************************************
**************************************************
REGRESSION
**************************************************/;
title Units regression;
proc reg data=reg1 SIMPLE;
	model active_res= assess_val landarea &varlst.;
	where active_res >1 and ssl ne "";
	output out=reg1_nogeo_results R=residual p=predicted;
	run;
	quit;

/*
proc reg data=reg1;
model log_units= assess_val landarea &varlst.;
output out=reg1_log_nogeo_results R=residual p=predicted;
run;
quit;

proc reg data=reg1;
model active_res= assess_val landarea &varlst. &geovarlst.;
output out=reg2_results R=residual p=predicted;
run;
quit;

proc reg data=reg1;
model log_units= assess_val landarea &varlst. &geovarlst.;
output out=reg2_log_results R=residual p=predicted;
run;
quit;*/

%macro plot (reg);
proc plot data=&Reg.;
  plot active_res * predicted;
run;
%mend;

%plot (reg1_nogeo_results);
/*%plot (reg1_log_nogeo_results);
%plot (reg2_results);
%plot (reg2_log_results);*/

proc means data=reg1_nogeo_results;
var predicted;
run;

proc format;
value pred
low-<0 = "negative"
0-<.5= "less than .5"
.5-high= ".5 or higher";
run;

proc freq data=reg1_nogeo_results;
table predicted;
format predicted pred.;
run;

/*proc reg data=reg1;
model log_units= assess_val landarea &varlst.;
run;
quit;*/

data mar.Parcel_units (keep= ssl unit_count predicted drop= dusecode021-dusecode025 dusecode029);
set reg1;
active_res_PREDICTED= ROUND( 
/*intercept*/       32.44819 +
ASSESS_VAL*0.00000374 + 


LANDAREA*0.00062771 + 

dusecode021*-28.65119 + 
dusecode022*7.31087 + 
dusecode023*-32.57459 + 
dusecode024*-33.72861 + 
dusecode025*-32.78507


)
;
if active_res ne . then do; 
	Unit_Count=active_res; 
	predicted=0; 
	end; 

else do; 
	unit_count=active_res_predicted; 
	predicted=1;
	end;
if unit_count <.5 then unit_count=1;
run;


proc means data= parcel_units sum;
var unit_count;
where ssl ne "";
run;
