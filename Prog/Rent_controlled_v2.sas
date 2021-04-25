/**************************************************************************
 Program:  Rent_controlled_v2.sas
 Library:  DHCD
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  10/12/14
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Compile list of buildings and units potentially
 subject to rent control.

 Version 2

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( RealProp )
%DCData_lib( PresCat )
%DCData_lib( MAR )

%let revisions = Update with latest parcel and address data.;

%Data_to_format(
  FmtLib=work,
  FmtName=$nlihcid_to_projname,
  Desc=,
  Data=PresCat.Project_category_view,
  Value=nlihc_id,
  Label=proj_name,
  OtherLabel=,
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=N,
  Contents=N
  )

%Data_to_format(
  FmtLib=work,
  FmtName=$nlihcid_to_subsidized,
  Desc=,
  Data=PresCat.Project_category_view,
  Value=nlihc_id,
  Label=put(subsidized,1.),
  OtherLabel='0',
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=N,
  Contents=N
  )


/**************************************************
**************************************************
1. Restrict to Rental units that are not tax exempt 
(Exclude commercial, hotel properties, condos, single-family, coops, etc)
**************************************************/;
data rental_1;
	merge 
	  realprop.Parcel_base_who_owns
	    (in=a
		 drop=ui_proptype in_last_ownerpt)
	  realprop.Parcel_base 
	    (in=b
	     keep=ssl ui_proptype in_last_ownerpt ownerpt_extractdat_first ownerpt_extractdat_last usecode premiseadd);
	by ssl;  
	if b and ui_proptype in ( "10", "11", "13", "19" ) and ssl ne "" and in_last_ownerpt = 1; *Residential: Rental apartment building ;

	** Only keep SF homes and condos if certain that they are rental properties **;
    if ui_proptype in ( "10", "11" ) then do;
	  if owner_occ_sale then delete;
      if ui_proptype = '11' and ( scan( premiseadd_std, 1, '#' ) = scan( owneraddress_std, 1, '#' ) or 
	     trim( owneraddress_std ) =: trim( premiseadd_std ) or
         premiseadd_std = '' or owneraddress_std = '' ) then delete;
	end;

	if MIX2TXTYPE = "TX" or MIX1TXTYPE = "TX" then Excluded_Nontaxable=0; else Excluded_Nontaxable=1;

  if left( ownername_full ) =: "+ " then ownername_full = "";
  
  label Excluded_Nontaxable = "Nontaxable property exclusion applies";

	run;


/**************************************************
**************************************************
2. Merge on Camarespt file (obtained from Peter Tatian) to get the AYB (Actual year built)
	2.1. Exclude properties that were issued a building permit after Dec. 31, 1975 
		(use 1977 since AYB may be after bilding permit was issued)
		2.1.2. Create flag for properties built after 1975 (1976, 1977) 
**************************************************/;

data cama;
set RealProp.Cama_building;
if ayb < 1800 or ayb > year( today() ) then ayb = .u;
if eyb < 1800 or eyb > year( today() ) then eyb = .u;
run;

/*
** Double check that none of the duplicate SSLs are in our file **;

proc summary data=cama n;
by ssl;
var ayb eyb;
output out=test1 (where=(_freq_>1)) 
 min= max= /autoname;
run;

data test2;
merge rental_1 (in=a) test1 (in=b);
by ssl;
if a=1 and b=1;
run;

title2 '---SSLs with multiple entries in CAMA files---';
proc print data=test2 n;
  id ssl;
  var in_last_ownerpt ui_proptype ownername_full _freq_ ayb_min ayb_max;
run;
title2;
*/

** Use earliest AYB value for identifying possible rent controlled properties **;
proc summary data=cama min;
var ayb eyb;
by ssl;
output out=cama_min min= /autoname;
run;

