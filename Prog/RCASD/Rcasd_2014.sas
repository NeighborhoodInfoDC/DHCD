/**************************************************************************
 Program:  Rcasd_2014.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/30/2025
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read RCASD weekly report of TOPA-related filings.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( MAR )

%Rcasd_read_all_files( 
  year=2014,
  infilelist=
    01-06_01-10-2014 revised.csv
)
