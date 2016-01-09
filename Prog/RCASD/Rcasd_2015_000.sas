/**************************************************************************
 Program:  Rcasd_2015_000.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  12/22/15
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read RCASD weekly report of TOPA-related filings.

 Modifications:
**************************************************************************/

/**%include "L:\SAS\Inc\StdLocal.sas";**/
%include "C:\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )

%Rcasd_read_all_files( 
  year=2015, 
  fileid=000, 
  infilelist=
    2015-11-13.csv 
    2015-11-27.csv 
    2015-12-4.csv 
    2015-12-11.csv 
 )

