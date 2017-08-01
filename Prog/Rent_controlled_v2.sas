/**************************************************************************
 Program:  Rent_controlled_v2.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/12/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Compile list of buildings and units potentially
 subject to rent control.

 Version 2

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( RealProp )
%DCData_lib( PresCat )
%DCData_lib( MAR )

/*Download parcel base file*/

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
	     keep=ssl ui_proptype in_last_ownerpt ownerpt_extractdat_first usecode premiseadd);
	by ssl;  
	if b and ui_proptype in ( "10", "11", "13" ) and ssl ne "" and in_last_ownerpt = 1; *Residential: Rental apartment building ;

	** Only keep SF homes and condos if certain that they are rental properties **;
    if ui_proptype in ( "10", "11" ) then do;
	  if owner_occ_sale then delete;
      if ui_proptype = '11' and ( scan( premiseadd_std, 1, '#' ) = scan( owneraddress_std, 1, '#' ) or 
	     trim( owneraddress_std ) =: trim( premiseadd_std ) or
         premiseadd_std = '' or owneraddress_std = '' ) then delete;
	end;

	if MIX2TXTYPE = "TX" or MIX1TXTYPE = "TX" then Excluded_Nontaxable=0; else Excluded_Nontaxable=1;

	run;
					/*proc format;
				value $proptype
				  "10" = "Single-family home"   
				  "11" = "Condominium unit"   
				  "12" = "Cooperative building"     
				  "13" = "Rental apartment building"     
				  "20" = "Retail"     
				  "21" = "Office"     
				  "22" = "Parking garage/lot"     
				  "23" = "Industrial"
				  "24" = "Hotel/motel"    
				  "29" = "Other"
				  "30" = "Group quarters"
				  "40" = "Garage"
				  "50" = "Unimproved land"    
				  "51" = "Vacant With structures"   
				 "99" = "Unknown";
				run; */

/**************************************************
**************************************************
2. Merge on Camarespt file (obtained from Peter Tatian) to get the AYB (Actual year built)
	2.1. Exclude properties that were issued a building permit after Dec. 31, 1975 
		(use 1977 since AYB may be after bilding permit was issued)
		2.1.2. Create flag for properties built after 1975 (1976, 1977) 
**************************************************/;

data Camarespt (keep= ssl ayb);
	length ssl $17;
	set Realprop.camarespt_2014_03;
	run;

data camacommpt (keep= ssl ayb);
	length ssl $17;
	set Realprop.camacommpt_2013_08;
	run;

data Camacondo (keep=ssl ayb);
  length ssl $17;
  set Realprop.camacondopt_2013_08;
  run;

/*
proc sort data= camacommpt;	by ssl;	run;
proc sort data= rental_1;	by ssl;	run;
proc sort data= camarespt;	by ssl;	run;
*/

data cama;
set camacommpt camarespt camacondo;
by ssl;
if ayb < 1800 then ayb = .u;
run;

/*
%Dup_check(
  data=cama,
  by=ssl,
  id=ayb,
  listdups=Y
)
*/

proc summary data=cama n;
by ssl;
var ayb;
output out=test1 (where=(_freq_>1)) 
 min= max= /autoname;
run;

/*
proc sort data=test1; 
  by ssl;
run;
*/

** Double check that none of the duplicate SSLs are in our file **;

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

** Use earliest AYB value for identifying possible rent controlled properties **;
proc summary data=cama min;
var ayb;
by ssl;
output out=cama_min min= /autoname;
run;

*Merge on AYB_min;
data rental_2;  * there are A LOT where the ayb=0;
	merge rental_1 (in=a) cama_min  (in=b);
	by ssl;
	if a=1;

	/*2.1 Flag buildings built before 1978*/
	if ayb_min < 1978 then Exempt_built1978=0; else Exempt_built1978=1; 

	/*2.2 create post 1975 flag*/
	if ayb_min ge 1976 then AYB_assumption=1;	else AYB_assumption=0;
	if ayb_min =0 or missing(ayb_min) then AYB_missing=1;	else AYB_missing=0;

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

