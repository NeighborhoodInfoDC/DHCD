/**************************************************************************
 Bundle:   t002_nsp_forecl_prop_type
 Source:   Prog/NSP_forecl_prop_type.sas  (NeighborhoodInfoDC/DHCD)
 Original: P. Tatian, NeighborhoodInfo DC, 05/19/09

 Description (verbatim from source): Foreclosures by property type for
 NSP census tracts.

 Adaptation: the original reads HsngMon.Foreclosures_qtr_2009_2 -- an
 external SAS library defined by the DCData macro framework. Here that
 input is supplied as a small inline sample (NSP_input) with the columns
 the program reads: ui_proptype, usecode, report_dt, in_foreclosure_end,
 and geo2000 (an 11-character Census-tract GEOID). The DATA-step recode
 (rental buildings split into < 5 / 5+ apts. by usecode) and the
 PROC TABULATE crosstab are reproduced exactly as written.
**************************************************************************/

** Sample standing in for HsngMon.Foreclosures_qtr_2009_2 **;
data NSP_input;
  length geo2000 $ 11 ui_proptype usecode $ 3;
  input geo2000 $ ui_proptype $ usecode $ in_foreclosure_end report_dt :date9.;
  format report_dt date9.;
  datalines;
11001007503 13 023 1 01jan2009
11001007503 13 016 1 01jan2009
11001007803 10 011 1 01jan2009
11001007901 13 024 1 01jan2009
11001008500 11 012 1 01jan2009
11001008500 13 016 1 01jan2009
11001009904 12 013 1 01jan2009
11001007806 13 016 1 01jan2009
11001007503 10 011 0 01jan2009
11001007803 13 023 1 01jan2009
;
run;

data NSP_forecl_prop_type;

  set NSP_input;

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