*Merge on AYB_min;
data rental_2;  * there are A LOT where the ayb=0;
	merge rental_1 (in=a) cama_min  (in=b);
	by ssl;
	if a=1;

  year_built_min = min( ayb_min, eyb_min );

	/*2.1 Flag buildings built before 1978*/
	if year_built_min < 1978 then Exempt_built1978=0; else Exempt_built1978=1; 

	/*2.2 create post 1975 flag*/
	if year_built_min ge 1976 then AYB_assumption=1;	else AYB_assumption=0;
	if year_built_min =0 or missing(ayb_min) then AYB_missing=1;	else AYB_missing=0;
	
	label 
	  year_built_min = "Composite property year built minimum from AYB and EYB"
	  Exempt_built1978 = "Property built 1978 or later exemption applies"
	  AYB_assumption = "Property year built >= 1976"
	  AYB_missing = "Property year built missing";

run;	

** Double check for duplicate SSLs **;

%Dup_check(
  data=rental_2,
  by=ssl,
  id=ayb_min,
  listdups=Y
)

proc freq data=rental_2;
  tables ui_proptype * ayb_missing / list missing;
run;


/**************************************************
**************************************************
3. Merge on Assisted units
	3.1. Exclude properties receiving a federal or district subsidy
**************************************************/;

proc sort data=PresCat.Parcel (where=(put( nlihc_id, $nlihcid_to_subsidized. ) = '1')) out=Prescat_parcel nodupkey;
  by ssl;
run;

data rental_3;
	merge 
	  rental_2 (in=a) 
	  Prescat_parcel (keep=nlihc_id ssl in=b);
	by ssl;

	if a;

	if b then Exempt_assisted=1; else Exempt_assisted=0; 
	
	label Exempt_assisted = "Assisted housing exemption applies";
	
	run;

%File_info( data=rental_3, printobs=0, contents=n )


/**************************************************
**************************************************
4. Add on property address, ward, ANC, neighborhood cluster, and census tract
**************************************************/;

data rental_5;
merge 
  rental_3 (in=a) 
  realprop.parcel_geo (keep=ssl ANC2012 Ward2012 Cluster2017 geo2010 zip x_coord y_coord);
by ssl;
if a=1;

  ** Fill in missing geos for selected properties **;
  select ( ssl );
    when ( '0158    0084' ) do;
      ward2012 = '2';
      cluster2017 = '06';
    end;
    when ( '0701    7040' ) do;
      ward2012 = '6';
      cluster2017 = '27';
    end;
    when ( '3117    0096' ) do;
      ward2012 = '5';
      cluster2017 = '21';
    end;
    when ( '4513    0082' ) do;
      ward2012 = '6';
      cluster2017 = '25';
    end;
    when ( '5622    0073' ) do;
      ward2012 = '8';
      cluster2017 = '34';
    end;
    when ( '5933    0114' ) do;
      ward2012 = '8';
      cluster2017 = '39';
    end;
    otherwise
      /** SKIP **/;
  end;

run;

%File_info( data=rental_5, contents=n, printobs=0, freqvars=ward2012 cluster2017 )


/**************************************************
**************************************************
5. Merge with OCTO's rental unit address database to get unit addresses and counts
**************************************************/;

data rental_6;
	merge 
	  rental_5 (in=a) 
	  RealProp.Parcel_units (drop=ui_proptype rename=(total_res_units=units_mar));
	by ssl;
	if a=1;
	if ui_proptype in ( '10', '11' ) then do;
	  ** Single family homes and condo units **;
	  units_full = 1;
	  predicted = 0;
	end;
      else if units_mar > 0 then do;
	  ** Unit count reported in MAR **;
	  predicted = 0;
	  units_full = units_mar;
	end;
	else if ui_proptype = '13' and usecode in ( '023', '024' ) then do;
	  ** Rented townhomes/assume unit count = 1 **;
	  units_full = 1;
	  predicted = 1;
	end;
	
	label 
	  units_full = "Full property unit count"
	  predicted = "Property unit count is estimated";
	  
	run;

	*check duplicates;
	%Dup_check(
	  data=rental_6,
	  by=ssl,
	  id=ayb_min ui_proptype,
	  listdups=Y
	)

	*Check missing;
	proc means data= rental_6 n nmiss sum min max;
	  var Units_full Units_mar;
	run;

	data test5;
		set rental_6;
		where Units_full in ( 0, ., .u );
	run;

	proc freq data=test5;
	  tables usecode;
	  format usecode ;
	run;


