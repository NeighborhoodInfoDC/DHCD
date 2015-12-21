/**************************************************************************
 Program:  NSP_foreclosures.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/24/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create table of foreclosure data for DC NSP2 neighborhoods.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( HsngMon )
%DCData_lib( RealProp )


proc summary data=HsngMon.Foreclosures_year_2009_2 chartype;
  where ui_proptype in ( '10', '11' );
  var in_foreclosure_beg in_foreclosure_end foreclosure_start foreclosure_sale;
  class ui_proptype report_dt geo2000;
  output out=Neighborhoods (where=(_type_ = '110' or ( _type_ = '111' and put( geo2000, $nspnbhd. ) ~= '' ))) sum=;
  format geo2000 $nspnbhd.;
run;

proc print;
  title2 'File = Neighborhoods';

proc summary data=RealProp.Num_units_tr00 chartype;
  var units_sf_: units_condo_: ;
  class geo2000;
  output out=Units (where=(_type_ = '0' or (_type_ = '1' and put( geo2000, $nspnbhd. ) ~= '' ))) sum=;
  format geo2000 $nspnbhd.;
run;

proc print;
  title2 'File = Units';

proc sql noprint;
  create table Neighborhoods_units as
  select * from
    Neighborhoods left join 
    Units
  on put( Neighborhoods.geo2000, $nspnbhd. ) = put( Units.geo2000, $nspnbhd. )
  order by Neighborhoods._type_, Neighborhoods.ui_proptype, Neighborhoods.report_dt, Neighborhoods.geo2000;

proc print;
  title2 'File = Neighborhoods_units';

proc sort data=Neighborhoods;
  by geo2000;

data Neighborhoods_2;

  set Neighborhoods_units;

  if ui_proptype = '10' then do;
  
    select ( year( report_dt ) );
      when ( 1999 ) units = units_sf_1999;
      when ( 2000 ) units = units_sf_2000;
      when ( 2001 ) units = units_sf_2001;
      when ( 2002 ) units = units_sf_2002;
      when ( 2003 ) units = units_sf_2003;
      when ( 2004 ) units = units_sf_2004;
      when ( 2005 ) units = units_sf_2005;
      when ( 2006 ) units = units_sf_2006;
      when ( 2007 ) units = units_sf_2007;
      when ( 2008 ) units = units_sf_2008; 
      otherwise units = units_sf_2008;
    end;
    
  end;
    
  else if ui_proptype = '11' then do;
  
    select ( year( report_dt ) );
      when ( 1999 ) units = units_condo_1999;
      when ( 2000 ) units = units_condo_2000;
      when ( 2001 ) units = units_condo_2001;
      when ( 2002 ) units = units_condo_2002;
      when ( 2003 ) units = units_condo_2003;
      when ( 2004 ) units = units_condo_2004;
      when ( 2005 ) units = units_condo_2005;
      when ( 2006 ) units = units_condo_2006;
      when ( 2007 ) units = units_condo_2007;
      when ( 2008 ) units = units_condo_2008; 
      otherwise units = units_condo_2008;
    end;
    
  end;
    
  in_foreclosure_beg_rate = 1000 * in_foreclosure_beg / units;
  in_foreclosure_end_rate = 1000 * in_foreclosure_end / units;
  foreclosure_start_rate = 1000 * foreclosure_start / units;
  foreclosure_sale_rate = 1000 * foreclosure_sale / units;
  *distressed_sale_rate = 1000 * distressed_sale / units;
  *foreclosure_avoided_rate = 1000 * foreclosure_avoided / units;
  
  label 
    foreclosure_start = 'New foreclosure starts'
    in_foreclosure_end_rate = 'Foreclosure inventory per 1,000 existing units (end of year)'
    foreclosure_start_rate = 'New foreclosure starts per 1,000 existing units'
    foreclosure_sale_rate = 'Foreclosure sales per 1,000 existing units'
  ;
      
  drop units_sf_: units_condo_: ;
  
run;

proc print;
  *where _type_ = '01' or ( _type_ = '11' and put( geo2000, $nspnbhd. ) ~= '' );
  title2 'File = Neighborhoods_2';
run;

%fdate()

options missing='-';
options nodate nonumber;

ods rtf file="D:\DCData\Libraries\DHCD\Prog\NSP_foreclosures.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=Neighborhoods_2 format=comma12.0 noseps missing;
  where _type_ = '110' or ( _type_ = '111' and put( geo2000, $nspnbhd. ) ~= '' );
  class geo2000 ui_proptype report_dt;
  var in_foreclosure_end foreclosure_start foreclosure_sale;
  table 
    /** Pages **/
    ui_proptype=' ',
    /** Rows **/
    geo2000=' ',
    /** Columns **/
    in_foreclosure_end * sum=' ' * ( report_dt=' ' )
  ;
  table 
    /** Pages **/
    ui_proptype=' ',
    /** Rows **/
    geo2000=' ',
    /** Columns **/
    foreclosure_start * sum=' ' * ( report_dt=' ' )
  ;
  table 
    /** Pages **/
    ui_proptype=' ',
    /** Rows **/
    geo2000=' ',
    /** Columns **/
    foreclosure_sale * sum=' ' * ( report_dt=' ' )
  ;
  format geo2000 $nspnrtf. ui_proptype $newptyp. report_dt year4.;
  title1 "Residential Foreclosures by Year and Neighborhood";
  footnote1 height=9pt "Prepared by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
run;

proc tabulate data=Neighborhoods_2 format=comma12.1 noseps missing;
  where _type_ = '110' or ( _type_ = '111' and put( geo2000, $nspnbhd. ) ~= '' );
  class geo2000 ui_proptype report_dt;
  var in_foreclosure_end_rate foreclosure_start_rate foreclosure_sale_rate;
  table 
    /** Pages **/
    ui_proptype=' ',
    /** Rows **/
    geo2000=' ',
    /** Columns **/
    in_foreclosure_end_rate * sum=' ' * ( report_dt=' ' )
  ;
  table 
    /** Pages **/
    ui_proptype=' ',
    /** Rows **/
    geo2000=' ',
    /** Columns **/
    foreclosure_start_rate * sum=' ' * ( report_dt=' ' )
  ;
  table 
    /** Pages **/
    ui_proptype=' ',
    /** Rows **/
    geo2000=' ',
    /** Columns **/
    foreclosure_sale_rate * sum=' ' * ( report_dt=' ' )
  ;
  format geo2000 $nspnrtf. ui_proptype $newptyp. report_dt year4.;
  title1 "Residential Foreclosure Rates by Year and Neighborhood";
  footnote1 height=9pt "Prepared by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
run;

ods rtf close;
