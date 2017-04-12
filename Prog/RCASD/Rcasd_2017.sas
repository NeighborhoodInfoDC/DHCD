/**************************************************************************
 Program:  Rcasd_2017.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/07/17
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
  year=2017, 
  infilelist=
	2017-01-06.csv
	2017-01-13.csv
	2017-01-20.csv
	2017-02-03.csv
	2017-02-10.csv
	2017-02-17.csv
	2017-02-24.csv
	2017-03-03.csv
	2017-03-10.csv
	2017-03-17.csv
	2017-03-24.csv
	2017-03-31.csv
	2017-04-07.csv
)

