/**************************************************************************
 Program:  Rcasd_2016.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/01/16
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
  year=2016, 
  infilelist=
    2016-01-08.csv
    2016-01-15.csv
    2016-01-22_Revised.csv
    2016_-01-29.csv
    2016-02-05.csv
    2016-02-12.csv
    2016-02-19.csv
    2016-02-26.csv
    2016-03-4.csv
    2016-03-11.csv
    2016-03-18.csv
    2016-03-25.csv
    2016-04-01.csv
    2016-04-08.csv
    2016-04-15.csv
    2016-04-22_Revised.csv
    2016-04-29.csv
    2016-05-06.csv
    2016-05-13_Revised.csv
    2016-05-20.csv
    2016-05-27.csv
    2016-06-03.csv
    2016-06-10.csv
    2016-06-17.csv
    2016-06-24.csv
    2016-07-01.csv
    2016-07-08.csv
    2016-07-15.csv
    2016-07-22.csv
    2016-07-29.csv
    2016-08-19.csv
    2016-08-26.csv
    2016-09-02.csv
    2016-09-09-.csv
    2016-09-16_Revised_02.csv
    2016-09-23.csv
    2016-09-30.csv
    2016-10-07_Revised.csv
    2016-10-14.csv
    2016-10-21.csv
    2016-10-28.csv
    2016-11-04.csv
	2016-11-11.csv
	2016-11-18.csv
	2016-11-25.csv
	2016-12-02.csv
)

