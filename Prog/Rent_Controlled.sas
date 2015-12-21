/**************************************************************************
 Program:  Rent_Controlled.sas
 Library:  ROD
 Project:  DC Foreclosures
 Author:   A. Williams
 Created:  12/03/09
 Version:  SAS 9.1
 Environment:  Windows
 Description:  Creates rent controlled buildings/units database
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

%DCData_lib( Rod )
%DCData_lib( RealProp )
%DCData_lib(MAR)


/*rsubmit;
proc download status = no inlib=work       outlib=work    
memtype=(data);  select  parcel_base;      run; 
proc download data=realprop.parcel_geo out = realprop.parcel_geo;
run;
proc download data=realprop.parcel_base out=test (keep=nbhdname);
run;
endrsubmit;*/



/*Download parcel base file*/

/**************************************************
**************************************************
1. Restrict to Rental units that are not tax exempt 
(Exclude commercial, hotel properties, condos, single-family, coops, etc)
**************************************************/;
data rental_1;
	set realprop.who_owns; *Created by the "Who_owns" program--is Parcel_Base file with added on field for owner categories;
	where ui_proptype = "13" and ssl ne "" and in_last_ownerpt = 1; *Residential: Rental apartment building ;
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
	set rod.Camarespt;
	run;

data camacommpt (keep= ssl ayb);
	length ssl $17;
	set rod.camacommpt;
	run;

proc sort data= camacommpt;	by ssl;	run;
proc sort data= rental_1;	by ssl;	run;
proc sort data= camarespt;	by ssl;	run;

data cama;
set camacommpt camarespt;
by ssl;
run;

proc summary data=cama n;
by ssl;
var _numeric_;
output out=test1 (where=(_freq_>1)) n=;
run;

proc sort data=test1; by ssl;run;
*Double check that none of the duplicate SSLs are in our file;

data test2;
merge rental_1 (in=a) test1 (in=b);
by ssl;
if a=1 and b=1;
run;

proc summary data=cama min;
var ayb;
by ssl;
output out=cama_min min=;
run;

*Merge on AYB;
data rental_2;  * there are A LOT where the ayb=0;
	merge rental_1 (in=a) cama_min  (in=b);
	by ssl;
	if a=1;

	/*2.1 Flag buildings built before 1976*/
	if ayb < 1978 then Exempt_built1978=0; else Exempt_built1978=1; 

	/*2.2 create post 1975 flag*/
	if ayb ge 1976 then AYB_assumption=1;	else AYB_assumption=0;
	if ayb =0 or ayb=. then AYB_missing=1;	else AYB_missing=0;

	run;	

	*Double check for duplicate SSLs;
	proc summary data=rental_2 n;
	by ssl;
	var _numeric_;
	output out=test3 (where=(_freq_>1)) n=;
	run;

	proc freq data=rental_2;
	table ayb_missing / missing;
	run;




/**************************************************
**************************************************
3. Merge on Assisted units--obtained from Peter
	3.1. Exclude properties receiving a federal or district subsidy
**************************************************/;

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

data rental_3;
	merge rental_2 (in=a) assisted (in=b);
	if a;
	by ssl;
	run;

data rental_4;
	set rental_3;
	if subsidized = 1 then Exempt_assisted=1; else Exempt_assisted=0; 
	if subsidized ne 1 then subsidized=0;
	run;



/**************************************************
**************************************************
4. Add on property address, ward, ANC, neighborhood cluster, and census tract
**************************************************/;
proc sort data= realprop.parcel_geo;
by ssl;
run;

proc sort data= rental_4;
by ssl;
run;

data rental_5;
merge rental_4 (in=a) realprop.parcel_geo (in=b keep= ssl ANC2002 Ward2002  Cluster2000  geo2000 Cluster_tr2000 zip) ;
by ssl;
if a=1;
run;



/**************************************************
**************************************************
5. Merge with OCTO's rental unit address database to get unit addresses and counts
**************************************************/;
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


	data parcel_units;
	set mar.parcel_units;
	run;

	proc sort data=parcel_units; by ssl; run;
	proc sort data=rental_5; by ssl; run;

	data rental_6;
	merge rental_5 (in=a) parcel_units (in=b);
	by ssl;
	if a=1;
	run;
	*check duplicates;
		proc summary data=rental_6 (drop= _type_ _freq_) sum;
		by ssl;
		var _numeric_;
		output out=test4 (where=( _freq_>1)) sum=;
		run;
	
	*Check missing;
		data test5;
		set rental_6;
		where unit_count=.;
		run;



/**************************************************
**************************************************
6. Exclude rental units owned by a person who own 4 units or less
	-->Exemption does not apply to those who aren't individuals
**************************************************/;


