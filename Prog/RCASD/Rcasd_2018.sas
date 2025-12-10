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

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( MAR, local=n )


%Rcasd_read_all_files( 
  revisions=%str(Recreate data with updated code.),
  year=2018, 
  infilelist=
	2018-01-05.csv
	2018-01-12_edited.csv
	2018-01-19_edited.csv
	2018-01-26.csv
	2018-02-02_edited.csv
	2018-02-09.csv
	2018-02-16.csv
	2018-02-23_edited.csv
	2018-03-02.csv
	2018-03-09.csv
	2018-03-16_edited.csv
	2018-03-23.csv
	2018-03-30_edited.csv
	2018-04-06_edited.csv
	2018-04-13.csv
	2018-04-20.csv
	2018-04-27.csv
	2018-05-04_edited.csv
	2018-05-11.csv
	2018-05-18.csv
	2018-05-25.csv
	2018-06-01.csv
	2018-06-08.csv
	2018-06-15_edited.csv
	2018-06-22_edited.csv
	2018-06-29_edited.csv
	2018-07-06_edited.csv
	2018-07-13_edited.csv
	2018-07-20.csv
	2018-07-27.csv
	2018-08-03_edited.csv
	2018-08-10.csv
	2018-08-17.csv
	2018-08-24.csv
	2018-08-31.csv
	2018-09-07.csv
	2018-09-14.csv
	2018-09-28_edited.csv
	2018-10-26.csv
	2018-11-02_edited.csv
	2018-11-09_edited.csv
	2018-11-16_edited.csv
	2018-11-23.csv
	2018-11-30_edited.csv
	2018-12-07_edited.csv
	2018-12-14_edited.csv
	2018-12-21_edited.csv
	2018-12-28.csv
	)

