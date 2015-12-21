/**************************************************************************
 Program:  NSP_forecl_prop_type.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/19/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Foreclosures by property type for NSP census tracts.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( HsngMon )
%DCData_lib( RealProp )

data NSP_forecl_prop_type;

  set HsngMon.Foreclosures_qtr_2009_2;

  length new_proptype $ 2;
  
  if ui_proptype = '13' then do;
    if usecode in ( '023', '024' ) then new_proptype = '14';
    else new_proptype = '15';
  end;
  else new_proptype = ui_proptype;
  
run;

proc format;
    value $newptyp
      10 = 'Single-family homes'
      11 = 'Condominium'
      12 = 'Cooperative building'
      14 = 'Rental building (< 5 apts.)'
      15 = 'Rental building (5+ apts.)';
    value $nbrhd
      '11001007503' = 'Anacostia'
      '11001007504' = 'Anacostia'
      '11001007601' = 'Anacostia'
      '11001007803' = 'Deanwood'
      '11001007806' = 'Deanwood'
      '11001007807' = 'Deanwood'
      '11001007808' = 'Deanwood'
      '11001007809' = 'Deanwood'
      '11001009904' = 'Deanwood'
      '11001009905' = 'Deanwood'
      '11001009906' = 'Deanwood'
      '11001007901' = 'Trinidad'
      '11001007903' = 'Trinidad'
      '11001008500' = 'Trinidad'
      '11001008802' = 'Trinidad'
      '11001008803' = 'Trinidad'
      '11001008804' = 'Trinidad'
      '11001008903' = 'Trinidad'
      '11001008904' = 'Trinidad'
      other = ' ';

proc tabulate data=NSP_forecl_prop_type format=comma10.0 noseps missing;
  where report_dt = '01jan2009'd and in_foreclosure_end and
        put( geo2000, $nbrhd. ) ~= '';
  class new_proptype geo2000;
  table 
    /** Rows **/
    all='Total' new_proptype=' ',
    /** Columns **/
    geo2000='Properties in Foreclosure, End of 2009-Q1' * ( n='Properties' colpctn='%'*f=comma10.1 )
  ;
  format new_proptype $newptyp. geo2000 $nbrhd.;

run;