/*
	*Double check for duplicate SSLs;
	proc summary data=rental_2 n;
	by ssl;
	var _numeric_;
	output out=test3 (where=(_freq_>1)) n=;
	run;

	proc freq data=rental_2;
	table ayb_missing / missing;
	run;
*/



/**************************************************
**************************************************
3. Merge on Assisted units
	3.1. Exclude properties receiving a federal or district subsidy
**************************************************/;

/*
proc format;
value progcat
 
   1 = 'Public Housing only'
    2 = 'Section 8 only'
    9 = 'Section 8 and other subsidies'
    3 = 'LIHTC only'
    8 = 'LIHTC and Tax Exempt Bond only'
    4 = 'HOME only'
    5 = 'CDBG only'
    6 = 'HPTF only'
    7, 10 = 'All other combinations';
	run;
proc sort data=rod.assisted_units;
by ssl;
run;

proc summary data=rod.Assisted_units n;
by ssl;
var _Numeric_;
where ssl ne "";
output out=assisted_units (keep= ssl _Freq_) n=;
run;


data Assisted(keep= ssl subsidized);
	set Assisted_units;
	subsidized= 1;
	run;

proc sort data=assisted;
	by ssl; run;

	*Check for duplcate ssls;
	proc summary data=assisted n;
	var _numeric_;
	by ssl;
	output out=Assis_Dup_check n=;
	run;

	proc print data=assis_Dup_check;
	where _Freq_>1;
	run;
*/

proc sort data=PresCat.Parcel_subsidy out=Parcel_subsidy;
  by ssl;

%Dup_check(
  data=Parcel_subsidy,
  by=ssl,
  id=nlihc_id,
  listdups=Y
)


data rental_3;
	merge 
	  rental_2 (in=a) 
	  PresCat.Parcel_subsidy (keep=ssl Sub_all_proj);
	by ssl;

	if a;

	if Sub_all_proj > 0 then Exempt_assisted=1; else Exempt_assisted=0; 
	
	run;

%File_info( data=rental_3, printobs=0, contents=n )

/**** PT: SKIP THIS STEP - NO LONGER NEEDED
data rental_4;
	set rental_3;
	if subsidized = 1 then Exempt_assisted=1; else Exempt_assisted=0; 
	if subsidized ne 1 then subsidized=0;
	run;
*/


/**************************************************
**************************************************
4. Add on property address, ward, ANC, neighborhood cluster, and census tract
**************************************************/;
/*
proc sort data= realprop.parcel_geo;
by ssl;
run;

proc sort data= rental_4;
by ssl;
run;
*/

data rental_5;
merge 
  rental_3 (in=a) 
  realprop.parcel_geo (keep=ssl anc2002 ANC2012 Ward2002 Ward2012  Cluster2000  geo2000 geo2010 Cluster_tr2000 zip);
by ssl;
if a=1;
run;

%File_info( data=rental_5, contents=n, stats=, printobs=0, freqvars=ward2012 cluster_tr2000 )

/**************************************************
**************************************************
5. Merge with OCTO's rental unit address database to get unit addresses and counts
**************************************************/;
/*
proc format;
value unit
.="Missing"
0="\~0"
1="\~1"
2="\~2"
3-5="\~3-5"
6-10="\~6-10"
11-50="\~11-50"
50-100="\~50-100"
101-700="\~101-700"
701-high="\~700 or above";
run;
*/

