/**************************************************************************
 Program:  Rcasd_2007.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/1/22
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  132
 
 Description:  Read RCASD weekly report of TOPA-related filings.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( MAR )

%Rcasd_read_all_files( 
  revisions=%str(New file.),
  year=2007, 
  infilelist=
    01-01_01-05-2007.csv
    01-08_01-12-2007 revised.csv
    01-15_01-19-2007.csv
    01-22_01-26-2007.csv
    01-29_02-02-2007 revised.csv
    02-05_02-09-2007.csv
    02-12_02-16-2007.csv
    02-19_02-23-2007.csv
    02-26_03-02-2007.csv
    03-05_03-09-2007.csv
    03-12_03-16-2007.csv
    03-19_03-23-2007.csv
    04-02_04-06-2007.csv
    04-09_04-13-2007.csv
    04-16_04-20-2007.csv
    04-23_04-27-2007.csv
    04-23_04-27-2007_(Revised).csv
    04-30_05-04-2007.csv
    05-07_05-11-2007.csv
    05-14_05-18-2007.csv
    05-21_05-25-2007.csv
    05-28_06-01-2007.csv
    06-04_06-08-2007.csv
    06-11_06-15-2007.csv
    06-18_06-22-2007.csv
    06-25_06-29-2007.csv
    07-02_07-06-2007.csv
    07-09_07-13-2007.csv
    07-16_07-20-2007.csv
    07-23_07-27-2007.csv
    07-30_08-03-2007.csv
    08-06_08-10-2007.csv
    08-13_08-17-2007.csv
    08-20_08-24-2007.csv
    08-27_08-31-2007.csv
    09-03_09-07-2007.csv
    09-10_09-14-2007.csv
    09-17_09-21-2007.csv
    09-24_09-28-2007.csv
    10-01_10-05-2007.csv
    10-08_10-12-2007.csv
    10-15_10-19-2007.csv
    10-22_10-26-2007.csv
    10-29_11-02-2007_updated revised.csv
    11-05_11-09-2007.csv
    11-12_11-16-2007.csv
    11-19_11-23-2007.csv
    11-26_11-30-2007.csv
    12-03_12-07-2007.csv
    12-10_12-14-2007.csv
)

