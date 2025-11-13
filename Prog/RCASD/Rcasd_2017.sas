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

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( MAR )


%Rcasd_read_all_files( 
  revisions=%str(Recreate data with updated code.),
  year=2017, 
  infilelist=
	2017-01-06.csv
	2017-01-13.csv
	2017-01-20.csv
	2017-02-03.csv
	2017-02-10_edited.csv
	2017-02-17.csv
	2017-02-24.csv
	2017-03-03.csv
	2017-03-10.csv
	2017-03-17_edited.csv
	2017-03-24.csv
	2017-03-31.csv
	2017-04-07.csv
	2017-04-14_edited.csv
	2017-04-21_edited.csv
	2017-04-28_edited.csv
	2017-05-05_edited.csv
	2017-05-12.csv
	2017-05-19.csv
	2017-05-26_Revised.csv
	2017-06-02.csv
	2017-06-09.csv
	2017-06-16_Revised.csv
	2017-06-23_Revised.csv
	2017-06-30.csv
	2017-08-04.csv
	2017-08-11.csv
	2017-08-18.csv
	2017-08-25.csv
	2017-09-01.csv
	2017-09-08.csv
	2017-09-15.csv
	2017-09-22.csv
	2017-09-29.csv
	2017-10-13_Revised.csv
	2017-10-20_Revised.csv
	2017-11-17.csv
	2017-11-24.csv
	2017-12-01.csv
	2017-12-08_edited.csv
	2017-12-15.csv
	2017-12-22.csv
	2017-12-29.csv
)