/*
	data parcel_units;
	set mar.parcel_units;
	run;

	proc sort data=parcel_units; by ssl; run;
	proc sort data=rental_5; by ssl; run;
*/

	data rental_6;
	merge 
	  rental_5 (in=a) 
	  /*RealProp.Parcel_rental_units (in=b drop=ui_proptype)*/
	  Dhcd.Units_regression (keep=ssl units_mar units_full);
	by ssl;
	if a=1;
    if units_mar > 0 then do;
	  ** Unit count reported in MAR **;
	  predicted = 0;
	  units_full = units_mar;
	end;
	else if units_full > 0 then do;
	  ** Unit count estimated from MAR using regression **;
	  predicted = 1;
	end;
	else if ui_proptype in ( '10', '11' ) then do;
	  ** Single family homes and condo units **;
	  units_full = 1;
	  predicted = 0;
	end;
	else if ui_proptype = '13' and usecode in ( '023', '024' ) then do;
	  ** Rented townhomes/assume unit count = 1 **;
	  units_full = 1;
	  predicted = 1;
	end;
	run;

	*check duplicates;
	%Dup_check(
	  data=rental_6,
	  by=ssl,
	  id=ayb_min ui_proptype,
	  listdups=Y
	)
/*
		proc summary data=rental_6 (drop= _type_ _freq_) sum;
		by ssl;
		var _numeric_;
		output out=test4 (where=( _freq_>1)) sum=;
		run;
*/	
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

/*
proc format;
value $owner
'010'='Individuals (natural persons)'
'020'='Individuals (natural persons)'
'030'='Individuals (natural persons)'
'040' = 'DC government'
'050' = 'US government'
'060' = 'Foreign governments'
'070' = 'Quasi-public entities'
'080' = 'Community development corporations/organizations'
'090' = 'Private universities, colleges, schools'
'100' = 'Churches, synagogues, religious'
'110' = 'Corporations, partnership, LLCs, LLPs, associations'
'111' = 'Nontaxable corporations, partnerships, associations'
'115' = 'Taxable corporations, partnerships, associations'
'120' = 'Government-Sponsored Enterprise'
'130' = 'Banks, Lending, Mortgage and Servicing Companies';
run;
*/

*Create new dummy variable to indicate if property is greater than 5;
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

	run;

/*
proc means data= rental_6 sum;
var Unit_count;
where ssl ne "";
run;
*/

/*
proc sql noprint;
  create table rental_6_1_owner_add_sum (where=(owner_add_count > 1)) as
  select 
    owner_add, 
    count( owner_add ) as owner_add_count, 
    sum( adj_unit_count ) as adj_unit_count_owner_add_sum 
  from rental_6_1
  where owner_add ne ""
  group by owner_add;
quit;
*/

proc sql noprint;
  create table rental_6_2 as
  select rental_6_1.*, Owner_add_sum.*
  from rental_6_1 left join
  ( select 
    owner_add, 
    count( owner_add ) as owner_add_count, 
    sum( adj_unit_count ) as adj_unit_count_owner_add_sum 
  from rental_6_1
  where owner_add ne ""
  group by owner_add ) as Owner_add_sum
  on Owner_add_sum.owner_add = rental_6_1.owner_add
;
quit;

/*
proc sql noprint;
  create table rental_6_1_ownername_sum (where=(ownername_count > 1)) as
  select 
    ownername_full, 
    count( ownername_full ) as Ownername_count, 
    sum( adj_unit_count ) as adj_unit_count_ownername_sum 
  from rental_6_1
  where ownername_full ne ""
  group by ownername_full;
quit;
*/

proc sql noprint;
  create table rental_6_3 as
  select rental_6_2.*, Ownername_sum.*
  from rental_6_2 left join
  ( select 
    ownername_full, 
    count( ownername_full ) as Ownername_count, 
    sum( adj_unit_count ) as adj_unit_count_ownername_sum 
  from rental_6_1
  where ownername_full ne ""
  group by ownername_full ) as Ownername_sum
  on Ownername_sum.ownername_full = rental_6_2.ownername_full
;
quit;

