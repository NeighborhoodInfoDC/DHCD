/**************************************************************************
 Program:  Rcasd_2018.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   N. Strayer
 Created:  02/06/18
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read RCASD weekly report of TOPA-related filings.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( MAR )


%Rcasd_read_all_files( 
  year=2018, 
  infilelist=
	2018-01-05.csv
	2018-01-12.csv
	2018-01-19.csv
	2018-01-26.csv
	2018-02-02.csv
)
