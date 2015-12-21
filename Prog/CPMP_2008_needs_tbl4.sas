/**************************************************************************
 Program:  CPMP_2008_needs_tbl4.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/26/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Produce data for CPMP tool Needs table (Needs.xls) for
DC ConPlan.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( DHCD )

proc format;
  value hudinc
    1 = '<=30% MFI'
    2 = '>30 to <=50% MFI'
    3 = '>50 to <=80% MFI';
  value ownershp (notsorted)
    2 = 'Renter'
    1 = 'Owner';
  value cstbrdn
    0 - 30 = '<= 30%'
    30 <- high = '> 30%';
  value kitchen
    1 = 'Inadeq'
    4 = 'Adeq';
  value plumbing
    10 = 'Inadeq'
    20 = 'Adeq';
  value hhtype
    1 = 'Elderly'
    2 = 'Small related'
    3 = 'Large related'
    4 = 'All other';
  value age
    0 -< 30 = 'Under 30 years'
    30-< 40 = '30-39'
    40-< 50 = '40-49'
    50-< 62 = '50-61'
    62- high = '62+';
  value size
    1 = '1 person'
    2 = '2'
    3-high = '3+';
  value school (notsorted)
    2 = 'Yes'
    1 = 'No';
  value sploc (notsorted)
    1-high = 'Yes'
    0 = 'No';
run;

data tbl4;

  set DHCD.CPMP_2008;
  
run;


%fdate()

ods html body="D:\DCData\Libraries\DHCD\Prog\CPMP_2008_needs_tbl4.xls" style=Minimal;

proc tabulate data=tbl4 format=comma12.0 noseps missing;
  where hud_inc in ( 1, 2, 3 ) and household_type = 4;
  class hud_inc school sploc / preloadfmt order=data;
  class numprec age puma;
  var total housing_problems cost_burden_30 cost_burden_50;
  weight hhwt;
  table 
    /** Pages **/
    all='Total <=80% MFI' hud_inc=' ',
    /** Rows **/
    all='TOTAL' age='Age' School='In school' puma='PUMA'
    ,
    /** Columns **/
    total="'Other' Households" * 
      ( all='Total' numprec='Household size' ) * 
      ( sum='Number' colpctsum='%'*f=comma10.2 )
    / rts=60 box='2008'
  ;
  format hud_inc hudinc. age age. numprec size. school school. sploc sploc.;
  title2 "OTHER HOUSEHOLDS";
  footnote1 "Source: ACS 2008 IPUMS file.";
  footnote2 "Prepared for DC DHCD by NeighborhoodInfo DC (&fdate)"; 

run;

ods html close;

