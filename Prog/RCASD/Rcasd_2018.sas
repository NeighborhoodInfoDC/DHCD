/**************************************************************************
 Program:  Rcasd_2018.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   W. Oliver
 Created:  05/01/18
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
	2018-02-09.csv
	2018-02-16.csv
	2018-02-23.csv
	2018-03-02.csv
	2018-03-09.csv
	2018-03-16.csv
	2018-03-23.csv
	2018-03-30.csv
	2018-04-06.csv
	2018-04-13.csv
	2018-04-20.csv
	2018-04-27.csv
	2018-05-04.csv
	2018-05-11.csv
	2018-05-18.csv
	2018-05-25.csv
	2018-06-01.csv
	2018-06-08.csv
	2018-06-15.csv
	2018-06-22.csv
	2018-06-29.csv
	2018-07-06.csv
	2018-07-13.csv
	2018-07-20.csv
	2018-07-27.csv
	2018-08-03.csv
	2018-08-10.csv
	2018-08-17.csv
	2018-08-24.csv
	2018-08-31.csv
	)

