/**************************************************************************
 Program:  Rcasd_2021.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/03/21
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
  year=2021, 
  infilelist=
	Weekly Report Jan 4 - 8 2021.csv
	Week of Jan 11 - 15 2021.csv
	Weekly Report Jan 18 - 24 2021.csv
	)
