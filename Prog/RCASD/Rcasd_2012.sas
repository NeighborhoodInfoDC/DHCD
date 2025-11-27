/**************************************************************************
 Program:  Rcasd_2012.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/31/2025
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
  year=2012,
  infilelist=
    01-02_01-06-2012.csv
    01-09_01-13-2012.csv
    01-30_02-03-2012.csv
    02-06_02-10-2012.csv
    02-13_02-17-2012.csv
    02-20_02-24-2012.csv
    02-27_03-02-2012.csv
    03-05_03-09-2012.csv
    03-12_03-16-2012.csv
    03-19_03-23-2012.csv
    03-26_03-30-2012.csv
    04-02_04-06-2012.csv
    04-09_04-13-2012.csv
    04-16_04-20-2012.csv
    04-23_04-27-2012.csv
    04-30_05-04-2012.csv
    05-07_05-11-2012.csv
    05-14_05-18-2012 edited.csv
    05-21_05-25-2012.csv
    05-28_06-01-2012.csv
    06-04_06-08-2012.csv
    06-11_06-15-2012.csv
    06-18_06-22-2012.csv
    06-25_06-29-2012.csv
    07-02_07-06-2012.csv
    07-09_07-13-2012.csv
    07-16_07-20-2012.csv
    07-23_07-27-2012.csv
    07-30_08-03-2012.csv
    08-06_08-10-2012.csv
    08-13_08-17-2012_(Amended) edited.csv
    08-20_08-24-2012.csv
    08-27_08-31-2012.csv
    09-03_09-07-2012_Revised.csv
    09-10_09-14-2012.csv
    09-17_09-21-2012_Revised.csv
    09-24_09-28-2012.csv
    10-01_10-05-2012_Revised_2nd.csv
    10-08_10-12-2012_(Revised).csv
    10-15_10-19-2012.csv
    10-22_10-26-2012.csv
    10-29_11-02-2012.csv
    11-05_11-09-2012.csv
    11-12_11-16-2012.csv
    11-19_11-23-2012.csv
    11-26_11-30-2012_Revised.csv
    12-03_12-07-2012.csv
    12-10_12-14-2012.csv
    12-17_12-21-2012.csv
    12-24_12-28-2012_Revised.csv
)
