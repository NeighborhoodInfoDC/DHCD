/**************************************************************************
 Program:  Read_LIHTC_FOIA_11_09_12.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/25/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read tax credit data provided by DHCD.
 Original: L:\Libraries\DHCD\Raw\LIHTC\FOIA Request Tax Credit Properties 11-9-12.csv
 Edited: FOIA Request Tax Credit Properties 11-9-12 (Urban edit).csv

 In edited file, 
 Copied the following missing addresses to Mayfair Mansions
   3726 Hayes St NE 
   3780 Hayes St NE 
   3810 Hayes St NE 
 Removed these addresses from Faircliff Plaza
  "1424 Euclid Street, NW (Acq.)",,,,,,03/18/05,,,
  "1424 Euclid Street, NW (Reb.)",,,,,,12/01/05,,,
  "1426 Euclid Street, NW (Acq.)",,,,,,03/18/05,,,
  "1426 Euclid Street, NW (Reb.)",,,,,,12/01/05,,,
  "1428 Euclid Street, NW (Acq.)",,,,,,03/18/05,,,
  "1428 Euclid Street, NW (Reb.)",,,,,,12/01/05,,,
  "1430 Euclid Street, NW (Acq.)",,,,,,03/18/05,,,
  "1430 Euclid Street, NW (Reb.)",,,,,,12/01/05,,,
  "1432 Euclid Street, NW (Acq.)",,,,,,03/18/05,,,
  "1432 Euclid Street, NW (Reb.)",,,,,,12/01/05,,,
 Added to Faircliff Plaza
  1424 - 1432 CLIFTON ST NW
 Replaced business address for PV Limited Partnership with actual 
 property addresses
 For Comm. Group/Regency Pool (WDC I) replaced "5115 Drake Place, SE" with
 "5115 QUEENS STROLL PL SE"

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( MAR )

filename foia  "L:\Libraries\DHCD\Raw\LIHTC\FOIA Request Tax Credit Properties 11-9-12 (Urban edit).csv" lrecl=2000;

data A;

  dhcd_project_id + 1;
  dhcd_seg_id = 0;

  infile foia dsd missover firstobs=2;
  
  length project $ 40;

  do until( project ~= "" );

    input
      project : $40.
      owner : $80.
      ward : $1.
      proj_bldgs : 8.
      proj_units : 8.
      proj_lihtc_units : 8.
      proj_placed_in_service : mmddyy10.
      proj_compliance_start : mmddyy10.
      proj_initial_expiration : mmddyy10.
      proj_extended_expiration : mmddyy10.;
  
  end;

  length seg_address skip1-skip5 $ 120;

  do until ( seg_address = "" );

    input 
        seg_address
        skip1
        skip2
        skip3
        skip4
        skip5
        seg_placed_in_service : mmddyy10.;

    ** Corrections **;
    
    select ( seg_address );
      when ( '400 M Street' )
        seg_address = '400 M Street SE';
      when ( '107-113 58th Street  (Amended)' )
        seg_address = '107-113 58th Street SE (Amended)';
      when ( '5745-5765 Blaine Street  (Amended)' )
        seg_address = '5745,5747,5763,5765 Blaine Street  (Amended)';
      when ( '5747-5751 East Capitol Street   (Amended)' )
        seg_address = '5747 East Capitol Street   (Amended)';
      when ( '1374 Congress Street (Acq.)', '1374 Congress Street (Rehab.)' )
        seg_address = '-SKIP-';
      otherwise
        /** Do nothing **/;
    end;
    
    if seg_address not in ( '', '-SKIP-' ) then do;
        seg_address = prxchange( 's/(\(.*\))//', -1, seg_address );
        dhcd_seg_id + 1;
        output;
    end;
    
  end;
  
  format seg_placed_in_service proj_placed_in_service proj_compliance_start proj_initial_expiration proj_extended_expiration mmddyy10.;
  
  drop skip: ;

run;

%LIHTC_address_parse( data=A, out=B, id=dhcd_project_id dhcd_seg_id, addr=seg_address )

%File_info( data=B, printobs=10 )

%DC_mar_geocode( 
  data=B, 
  staddr=Address, 
  out=C, 
  id=dhcd_project_id dhcd_seg_id, 
  keep_geo=address_id ssl, 
  streetalt_file=D:\DCData\Libraries\DHCD\Prog\LIHTC\StreetAlt.txt )

data Dhcd.Lihtc_foia_11_09_12 (label="LIHTC projects, FOIA request, 11/9/12");

  merge A C;
  by dhcd_project_id dhcd_seg_id;

  ** Remove extraneous geo matches from LIHTC FOIA data **;

  if scan( address_std, 1 ) ~= scan( m_addr, 1 ) then _score_ = .n;
  
  if _score_ >= 45;
  
  if indexw( _notes_, 'NODSM' ) then delete;
  
  drop m_state m_city;
  
run;

%File_info( data=Dhcd.Lihtc_foia_11_09_12, printobs=10, freqvars=_matched_ _status_ )
