/**************************************************************************
 Program:  CPMP_2008_needs_tbl.sas
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
run;

%fdate()

ods html body="D:\DCData\Libraries\DHCD\Prog\CPMP_2008_needs_tbl.xls" style=Minimal;

proc tabulate data=DHCD.CPMP_2008 format=comma12.0 noseps missing;
  where hud_inc in ( 1, 2, 3 );
  class hud_inc ownershp household_type / preloadfmt order=data;
  var total housing_problems cost_burden_30 cost_burden_50;
  weight hhwt;
  table 
    /** Rows **/
    ( hud_inc='Income' all='TOTAL <=80% MFI' ) * ownershp='Tenure' * household_type='Type' * 
      ( total='Number of households'
        housing_problems='Any housing problems'
        cost_burden_30='Cost burden > 30%'
        cost_burden_50='Cost burden > 50%' ),
    /** Columns **/
    pctsum<total>='Current %'*f=comma10.2 sum='Current Number' n='Sample obs.'
    / rts=60 box="Households, 2008"
  ;
  format hud_inc hudinc. ownershp ownershp. household_type hhtype.;
  title2 "HOUSING NEEDS TABLE";
  footnote1 "Source: ACS 2008 IPUMS file.";
  footnote2 "Prepared for DC DHCD by NeighborhoodInfo DC (&fdate)"; 

run;

ods html close;
