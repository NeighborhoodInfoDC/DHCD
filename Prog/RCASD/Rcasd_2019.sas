/**************************************************************************
 Program:  Rcasd_2019.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/01/19
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read RCASD weekly report of TOPA-related filings.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( MAR )


%Rcasd_read_all_files( 
  year=2019, 
  infilelist=
	2019-01-04.csv
	2019-1-11 Revised.csv
	Weekly Report January 14-18 2019.csv
	
	Week of June 10 – 24 2019 Revised.csv
	)

