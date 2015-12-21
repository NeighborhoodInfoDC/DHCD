/**************************************************************************
 Program:  Address_units.sas
 Library:  DHCD
 Project:  DC Rent Control Database 07080-015-00
 Author:   A. Williams
 Created:  11/18/10
 Version:  SAS 9.1
 Environment:  Windows
 Description:  Preps address units file for regression
 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
	%DCData_lib( DHCD )
	%DCData_lib( RealProp )
	%DCData_lib( MAR )


*New address unit file;
	data addresspt;
	set mar.addresspt;
	run;

	proc contents data=addresspt;
	run;

*Check for number of SSLs with missing units;
	proc freq data=addresspt ;
	table ACTIVE_RES;
	where active_res=.;
	run;

	proc sort data=addresspt;
	by ssl;
	run;

*summarize by ssl to get total unit count;
	proc summary data=addresspt sum;
	var active_res;
	by ssl;
	where ssl ne ""; *exclude properties with missing SSLs;
	output out=summed_units (keep=active_res ssl) sum=;
	run;

*Merge unit counts with parcel base info;
	proc sort data= summed_units;
	by SSL;
	run;

	proc sort data= realprop.who_owns out=parcel_base;
	by SSL;
	run;

	data parcel_unit_merge match_check;
	merge  parcel_base (in=a where=(ui_proptype="13")) summed_units (in=b);
	by SSL;
	if a=1 and b=0 then parcel_only=1; else parcel_only=0;
	if b=1 and a=0 then address_only=1; else address_only=0;
	if a=1 then output parcel_unit_merge; else output match_check;
	/*if a=1 and b=1 then output parcel_unit_merge; else if a=1 and b=0 then output nomatch;*/
	run;

*Check results;
proc format;
value unit
0="0"
1="1"
2="2"
3-5="3-5"
6-10="6-10"
11-50="11-50"
50-100="50-100"
101-700="101-700"
701-high="700 or above";
run;


proc freq data=addresspt;
table active_res;
run;

proc means data=parcel_unit_merge;
var active_res;
run;

proc sort data=realprop.parcel_geo out=parcel_geo;
by ssl;
run;

* Merge parcel_geo info on;
data dhcd.parcel_unit_geo_merge (drop=parcel_only address_only) nomatch;
merge parcel_geo (in=a) parcel_unit_merge (in=b);
by ssl;
if b=1 then output dhcd.parcel_unit_geo_merge;
if a=0 and b=1 then output nomatch;
run;

