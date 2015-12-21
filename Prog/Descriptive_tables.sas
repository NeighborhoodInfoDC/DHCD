/**************************************************************************
 Program:  Descriptive_tables.sas
 Library:  ROD
 Project:  DC Rent Control Properties
 Author:   A. Williams
 Created:  12/27/09
 Version:  SAS 9.1
 Environment:  Windows
 Description:  Creates tables based on rent control database
 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

%DCData_lib( Rod )


proc template;
      define style MyStyle_1; 
             parent=styles.journal;
      end;
    run;

ods rtf file="D:\dcdata\libraries\ROD\Prog\Rent_Controlled\Rent_Control_1_20_10.doc" style=mystyle_1 ;

/**************************************************
**************************************************
Table 1
**************************************************/;

proc tabulate data=rod.rent_control_database missing format=comma12.0 ;
class excluded_nontaxable Exempt_built1978 Exempt_lt5units_indiv Exempt_assisted Exempt_govowned
		AYB_assumption Exempt_lt5units_ALL Receive_Exempt Rent_controlled;
var adj_unit_count ;
table 
	ALL="Total Rental Properties"
	excluded_Nontaxable='Excluded: Nontaxable' 
	Exempt_built1978="Built 1978 or later" 
	AYB_assumption="Built 1976-77*" 
	Exempt_lt5units_ALL="Owns fewer than 5 units**"
	Exempt_assisted="Publicly assisted" 
	Exempt_govowned ="Government owned" 
	Receive_Exempt="With 1 or more exemptions" 
	Rent_Controlled="Total without exclusion or exemption (subject to rent control)" 
	, (ALL="Number of Properties")*(N="") (adj_unit_count="Number of Units")*(SUM="") ;
   title 'Properties/Units Excluded Nontaxable';
   footnote1 "Notes:";
   footnote2 "*Properties built 1976-77 are included in the database as possibly subject to rent control. See report for details.";
   footnote3 "**Exemption only applies to properties owned by individuals (natural persons).";
run;


*/**************************************************
**************************************************
Table(s) 2
Create tables showing the numbers of rent-controlled properties/units by property characteristics. 
Same columns for each table:  Number of properties, Pct. properties, Number of units, Pct. units.  
Table rows always start with "Total rent control" and characteristics are below. Show "missing" as a 
separate category, where applicable, on the last row.
 
a) By ward
b) By year built
c) By number of units in property (1-4, 5-10, etc.)

**************************************************/;
*Ward;
	proc sort data=rod.rent_control_database;
	by ward2002;
	run;

	proc format;
	value $ward
	"1"= "  Ward 1"
	"2"= "  Ward 2"
	"3"= "  Ward 3"
	"4"= "  Ward 4"
	"5"= "  Ward 5"
	"6"= "  Ward 6"
	"7"= "  Ward 7"
	"8"= "  Ward 8"
	" "="  Missing";
	run;

	proc tabulate data=rod.rent_control_database missing format=comma12.0;
	class rent_controlled ward2002;
	var adj_unit_count ;
	table (ALL="Total Rent Controlled") Ward2002="Ward"  , (ALL="Number of properties")*N="" (ALL="Pct. properties")*(PCTN="")*f=comma12.1 
	(adj_unit_count="Number of units")*SUM="" (adj_unit_count="Pct. units")*(pctsum="")*f=comma12.1 ;
	where rent_controlled=1;
	format ward2002 $ward.;
	title 'Rent Controlled Properties by Ward';
	footnote1 "Note: The figures in these tables are based on a preliminary enumeration of rent-controlled housing in the District of Columbia.";
	run;

*AYB;
	proc format;
	value AYB
	. = "  Missing"
	low-1899="  before 1900"
	1900-1919="  1900-1919"
	1920-1949="  1920-1949"
	1950-high="  1950 or later";
	run;

	proc tabulate data=rod.rent_control_database missing format=comma12.0 ;
	class rent_controlled ayb;
	var adj_unit_count ;
	table (ALL="Total Rent Controlled") ayb="Actual Year Built"  , (ALL="Number of properties")*N="" (ALL="Pct. properties")*(PCTN="")*f=comma12.1 
	(adj_unit_count="Number of units")*SUM="" (adj_unit_count="Pct. units")*(pctsum="")*f=comma12.1 ;
	where rent_controlled=1;
	format ayb ayb.;
	title 'Rent Controlled Properties by Actual Year Built';
	footnote1 "Note: The figures in these tables are based on a preliminary enumeration of rent-controlled housing in the District of Columbia.";
	run;

*Unit count;
	proc format;
	value unit
	.="Missing"
	0="  0"
	1="  1"
	2="  2"
	3-5="  3-5"
	6-10="  6-10"
	11-50="  11-50"
	51-100="  51-100"
	101-high="  Above 100";
	run;

	data rent_control_database_UNITS;
	set rod.rent_control_database;
	dup_adj_unit_count= adj_unit_count;
	run;

	proc tabulate data=rent_control_database_UNITS missing format=comma12.0 ;
	class rent_controlled dup_adj_unit_count;
	var adj_unit_count;
	table (ALL="Total Rent Controlled") dup_adj_unit_count="Number of Units in Property"  , (ALL="Number of properties")*N="" (ALL="Pct. properties")*(PCTN="")*f=comma12.1 
	(adj_unit_count="Number of units")*SUM="" (adj_unit_count="Pct. units")*(pctsum="")*f=comma12.1 ;
	where rent_controlled=1;
	format dup_adj_unit_count unit.;
	title 'Rent Controlled Properties by Number of Units in Property ';
	footnote1 "Note: The figures in these tables are based on a preliminary enumeration of rent-controlled housing in the District of Columbia.";
	run;