/**************************************************
**************************************************
6. Exclude rental units owned by a person who own 4 units or less
	-->Exemption does not apply to those who aren't individuals
**************************************************/;

*Create new dummy variable to indicate if property is greater than 5 units;
data rental_6_1;
	set rental_6;

	*5 or more units as id'd by Parcel_base;
	if usecode = "025" then units5plus_realprop=1;
	else units5plus_realprop=0;

	if units5plus_realprop=0 and units_full ge 5 and predicted=1 then adj_unit_count=4; *if codes as less than 5 units and our predicted value says more than 5, then adjust to 4;
	else if units5plus_realprop=1 and units_full le 5 and predicted=1 then adj_unit_count=5; 
	else adj_unit_count=units_full;

	if adj_unit_count ge 5  then units5plus_flag=1; else units5plus_flag=0; * assign flag for units greater than 5;

	rename predicted= Unit_count_pred_flag ;

	  length owner_add $ 500;

  *Use standardized owner address where possible;
if owneraddress_std ne "" then 
  OWNER_ADD=upcase( left( compbl( owneraddress_std ) ) ); 
else if owneraddress ne "" then do;
  if address3 =: "WASHINGTON, DC" then
    OWNER_ADD=upcase( left( compbl( trim( owneraddress ) ) ) );
  else OWNER_ADD=upcase( left( compbl( trim( owneraddress ) || "; " || left( address3 ) ) ) );
end;

 label
   units5plus_realprop = "Real property use code indicates 5+ units"
   adj_unit_count = "Adjusted property unit count"
   units5plus_flag = "Adjusted property unit count is 5+ units"
   owner_add = "Full owner mailing address for matching";
   
	run;

** Check for owners of multiple properties by address **;

proc sql noprint;
  create table rental_6_2 as
  select rental_6_1.*, Owner_add_sum.*
  from rental_6_1 left join
  ( select 
    owner_add, 
    count( owner_add ) as owner_add_count label="Number of properties for same owner address", 
    sum( adj_unit_count ) as adj_unit_count_owner_add_sum label="Number of units for same owner address"
  from rental_6_1
  where owner_add ne ""
  group by owner_add ) as Owner_add_sum
  on Owner_add_sum.owner_add = rental_6_1.owner_add
;
quit;

/*
title2 '-- Multiple properties by owner address --';
proc print data=rental_6_2 (obs=200);
  where owner_add_count > 1;
  id owner_add;
  var ssl owner_add_count adj_unit_count_owner_add_sum;
run;
title2;
*/

** Check for owners of multiple properties by name **;

proc sql noprint;
  create table rental_6_3 as
  select rental_6_2.*, Ownername_sum.*
  from rental_6_2 left join
  ( select 
    ownername_full, 
    count( ownername_full ) as Ownername_count label="Number of properties for same owner name", 
    sum( adj_unit_count ) as adj_unit_count_ownername_sum label="Number of units for same owner name"
  from rental_6_1
  where ownername_full ne ""
  group by ownername_full ) as Ownername_sum
  on Ownername_sum.ownername_full = rental_6_2.ownername_full
;
quit;

/*
title2 '-- Multiple properties by owner name --';
proc print data=rental_6_3 (obs=200);
  where ownername_count > 1;
  id ownername_full;
  var ssl ownername_count adj_unit_count_ownername_sum;
run;
title2;
*/

