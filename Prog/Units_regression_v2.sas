/**************************************************************************
 Program:  Units_regression.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/13/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Estimate numbers of rental units for parcels without
data in Realprop.Parcel_rental_units.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( RealProp, local=n )

data Units_regression;

  merge
    RealProp.Parcel_base
      (in=inPB
       keep=ssl ui_proptype in_last_ownerpt usecode assess_val landarea
       where=(ui_proptype='13'))
    RealProp.Parcel_rental_units
      (keep=ssl units_active units_retired)
    RealProp.Parcel_geo
      (keep=ssl ward2012);
  by ssl;
  
  if inPB;
  
  if Units_active > 0 then Units_mar = Units_active;
  else if Units_retired > 0 then Units_mar = Units_retired;
  
  ** Nonzero assessed value and landarea **;
  
  if assess_val > 0 then assess_val0 = 0;
  else assess_val0 = 1;
  
  if landarea > 0 then landarea0 = 0;
  else landarea0 = 1;
  
  ** Squared terms **;
  
  assess_val_sq = assess_val * assess_val;
  landarea_sq = landarea * landarea;
  
  ** Ward dummies **;
  
  if not( missing( Ward2012 ) ) then do;
  
    array a_ward dWard1-dWard8;
    
    do i = 1 to dim( a_ward );
      if Ward2012 = i then a_ward{i} = 1;
      else a_ward{i} = 0;
    end;
    
  end;
  
  ** Usecode dummies **;

  if not( missing( usecode ) ) then do;

    if usecode='021' then dusecode021=1; else dusecode021=0;
    if usecode='022' then dusecode022=1; else dusecode022=0;
    if usecode='023' then dusecode023=1; else dusecode023=0;
    if usecode='024' then dusecode024=1; else dusecode024=0;
    if usecode='025' then dusecode025=1; else dusecode025=0;
    if usecode='029' then dusecode029=1; else dusecode029=0;

  end;
  
  drop i;

run;

%File_info( data=Units_regression )

ods tagsets.excelxp file="L:\Libraries\DHCD\Prog\Units_regression_v2.xls" style=Minimal options(sheet_interval='Table' );


proc reg data=Units_regression SIMPLE;
	model Units_mar = assess_val assess_val0 assess_val_sq landarea landarea0 landarea_sq dward1-dward7 dusecode021--dusecode029;
	where Units_mar > 1 and ssl ne "" and in_last_ownerpt;
	output out=reg1_nogeo_results R=residual p=predicted;
	run;
	quit;
run;

ods tagsets.excelxp close;

proc plot data=reg1_nogeo_results;
  plot Units_mar * predicted;
run;

proc print data=reg1_nogeo_results;
  where Units_mar > 1000;
  id ssl;
run;


data Dhcd.Units_regression;

  set Units_regression;

  Units_est = round( 
    ( 1 * -2.07434 ) +
    ( ASSESS_VAL * 0.00000425 ) +
    ( assess_val0 * 1.55008 ) +
    ( assess_val_sq * -0.000000000000012133 ) +
    ( LANDAREA * 0.00069496 ) +
    ( landarea0 * 155.36893 ) +
    ( landarea_sq * -0.00000000019535 ) +
    ( dWard1 * 4.43698 ) +
    ( dWard2 * 0.28789 ) +
    ( dWard3 * -2.55831 ) +
    ( dWard4 * 2.16297 ) +
    ( dWard5 * 1.38777 ) +
    ( dWard6 * 2.38406 ) +
    ( dWard7 * 0.87793 ) +
    ( dusecode021 * 2.40707 ) +
    ( dusecode022 * 31.76003 ) +
    ( dusecode023 * 0.74434 ) +
    ( dusecode024 * -1.73116 ) +
    ( dusecode025 * -0.12369 ) +
    ( dusecode029 * 31.70052 )
    ,
    1 );
    
  if Units_est < 1 then Units_est = .u;
  
  if Units_mar > 1 then Units_full = Units_mar;
  else Units_full = Units_est;

run;

%File_info( data=Dhcd.Units_regression )

proc univariate data=Dhcd.Units_regression plot;
  var units_mar units_est units_full;
run;
