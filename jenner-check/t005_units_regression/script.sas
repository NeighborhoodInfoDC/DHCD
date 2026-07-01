/**************************************************************************
 Bundle:   t005_units_regression
 Source:   Prog/RC_Regression.sas  (NeighborhoodInfoDC/DHCD)
 Original: A. Williams, DC Rent Control Database, 11/18/10

 Description (from source): Regression to estimate unit counts for SSLs.
 This bundle reproduces the regression-prep DATA step (use-code dummy
 variables), the PROC MEANS over the predictor list, and the PROC REG
 model of active_res on assess_val, landarea and the use-code dummies,
 exactly as written in the source.

 Adaptation: the original reads dhcd.parcel_unit_geo_merge from an
 external SAS library (DCData framework). Here that input is supplied as
 a small inline sample with the columns the model reads (active_res,
 assess_val, landarea, usecode, ssl, ui_proptype, in_last_ownerpt). The
 %let predictor lists, the DATA step, PROC MEANS and PROC REG are
 reproduced exactly.
**************************************************************************/

** Sample standing in for dhcd.parcel_unit_geo_merge **;
data parcel_unit_geo_merge;
  length ssl $ 17 ui_proptype usecode $ 3;
  input ssl $ ui_proptype $ usecode $ in_last_ownerpt active_res assess_val landarea;
  datalines;
0001 13 021 1 12  850000 3200
0002 13 022 1 18 1200000 4100
0003 13 023 1  6  420000 1800
0004 13 024 1  4  380000 1600
0005 13 025 1 24 1650000 5200
0006 13 021 1 10  720000 2900
0007 13 022 1 30 2100000 6800
0008 13 023 1  8  510000 2100
0009 13 021 1 16 1050000 3600
0010 13 024 1  5  400000 1700
0011 13 025 1 40 2700000 8100
0012 13 022 1 14  980000 3300
;
run;

data reg1;
		set parcel_unit_geo_merge;
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

title Units regression;
proc reg data=reg1 SIMPLE;
	model active_res= assess_val landarea &varlst.;
	where active_res >1 and ssl ne "";
	output out=reg1_nogeo_results R=residual p=predicted;
	run;
	quit;

proc means data=reg1_nogeo_results;
var predicted;
run;