** Create owner exemption flags **;
proc freq data=rental_6_3;
  tables ownercat;
  format ownercat ;
run;

data rental_7;
	set rental_6_3;

	** Owns 5 or more units **;
	if adj_unit_count_owner_add_sum ge 5 or adj_unit_count_ownername_sum ge 5 then 
	owns5plus_assump_flag = 1;
	else owns5plus_assump_flag = 0;

	*Create exemption code for ALL that have lt 5 units, regardless of owner type;
	if units5plus_flag=1 or owns5plus_assump_flag=1 then Exempt_lt5units_ALL=0; else Exempt_lt5units_ALL=1;

	*Exemption does not apply to non individuals;
	if ownercat in ("010", "020", "030") then Indiv=1; 
		else Indiv=0;

	* Create final flag for those who are not individuals and have lt 5 units;
	if Indiv=0 and Exempt_lt5units_ALL=1 then Exempt_lt5units_Indiv=0;
	else if Indiv=1 and Exempt_lt5units_ALL=1 then Exempt_lt5units_Indiv=1;
	else exempt_lt5units_indiv=0;

* Create var for DC owners--pulled from foreclosure_history code;
	length OwnerDC 3;

  if address3 ~= '' then do;
  	if indexw( address3, 'DC' ) then OwnerDC=1;
  	else OwnerDC= 0;
 	 end;
 	 else OwnerDC = .u;
** Assume OwnerDC=1 for government & quasi-gov. owners **;
  
  if OwnerCat in ( '040', '045', '050', '060', '070' ) then OwnerDC = 1;

  label 
    owns5plus_assump_flag = "Ownership of 5+ units based on multiple parcels with same owner name or address"
    Exempt_lt5units_ALL = "Fewer than 5 units exemption regardless of owner type"
    Indiv = "Owner is an individual (legal person)"
    Exempt_lt5units_Indiv = "Individual with fewer than 5 units exemption applies"
    OwnerDC = 'DC-based owner';

run;

proc freq data=rental_7;
  tables Indiv * Exempt_lt5units_ALL * Exempt_lt5units_Indiv / list missing;
  title2 'File = rental_7';
run;
title2;


/**************************************************
**************************************************
7. Flag government Owners
**************************************************/;

data rental_7_1;
set rental_7;

if ownercat in ("040", "045", "050") then Exempt_govowned=1; else Exempt_govowned=0;

if ownercat="060" then Excluded_Foreign=1; else Excluded_Foreign=0;

*flag if a trust;
Trust1=find(OWNERNAME_full, "trust", "i");

if trust1>0 then Trust_flag=1; else Trust_flag=0;

label 
  Exempt_govowned = "Government-owned property exemption applies"
  Excluded_Foreign = "Foreign property owner exclusion applies"
  Trust_flag = "Property owner is a trust";

drop Trust1;

run;

%File_info( data=rental_7_1, printobs=0, contents=n )

data test7;
set rental_7_1;
where adj_Unit_Count=1 and unit_count_pred_flag=0 ;
run;


/**************************************************
**************************************************
Create flags and final file
**************************************************/;

proc format;
value ayb
.u="Unknown";
run;

proc sort data=rental_7_1;
  by ssl;
run;

proc sort data=DHCD.rent_control_database_041511 out=rent_control_database_041511;
  by ssl;
run;

data Parcels_Rent_Control;
merge 
  rental_7_1 
  rent_control_database_041511 
    (keep=ssl Rent_controlled
     rename=(Rent_controlled=Rent_controlled_2011)
     in=b);
by ssl;

if not b then Rent_controlled_2011 = .n;

*Flag if receives no exemptions or exclusions; 
if Excluded_nontaxable=0
and Excluded_Foreign=0
and Exempt_lt5units_Indiv=0  /*only case where not being an individual matters*/
and Exempt_built1978=0
and Exempt_assisted=0
and Exempt_govowned=0
then Rent_controlled=1; else Rent_controlled=0;

