/**************************************************************************
 Program:  CPMP_2008_needs_tbl3.sas
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
    3 = '>50 to <=80% MFI'
    4, 5 = '>80% MFI';
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
  value raceeth (notsorted)
    2 = 'Non-Hisp. Black'
    1 = 'Non-Hisp. White'
    5 = 'Hispanic/Latino'
    3 = 'Non-Hisp. Asian'
    4 = 'Non-Hisp. Other Race';
run;

%fdate()

ods html body="D:\DCData\Libraries\DHCD\Prog\CPMP_2008_needs_tbl3.xls" style=Minimal;

proc tabulate data=DHCD.CPMP_2008 format=comma12.0 noseps missing;
  where not( missing( hud_inc ) );
  class hud_inc race_eth / preloadfmt order=data;
  var total housing_problems;
  weight hhwt;
  table 
    /** Pages **/
    all='ALL HOUSEHOLDS'
    race_eth=' '
    ,
    /** Rows **/
    all='TOTAL' hud_inc='By Income'
    ,
    /** Columns **/
    total=' ' * sum='Total Households'
    housing_problems=' ' * ( sum='Households With Any Housing Problem' 
                             pctsum<total>='% With Any Housing Problem' * f=comma12.2 )
    / rts=60 box=_page_
  ;
  format hud_inc hudinc. ownershp ownershp. household_type hhtype. race_eth raceeth.;
  title2 "DISPROPORTIANATE NEEDS THRESHOLD BY INCOME, 2008";
  footnote1 "Source: ACS 2008 IPUMS file.";
  footnote2 "Prepared for DC DHCD by NeighborhoodInfo DC (&fdate)"; 

run;

ods html close;