/**************************************************
**************************************************
3. Create tables showing the numbers of rent-controlled properties/units 
by owner characteristics. Same format as 2).
 
a) By owner type
b) By DC vs. non-DC owner
c) By number of units owned by same owner (that is, number of properties owned by owners with < 10 units, etc.) 
 
**************************************************/;

* Ownertype;
	proc tabulate data=rod.rent_control_database missing format=comma12.0 ;
	class rent_controlled ownercat;
	var adj_unit_count ;
	table (ALL="Total Rent Controlled") ownercat="Owner Category"  , (ALL="Number of properties")*N="" (ALL="Pct. properties")*(PCTN="")*f=comma12.1 
	(adj_unit_count="Number of units")*SUM="" (adj_unit_count="Pct. units")*(pctsum="")*f=comma12.1 ;
	where rent_controlled=1;
	format ownercat $OWNCAT.;
	title 'Rent Controlled Properties by Owner Type';
	footnote1 "Note: The figures in these tables are based on a preliminary enumeration of rent-controlled housing in the District of Columbia.";
	run;



* DC owner;
	proc tabulate data=rod.rent_control_database missing format=comma12.0 ;
	class rent_controlled ownerdc;
	var adj_unit_count ;
	table (ALL="Total Rent Controlled") ownerdc="DC Owner"  , (ALL="Number of properties")*N="" (ALL="Pct. properties")*(PCTN="")*f=comma12.1 
	(adj_unit_count="Number of units")*SUM="" (adj_unit_count="Pct. units")*(pctsum="")*f=comma12.1 ;
	where rent_controlled=1;
	format ownerdc yesno.;
	title 'Rent Controlled Properties by D.C. Owner vs. non-D.C. Owner';
	footnote1 "Note: The figures in these tables are based on a preliminary enumeration of rent-controlled housing in the District of Columbia.";
	run;


*Units by same owner;
	proc tabulate data=rod.rent_control_database missing format=comma12.0 ;
	class rent_controlled owner_units;
	var adj_unit_count ;
	table (ALL="Total Rent Controlled") owner_units="Units Owned by Owner"  , (ALL="Number of properties")*N="" (ALL="Pct. properties")*(PCTN="")*f=comma12.1 
	(adj_unit_count="Number of units")*SUM="" (adj_unit_count="Pct. units")*(pctsum="")*f=comma12.1 ;
	where rent_controlled=1;
	format owner_units unit.;
	title 'Rent Controlled Properties by Number of Units Owned by Same Owner';
	footnote1 "Note: The figures in these tables are based on a preliminary enumeration of rent-controlled housing in the District of Columbia.";
	run;

/**************************************************
**************************************************
4. Produce a frequency of the numbers of properties 
	and units owned by trusts with fewer than 5 units total.  
**************************************************/;

* Trusts;
	proc tabulate data=rod.rent_control_database missing format=comma12.0 ;
	class rent_controlled Trust_flag;
	var adj_unit_count ;
	table Trust_flag="Owned by a Trust"  , (ALL="Number of properties")*N="" (ALL="Pct. properties")*(PCTN="")*f=comma12.1 
	(adj_unit_count="Number of units")*SUM="" (adj_unit_count="Pct. units")*(pctsum="")*f=comma12.1 ;
	where Exempt_lt5units_ALL=1;
	format Trust_flag yesno.;
	title 'Trustee owners who own less than five units';
	footnote1 "Note: The figures in these tables are based on a preliminary enumeration of rent-controlled housing in the District of Columbia.";
	run;


/**************************************************
**************************************************
Ward Tables
4) For appendix A, individual ward tables.  
A separate set of tables for each ward showing characteristics 2) and 3) 
above, same columns as above. 
**************************************************/;

proc format;
	value ownunit
	.="Missing"
	0="  0"
	1="  1"
	2="  2"
	3-5="  3-5"
	6-10="  6-10"
	11-50="  11-50"
	51-100="  51-100"
	101-700="  101-700"
	701-high="  Above 700";
	run;

proc sort data=rent_control_database_units;
	by ward2002;
	run;

%macro wards;
%do i=1 %to 8;
proc tabulate data=rent_control_database_UNITS missing format=comma12.0;
	class rent_controlled ward2002 AYB  owner_units  ownercat ownerDC dup_adj_unit_count;
	var adj_unit_count;
	table 
		ALL="Total Rent Controlled"
		AYB = "Actual Year Built"
		owner_units  = "Number of units owned by same owner"
		ownercat="Owner Type"
		ownerDC="DC Owner"
		dup_adj_unit_count="Number of Units in Property"
		,
	(ALL="Number of properties")*N="" (ALL="Pct. properties")*PCTN=""*f=comma12.1 
	(adj_unit_count="Number of units")*SUM="" (adj_unit_count="Pct. units")*(pctsum="")*f=comma12.1 / Box ="Ward &i." ; 
		where rent_controlled=1 and ward2002="&i.";
		format owner_units ownunit. ownerdc yesno. ownercat $OWNCAT. dup_adj_unit_count unit. ayb ayb. ward2002 $ward.;
		by ward2002;
		title "Rent Controlled Property Characteristics, Ward &i.";
		footnote1 "Note: The figures in these tables are based on a preliminary enumeration of rent-controlled housing in the District of Columbia.";
		run;
	%end;
%mend wards;

%wards;

ods rtf close;