*Create new dummy variable to indicate if property is greater than 5;
data rental_6_1;
	set rental_6;

	*5 or more units as id'd by Parcel_base;
	if usecode = "025" then units5plus_realprop=1;
	else units5plus_realprop=0;

	if units5plus_realprop=0 and unit_count ge 5 and predicted=1 then adj_unit_count=4; *if codes as less than 5 units and our predicted value says more than 5, then adjust to 4;
	else if units5plus_realprop=1 and unit_count le 5 and predicted=1 then adj_unit_count=5; 
	else adj_unit_count=unit_count;

	if adj_unit_count ge 5  then units5plus_flag=1; else units5plus_flag=0; * assign flag for units greater than 5;

	rename predicted= Unit_count_pred_flag ;

	  length owner_add $ 500;

  *Use standardized owner address where possible;
if owneraddress_std ne "" then OWNER_ADD=owneraddress_std; else OWNER_ADD=owneraddress;

	run;


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


** Reformat owner address into single field
create owner exemption **;
data rental_7;
	set rental_6_4;

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

	 length owner_addr_Full $ 500;
  if address2 = '' then 
    owner_addr_Full = left( trim( address1 ) ) || ', ' || left( address3 );
  else 
    owner_addr_Full = left( trim( address2 ) ) || ', ' || left( trim( address1 ) ) || ', ' || left( address3 );
	if owner_addr_full=" , ," then owner_addr_full="";

	if premiseadd_std ne "" then premiseadd_full= left(trim(premiseadd_std))||", Washington, D.C. "||left(trim(zip));
	else if premiseadd ne "" then premiseadd_full= left(trim(premiseadd))||", Washington, D.C. "||left(trim(zip));

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





/**************************************************
**************************************************
7. Flag government Owners
**************************************************/;

data rental_7_1;
set rental_7;
if ownercat in ("40", "040", "50", "050") then Exempt_govowned=1; else Exempt_govowned=0;
if ownercat="060" then Excluded_Foreign=1; else Excluded_Foreign=0;

*flag if a trust;
Trust1=find(OWNERNAME, "trust", "i");

If trust1>0 then Trust_flag=1; else Trust_flag=0;

run;

proc print data=rental_7_1 obs="100";
where Trust_flag=1;
var ownername;
run;

proc freq data=rental_7_1;
table ownercat*exempt_govowned;
run;

proc print data=rental_7_1;
where ownercat in ("40", "50", "60", "050", "60", "060");
var ownercat ownername;
run;

proc freq data=rental_7_1;
table ownercat;
run;

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

%let vars=/*Address info*/
ssl
	/*Owner info*/
	OWNERNAME
	OWNNAME2
	Ownername_full
	Ownercat
	OwnerDC
	OWNER_ADDR_Full


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
		Unit_count
		Owns5plus_assump_flag
		Units5plus_realprop
		

/*Sale Info*/
SALEDATE
ASSESS_VAL

/*Year built*/
AYB
AYB_assumption
AYB_missing

/*Exemptions and flags*/
Excluded_nontaxable
Exempt_lt5units_Indiv
Exempt_lt5units_ALL
Exempt_built1978
Exempt_assisted
Exempt_govowned
Indiv
Unit_count_pred_flag
Rent_controlled
Receive_Exempt
Trust_flag
Excluded_Foreign
;



data rod.Rent_Control_Database;
set rental_7_1;

*Flag if receives no exemptions or exclusions; 
if Excluded_nontaxable=0
and Excluded_Foreign=0
and Exempt_lt5units_Indiv=0  /*only case where not being an individual matters*/
and Exempt_built1978=0
and Exempt_assisted=0
and Exempt_govowned=0
then Rent_controlled=1; else Rent_controlled=0;

*Flag if receive one or more exemptions--does not take exclusions into account;
if  Exempt_lt5units_ALL=1
or Exempt_built1978=1
or Exempt_assisted=1
or Exempt_govowned=1 then Receive_Exempt=1; else Receive_Exempt=0;


* Delete properties that are not rental props...probably just slipped through;
if adj_Unit_Count=1 and unit_count_pred_flag=0 then delete;

format exempt: exclude: rent_: owns5plus_assump_flag ayb_: unit_count_pred_flag units5plus: Receive_Exempt dyesno.;

keep &vars.;
retain &vars.;
run;



proc freq data=rod.rent_control_database;
table Rent_controlled / nocum;
format Rent_controlled dyesno.;
run;

proc sort data=rod.rent_control_database;
by descending rent_controlled;
run;

proc export data=rod.rent_control_database outfile="D:\DCData\Libraries\ROD\Prog\Rent_Controlled\Rent_Control_12_28_2010.csv"
dbms=csv
replace;
run;


proc freq data=rod.Rent_Control_Database;
table ownercat*Exempt_lt5units_Indiv;  /*only case where not being an individual matters*/
table ownercat*Exempt_built1978;
table ownercat*Excluded_nontaxable;
table ownercat*Excluded_Foreign;
table ownercat*Exempt_assisted;
table ownercat*Exempt_govowned;
run;


