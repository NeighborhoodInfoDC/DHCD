/**************************************************************************
 Program:  Rcasd_2015.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  12/22/15
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
  revisions=%str(Add Notes var; cleanup Num_units, Sale_price.),
  year=2015, 
  infilelist=
    2015-01-09.csv
    2015-01-16.csv
    2015-01-23.csv
    2015-01-30.csv
    2015-02-06.csv
    2015-02-13.csv
    2015-02-20.csv
    2015-02-27.csv
    2015-03-06.csv
    2015-03-13.csv
    2015-03-20.csv
    2015-03-27_Revised.csv
    2015-04-03.csv
    2015-04-10.csv
    2015-04-17.csv
    2015-04-24.csv
    2015-05-01.csv
    2015-05-08_Revised.csv
    2015-05-15.csv
    2015-05-22.csv
    2015-05-29.csv
    2015-06-05.csv
    2015-06-12.csv
    2015-06-19.csv
    2015-06-26.csv
    2015-07-03.csv
    2015-07-10.csv
    2015-07-17.csv
    2015-07-24.csv
    2015-07-31.csv
    2015-08-07.csv
    2015-08-14_Amended_Report.csv
    2015-08-21.csv
    2015-08-28.csv
    2015-09-10.csv
    2015-09-18.csv
    2015-09-25.csv
    2015-10-16.csv
    2015-10-23.csv
    2015-10-30.csv
    2015-11-6.csv
    2015-11-13.csv
    2015-11-27.csv
    2015-12-4.csv
    2015-12-11.csv
    2015-12-18.csv
    2015-12-25.csv
    2016-01-01.csv
)

