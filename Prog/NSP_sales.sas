/**************************************************************************
 Program:  NSP_sales.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/24/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create table of sales data for DC NSP2 neighborhoods.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( HsngMon )
%DCData_lib( RealProp )


%Init_macro_vars( rpt_yr=2009, rpt_qtr=2, sales_qtr_offset=-2 )

%let prev_year = %eval( &g_sales_end_yr - 1 );

data Sales_adj (compress=no);

  set HsngMon.Sales_clean_&g_rpt_yr._&g_rpt_qtr 
       (keep=ui_proptype cluster_tr2000 ward2002 geo2000 saledate_yr saleprice_adj);
  
  ** Select single-family homes and condos with non-missing tract or ward IDs **;
  
  where ui_proptype in ( '10', '11' ) and geo2000 ~= '' and Ward2002 ~= '';
  
  city = '1';
  format city $city.;
  
  saleprice_adj = saleprice_adj / 1000;
  
run;

proc summary data=Sales_adj chartype;
  var saleprice_adj;
  class ui_proptype saledate_yr geo2000;
  output out=Neighborhoods median=;
  format geo2000 $nspnbhd.;
run;

proc print;
  *where _type_ = '01' or ( _type_ = '11' and put( geo2000, $nspnbhd. ) ~= '' );
run;

%fdate()

options missing='-';
options nodate nonumber;

ods rtf file="D:\DCData\Libraries\DHCD\Prog\NSP_sales.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=Neighborhoods format=comma12.0 noseps missing;
  where _type_ = '110' or ( _type_ = '111' and put( geo2000, $nspnbhd. ) ~= '' );
  class geo2000 ui_proptype saledate_yr;
  var _freq_ saleprice_adj;
  table 
    /** Pages **/
    ui_proptype=' ',
    /** Rows **/
    geo2000=' ',
    /** Columns **/
    _freq_='Number of Sales' * sum=' ' * ( saledate_yr=' ' )
  ;
  table 
    /** Pages **/
    ui_proptype=' ',
    /** Rows **/
    geo2000=' ',
    /** Columns **/
    saleprice_adj='Median Sales Price (2009 $, thousands)' * median=' ' * ( saledate_yr=' ' )
  ;
  format geo2000 $nspnrtf. ui_proptype $newptyp.;
  title1 "Residential Property Sales by Year and Neighborhood";
  footnote1 height=9pt "Prepared by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
run;

ods rtf close;
