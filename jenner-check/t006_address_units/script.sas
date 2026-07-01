/**************************************************************************
 Bundle:   t006_address_units
 Source:   Prog/RC_Address_units.sas  (NeighborhoodInfoDC/DHCD)
 Original: A. Williams, DC Rent Control Database, 11/18/10

 Description (from source): Preps the address-units file for the unit-count
 regression. The address points (one row per residential unit) are
 summed to a total active-residential unit count per SSL (parcel), then
 merged onto the parcel ownership file restricted to rental apartment
 buildings (ui_proptype "13").

 Adaptation: the original reads mar.addresspt and realprop.who_owns from
 external SAS libraries (DCData framework). Here those inputs are supplied
 as small inline samples with the columns the program reads (ssl,
 active_res; ssl, ui_proptype). The PROC FREQ, PROC SORT, PROC SUMMARY
 (sum by SSL), the MERGE with match flags, and the closing PROC FREQ /
 PROC MEANS are reproduced exactly as written in the source.
**************************************************************************/

** Sample standing in for mar.addresspt (address points, one per unit) **;
data addresspt;
  length ssl $ 17;
  input ssl $ active_res;
  datalines;
0001 1
0001 1
0001 1
0002 1
0002 1
0003 1
0004 .
0005 1
0005 1
0006 1
;
run;

** Sample standing in for realprop.who_owns (parcel ownership file) **;
data who_owns;
  length ssl $ 17 ui_proptype $ 3;
  input ssl $ ui_proptype $;
  datalines;
0001 13
0002 13
0003 13
0004 13
0005 10
0006 13
0007 13
;
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

	proc sort data= who_owns out=parcel_base;
	by SSL;
	run;

	data parcel_unit_merge match_check;
	merge  parcel_base (in=a where=(ui_proptype="13")) summed_units (in=b);
	by SSL;
	if a=1 and b=0 then parcel_only=1; else parcel_only=0;
	if b=1 and a=0 then address_only=1; else address_only=0;
	if a=1 then output parcel_unit_merge; else output match_check;
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