/*
proc sort data= rental_6_1;
	by OWNER_ADD;
	run;

*For smaller properties, we need to summarize by owner to see if they own more than 4;


proc summary data=rental_6_1 sum nway;
by OWNER_ADD;
var adj_unit_count;
*where usecode in ("023" "024");
where owner_add ne "";
output out= rental_6_2 (keep=_freq_ OWNER_ADD owner_units  ) sum=owner_units /autoname;
run;

proc sort data=rental_6_2 out=test6;
by descending owner_units ;
run;

data rental_6_3 (keep= owner_add owner_units  owns5plus_assump_flag);
set rental_6_2;
if owner_units  ge 5 then owns5plus_assump_flag=1;
*assign units5=1 to only properties were the owner owns 5 or more properties;
run;

proc sort data=rental_6_3;
by OWNER_ADD;
run;

*Merge small property list back on to bigger one so that we have the updated values for the units5 variable;
data rental_6_4;
merge rental_6_1 (in=a) rental_6_3(in=b);
by OWNER_ADD;
if owns5plus_assump_flag=. then owns5plus_assump_flag=0;
if a;
run;
*/

** Create owner exemption flags **;
data rental_7;
	set rental_6_3;

	** Owns 5 or more units **;
	if adj_unit_count_owner_add_sum ge 5 or adj_unit_count_ownername_sum ge 5 then 
	owns5plus_assump_flag = 1;
	else owns5plus_assump_flag = 0;

	*Create exemption code for ALL that have lt 5 units, regardless of owner type;
	if units5plus_flag=1 or owns5plus_assump_flag=1 then Exempt_lt5units_ALL=0; else Exempt_lt5units_ALL=1;

	*Exemption does not apply to non individuals;
	if ownercat in ("010", "020", "030", "10", "20", "30") then Indiv=1; 
		else Indiv=0;

	* Create final flag for those who are not individuals and have lt 5 units;
	if Indiv=0 and Exempt_lt5units_ALL=1 then Exempt_lt5units_Indiv=0;
	else if Indiv=1 and Exempt_lt5units_ALL=1 then Exempt_lt5units_Indiv=1;
	else exempt_lt5units_indiv=0;

	 /* if owneraddress_std ne " " then OWNER_ADD=owneraddress_std; 
	else if owneraddress_std=" " and address2 = " " then 
    owner_add= left( trim( address1 ) ) || ', ' || left( address3 );
  else
    owner_add = left( trim( address2 ) ) || ', ' || left( trim( address1 ) ) || ', ' || left( address3 );
	if owner_add= " , ," then owner_add=" ";	*/

	/*
	 length owner_addr_Full $ 500;
  if address2 = '' then 
    owner_addr_Full = left( trim( address1 ) ) || ', ' || left( address3 );
  else 
    owner_addr_Full = left( trim( address2 ) ) || ', ' || left( trim( address1 ) ) || ', ' || left( address3 );
	if owner_addr_full=" , ," then owner_addr_full="";

	if premiseadd_std ne "" then premiseadd_full= left(trim(premiseadd_std))||", Washington, D.C. "||left(trim(zip));
	else if premiseadd ne "" then premiseadd_full= left(trim(premiseadd))||", Washington, D.C. "||left(trim(zip));
*/

* Create var for DC owners--pulled from foreclosure_history code;
	length OwnerDC 3;

  if address3 ~= '' then do;
  	if indexw( address3, 'DC' ) then OwnerDC=1;
  	else OwnerDC= 0;
 	 end;
 	 else OwnerDC = 9;
** Assume OwnerDC=1 for government & quasi-gov. owners **;
  
  if OwnerCat in ( '040', '050', '060', '070' ) then OwnerDC = 1;
  label OwnerDC = 'DC-based owner';

				run;

%File_info( data=rental_7, printobs=0, contents=n )

proc freq data=rental_7;
  tables Indiv * Exempt_lt5units_ALL * Exempt_lt5units_Indiv / list missing;
  title2 'File = rental_7';
run;
title2;

/*
proc means data= rental_7 sum;
var adj_Unit_count;
where ssl ne "";
run;
*/

