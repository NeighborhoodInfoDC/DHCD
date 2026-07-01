/**************************************************************************
 Bundle:   t003_rc_descriptive_tab
 Source:   Prog/RC_Descriptive_tables.sas  (NeighborhoodInfoDC/DHCD)
 Original: A. Williams, DC Rent Control Properties, 12/27/09

 Description (from source): Creates tables based on the rent control
 database. This bundle reproduces the "By ward" table -- rent-controlled
 properties and units cross-classified by 2002 ward -- with the four
 statistic columns the source defines: number of properties (N),
 percent of properties (PCTN), number of units (SUM of adj_unit_count),
 and percent of units (PCTSUM).

 Adaptation: the original reads DHCD.rent_control_database from an
 external SAS library (DCData framework). Here that input is supplied as
 a small inline sample with ward2002, rent_controlled, and adj_unit_count.
 The PROC SORT, the $ward. PROC FORMAT, and the PROC TABULATE TABLE
 specification (including the WHERE on rent_controlled) are reproduced
 exactly as written in the source.
**************************************************************************/

** Sample standing in for DHCD.rent_control_database **;
data rent_control_database;
  length ward2002 $ 1;
  input ward2002 $ rent_controlled adj_unit_count;
  datalines;
1 1 12
1 1 8
2 1 30
3 0 5
4 1 16
4 1 6
5 1 22
5 1 14
6 1 40
7 1 3
8 1 9
8 1 11
1 0 7
6 1 18
;
run;

proc sort data=rent_control_database;
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

proc tabulate data=rent_control_database missing format=comma12.0;
class rent_controlled ward2002;
var adj_unit_count ;
table (ALL="Total Rent Controlled") Ward2002="Ward"  ,
	(ALL="Number of properties")*N=""
	(ALL="Pct. properties")*(PCTN="")*f=comma12.1
	(adj_unit_count="Number of units")*SUM=""
	(adj_unit_count="Pct. units")*(pctsum="")*f=comma12.1 ;
where rent_controlled=1;
format ward2002 $ward.;
title 'Rent Controlled Properties by Ward';
footnote1 "Note: The figures in these tables are based on a preliminary enumeration of rent-controlled housing in the District of Columbia.";
run;
