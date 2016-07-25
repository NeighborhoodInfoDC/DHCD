/**************************************************************************
 Program:  Read_LIHTC_FOIA_11_09_12.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/25/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read tax credit data provided by DHCD.
 L:\Libraries\DHCD\Raw\LIHTC\FOIA Request Tax Credit Properties 11-9-12.csv

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )

filename foia  "L:\Libraries\DHCD\Raw\LIHTC\FOIA Request Tax Credit Properties 11-9-12.csv" lrecl=2000;

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
    
    if seg_address ~= "" then do;
        dhcd_seg_id + 1;
        output;
    end;
    
  end;
  
  format seg_placed_in_service proj_placed_in_service proj_compliance_start proj_initial_expiration proj_extended_expiration mmddyy10.;
  
  drop skip: ;

run;

%File_info( data=A, printobs=50 )