/**************************************************
**************************************************
7. Flag government Owners
**************************************************/;

data rental_7_1;
set rental_7;
if ownercat in ("40", "040", "50", "050") then Exempt_govowned=1; else Exempt_govowned=0;
if ownercat="060" then Excluded_Foreign=1; else Excluded_Foreign=0;

*flag if a trust;
Trust1=find(OWNERNAME_full, "trust", "i");

If trust1>0 then Trust_flag=1; else Trust_flag=0;

run;

/*
proc print data=rental_7_1 obs="100";
where Trust_flag=1;
id ssl;
var ownercat ownername_full;
format ownercat ;
run;
*/
/*
proc freq data=rental_7_1;
table ownercat*exempt_govowned /list missing nocum;
run;

proc print data=rental_7_1;
where ownercat in ("40", "50", "60", "050", "60", "060");
var ownercat ownername_full;
run;

proc freq data=rental_7_1;
table ownercat;
run;
*/

/*Owner type codes	
10	Single-family owner-occupied
20	Multifamily owner-occupied
30	Other individuals
40	DC government
50	US government
60	Foreign governments
70	Quasi-public entities
80	Community development corporations/organizations
90	Universities, colleges, schools
100	Churches, synagogues, temples
110	Corporations, partnership, LLCs, LLPs, associations
111	Nontaxable corporations, partnerships, associations'
115	Taxable corporations, partnerships, associations
120	Government-Sponsored Enterprise
130	Banks, Lending, Mortgage and Servicing Companies
*/
data test7;
set rental_7_1;
where adj_Unit_Count=1 and unit_count_pred_flag=0 ;
run;

/*
proc sort data=rental_7_1; by ssl; run;


proc means data= rental_7_1 sum;
var adj_Unit_count;
where ssl ne "";
run;
*/

/**************************************************
**************************************************
Add on owner_occ_sale_flag			
**************************************************/;
/*
rsubmit;
proc download data=realprop.sales_master out=realprop.sales_master;
run;
endrsubmit;
*/
/*
Data Sales_master;
  Set Realprop.Sales_master (keep=ssl sale_num owner_occ_sale);
  By ssl sale_num;
  If last.ssl;  ** Only keep the last obs. for each SSL **;
Run;

data rental_8 no_sale;
merge rental_7_1 (in=a) sales_master (in=b);
by ssl;
if a then output rental_8;
if a=1 and b=0 then output no_sale;
run;


proc means data= rental_8 sum;
var adj_Unit_count;
where ssl ne "";
run;
*/

/**************************************************
**************************************************
Create flags and final file
**************************************************/;
%let vars=/*Address info*/
ssl
	/*Owner info*/
	OWNERNAME
	OWNNAME2
	Ownername_full
	Ownercat
	OwnerDC
	OWNER_ADDR_Full
	owner_occ_sale

Premiseadd_Full
Zip
ANC2002
Ward2002
Cluster2000
Geo2000
Cluster_tr2000
Zip
X_COORD
Y_COORD

/*tax type*/
MIX2TXTYPE
MIX1TXTYPE

/*Property Characteristics*/
Usecode
Ui_proptype
LANDAREA
MIXEDUSE

	/*units*/
		Units5plus_Flag 
		Adj_Unit_count
		owner_units /*num units owned by owner*/
		Owns5plus_assump_flag
		Units5plus_realprop
		

/*Sale Info*/
SALEDATE
ASSESS_VAL

/*Year built*/
AYB_min
AYB_assumption
AYB_missing

/*Exemptions and flags*/
Excluded_nontaxable
Exempt_lt5units_Indiv
Exempt_built1978
Exempt_assisted
Exempt_govowned
Exempt_lt5units_ALL

Indiv
Unit_count_pred_flag
Rent_controlled
Receive_Exempt
Trust_flag
Excluded_Foreign
;

proc format;
value ayb
0="Unknown";
run;

proc sort data=rental_7_1;
  by ssl;
