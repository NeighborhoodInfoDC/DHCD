/**************************************************************************
 Program:  NSP_vacant_prop.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/17/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create table of vacant properties for DC NSP2
 neighborhoods.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( RealProp )

proc summary data=DHCD.Vacant_list_may_2009 chartype;
  *where put( geo2000, $nspnbhd. ) ~= '';
  where ui_proptype =: '1';
  class geo2000 ui_proptype;
  output out=Neighborhoods;
  format geo2000 $nspnbhd.;

run;

proc print;
  *where _type_ = '01' or ( _type_ = '11' and put( geo2000, $nspnbhd. ) ~= '' );
run;

%fdate()

options missing='-';
options nodate nonumber;

ods rtf file="D:\DCData\Libraries\DHCD\Prog\NSP_vacant_prop.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=Neighborhoods format=comma12.0 noseps missing;
  where _type_ = '01' or ( _type_ = '11' and put( geo2000, $nspnbhd. ) ~= '' );
  class geo2000 ui_proptype;
  var _freq_;
  table 
    /** Rows **/
    geo2000=' ',
    /** Columns **/
    _freq_='Number of vacant residential properties' * sum=' ' * ( all='Total' ui_proptype='By Type' )
  ;
  format geo2000 $nspnrtf. ui_proptype $newptyb.;
  title1 "Vacant Residential Properties by Type and Neighborhood";
  footnote1 height=9pt "Prepared by NeighborhoodInfo DC (www.NeighborhoodInfoDC.org), &fdate..";
  footnote2 height=9pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';
run;

ods rtf close;
