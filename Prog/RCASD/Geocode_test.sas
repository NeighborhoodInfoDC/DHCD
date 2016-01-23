/**************************************************************************
 Program:  Geocode_test.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/22/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:

 Modifications:
**************************************************************************/

/**%include "L:\SAS\Inc\StdLocal.sas";**/
%include "C:\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( RealProp )
%DCData_lib( MAR )

/*%File_info( data=Mar.address_points )*/

data test;

  set Mar.address_points (keep=address_id fulladdres where=(fulladdres~=''));
  
  length xnumber $ 32 number 8 streetname streettype dir $ 40 buff $ 200;
  
  buff = left( compbl( fulladdres ) );
  
  xnumber = scan( buff, 1, ' ' );
  number = input( xnumber, 32. );
  
  buff = substr( buff, length( xnumber ) + 2 );
  
  if scan( buff, 1, ' ' ) in ( '1/2', 'REAR' ) then buff = substr( buff, length( scan( buff, 1, ' ' ) ) + 2 );
  
  if scan( buff, 1, ' ' ) in ( 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K' ) then do;
    if scan( buff, 2, ' ' ) not in ( 'STREET', 'ROAD', 'COURT', 'PLACE', 'TERRACE' ) then buff = substr( buff, 3 );
  end;
  
  dir = scan( buff, -1, ' ' );
  
  streettype = scan( buff, -2, ' ' );
  
  streetname = substr( buff, 1, length( buff ) - ( length( dir ) + length( streettype ) + 2 ) );
  
  drop buff;
  
run;

proc print data=Test (obs=20);
  where streetname contains 'WEST LANE';
  id address_id;
run;

proc freq data=Test;
  tables streetname streettype dir;
run;

ENDSAS;

%File_info( data=sashelp.GEOEXM /*, freqvars=name*/ )
%File_info( data=sashelp.GEOEXS, freqvars=PREDIRABRV SUFDIRABRV SUFTYPABRV )
%File_info( data=sashelp.GEOEXP )
%File_info( data=SASHELP.PLFIPS )
%File_info( data=SASHELP.GCTYPE )

proc print data=sashelp.GEOEXM;
  where name = "YORK";
run;

proc print data=sashelp.GEOEXS (firstobs=100523 obs=100538);
run;

endsas;

data Rcasd_geocode;

  set dhcd.rcasd_2015_000 (obs=10 keep=Nidc_id Addr_num Address);
  
  retain City "Washington" State "DC";
  
run;

proc geocode
  method=street
  data=rcasd_geocode
  lookupstreet=RealProp.Parcel_base
  attribute_var=(ssl);
  run;
quit;