*Flag if receive one or more exemptions--does not take exclusions into account;
if  Exempt_lt5units_Indiv=1
or Exempt_built1978=1
or Exempt_assisted=1
or Exempt_govowned=1 then Exempt_any=1; else Exempt_any=0;

label
  Rent_controlled = "Property is subject to rent control (current estimate)"
  Rent_controlled_2011 = "Property was subject to rent control in original 2011 estimate"
  Exempt_any = "One or more property exemptions apply";

format 
  ayb_assumption ayb_missing Unit_count_pred_flag units5plus_realprop units5plus_flag 
  owns5plus_assump_flag Indiv OwnerDC Trust_flag Exempt_: Excluded_: Rent_controlled: 
  dyesno.;

format ssl ;

informat _all_ ;

drop _type_ _freq_;

run;

%Finalize_data_set( 
  /** Finalize data set parameters **/
  data=Parcels_rent_control,
  out=Parcels_rent_control,
  outlib=DHCD,
  label="Residential property parcels classified by estimated rent control status",
  sortby=ssl,
  /** Metadata parameters **/
  restrictions=None,
  revisions=%str(&revisions),
  /** File info parameters **/
  printobs=0,
  freqvars=Rent_controlled Rent_controlled_2011
)


/**************************************************
**************************************************
Output and diagnostics 
**************************************************/;

%Dup_check(
  data=Parcels_Rent_Control,
  by=ssl,
  id=premiseadd,
  listdups=Y
)

proc format;
  value rc (notsorted)
    1 = 'Rent controlled'
    0 = 'Not rent controlled';
run;

proc tabulate data=Parcels_Rent_Control format=comma12.0 noseps missing;
  where in_last_ownerpt;
  class ui_proptype ward2012;
  class rent_controlled / preloadfmt order=data;
  var adj_unit_count;
  table 
    /** Pages **/
    ui_proptype=' ',
    /** Rows **/
    all='DC' ward2012=' ',
    /** Columns **/
    ( all='Total' rent_controlled=' ' ) *
    ( n='Properties' sum=' '*adj_unit_count='Units' )
    / condense;
  format rent_controlled rc.;
run;

title2 '--Missing geography--';
proc print data=Parcels_Rent_Control;
  where missing( Ward2012 ) and not missing( ui_proptype );
  id ssl; 
  var premiseadd ui_proptype nlihc_id;
run;
title2;

proc freq data=Parcels_Rent_Control;
  tables Rent_controlled * Rent_controlled_2011 / list missing;
run;

/*
proc compare base=Dhcd.Parcels_rent_control compare=Parcels_rent_control maxprint=(40,32000);
  id ssl;
run;
*/

/*
** Compare conflicting results from 2011 analysis **;

proc compare maxprint=(40,32000) out=compare1 outnoequal outbase outcomp outdif noprint
    base=rent_control_database_041511 
	  (where=(not Rent_controlled))
    compare=Parcels_Rent_Control 
      (where=(Rent_controlled and Rent_controlled_2011 = 0));
  id ssl;
  var Rent_controlled exempt_: Indiv Unit_count_pred_flag Excluded_Foreign;
run;
*/

proc freq data=Parcels_Rent_Control;
table ownercat*Exempt_lt5units_Indiv / list missing;  /*only case where not being an individual matters*/
table ownercat*Exempt_built1978 / list missing;
table ownercat*Excluded_nontaxable / list missing;
table ownercat*Excluded_Foreign / list missing;
table ownercat*Exempt_assisted / list missing;
table ownercat*Exempt_govowned / list missing;
*format ownercat $owner.;
run;


/**************************************************
**************************************************
Export rent control data base
**************************************************/;

%fdate( fmt=yymmddd10. )

proc export data=Parcels_Rent_Control outfile="&_dcdata_default_path\DHCD\Raw\Rent_Control_&fdate..csv"
dbms=csv
replace;
run;

