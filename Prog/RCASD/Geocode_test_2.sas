/**************************************************************************
 Program:  Geocode_test_2.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/22/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( MAR )

%DC_geocode(
  data = DHCD.Rcasd_2015_000,
  staddr = address,
  zip = ,
  out = Rcasd_2015_000_geo,
  geo_match = Y,
  debug = Y,
  mprint = Y
)

proc print data=Rcasd_2015_000_geo n='TOTAL MATCHED = ';
  where _score_ >= 45 and scan( address, 1, ' ' ) = scan( m_addr, 1, ' ' );
  id nidc_id Addr_num;
  var address m_addr _matched_ _score_ address_id ssl;
  title2 'MATCHED ADDRESSES';
run;

proc print data=Rcasd_2015_000_geo n='TOTAL UNMATCHED = ';
  where not( _score_ >= 45 and scan( address, 1, ' ' ) = scan( m_addr, 1, ' ' ) );
  id nidc_id Addr_num;
  var orig_address address m_addr _score_  _notes_;
  title2 'UNMATCHED ADDRESSES';
run;