run;

proc sort data=DHCD.rent_control_database_041511 out=rent_control_database_041511;
  by ssl;
run;

data dhcd.Parcels_Rent_Control;
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
or Exempt_govowned=1 then Receive_Exempt=1; else Receive_Exempt=0;


* Delete properties that are not rental props...probably just slipped through;
****if adj_Unit_Count=1 and unit_count_pred_flag=0 and rent_controlled=0 then delete;

/*
format exempt: indiv owner_occ_sale Trust_flag ownerdc exclude: rent_: owns5plus_assump_flag ayb_: unit_count_pred_flag units5plus: Receive_Exempt dyesno. 
ayb ayb.
Ownercat $OWNCAT.
;

keep &vars.;
retain &vars.;
*/

format Rent_controlled dyesno.;

drop _type_ _freq_;

run;

%Dup_check(
  data=dhcd.Parcels_Rent_Control,
  by=ssl,
  id=premiseadd,
  listdups=Y
)

%File_info( data=dhcd.Parcels_Rent_Control, freqvars=Rent_controlled Rent_controlled_2011 )

proc freq data=dhcd.Parcels_Rent_Control;
  tables Rent_controlled * Rent_controlled_2011 / list missing;
run;

data test8;

  set dhcd.Parcels_Rent_Control;
  where Rent_controlled and Rent_controlled_2011 in ( 0, .n );

run;

** Compare conflicting results from 2011 analysis **;

proc compare maxprint=(40,32000) out=compare1 outnoequal outbase outcomp outdif noprint
    base=rent_control_database_041511 
	  (where=(not Rent_controlled))
    compare=dhcd.Parcels_Rent_Control 
      (where=(Rent_controlled and Rent_controlled_2011 = 0));
  id ssl;
  var Rent_controlled exempt_: Indiv Unit_count_pred_flag Receive_Exempt Excluded_Foreign;
run;


/*
proc means data= dhcd.Rent_Control_Database sum;
var Adj_Unit_count;
where ssl ne "";
run;

proc summary data=dhcd.rent_control_database sum;
var adj_unit_count;
where ssl ne "";
output out=test sum= / autoname;
run;

proc freq data=dhcd.rent_control_database;
table Rent_controlled / nocum;
format Rent_controlled dyesno.;
run;

proc sort data=dhcd.rent_control_database;
by descending rent_controlled;
run;

data csv_RC;
set dhcd.rent_control_database;
drop Exempt_lt5units_ALL;
run;
*/
%fdate( fmt=yymmddd10. )

proc export data=dhcd.Parcels_Rent_Control outfile="D:\DCData\Libraries\DHCD\Raw\Rent_Control_&fdate..csv"
dbms=csv
replace;
run;


proc freq data=dhcd.Parcels_Rent_Control;
table ownercat*Exempt_lt5units_Indiv / list missing;  /*only case where not being an individual matters*/
table ownercat*Exempt_built1978 / list missing;
table ownercat*Excluded_nontaxable / list missing;
table ownercat*Excluded_Foreign / list missing;
table ownercat*Exempt_assisted / list missing;
table ownercat*Exempt_govowned / list missing;
*format ownercat $owner.;
run;


/*
data Parcel_compare;

  merge
    Parcel_rent_control_2_24_2011 (in=inA)
	dhcd.Parcels_Rent_Control (in=inB);
  by ssl;

  in_old = inA;
  in_new = Rent_controlled;

run;

proc freq data=Parcel_compare;
  tables in_old * in_new / list missing;
run;

proc print data=Parcel_compare (obs=50);
  where in_old and not in_new;
  id ssl;
  var 
Excluded_nontaxable
Exempt_lt5units_Indiv
Exempt_built1978
Exempt_assisted
Exempt_govowned
Exempt_lt5units_ALL

Indiv
Unit_count_pred_flag
Rent_controlled
Receive_Exempt
Trust_flag
Excluded_Foreign;
run;
