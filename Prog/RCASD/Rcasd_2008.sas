/**************************************************************************
 Program:  Rcasd_2008.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  12/3/22
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
  year=2008, 
  infilelist=
    01-04-2008 revised.csv
    01-07_01-11-2008.csv
    01-14_01-18-2008 revised.csv
    01-21_01-25-2008 revised.csv
    01-28_02-01-2008 revised.csv
    02-04_02-08-2008.csv
    02-11_02-15-2008 revised.csv
    02-18_02-22-2008.csv
    02-25_02-29-2008.csv
    03-03_03-07-2008 revised.csv
    03-10_03-14-2008.csv
    03-17_03-21-2008.csv
    03-24_03-28-2008.csv
    03-31_04-04-2008.csv
    04-07_04-11-2008.csv
    04-14_04-18-2008.csv
    04-21_04-25-2008.csv
    04-28_05-02-2008.csv
    05-05_05-09-2008.csv
    05-11_05-17-2008.csv
    05-18_05-24-2008.csv
    05-26_05-30-2008.csv
    06-02_06-06-2008 revised.csv
    06-09_06-13-2008.csv
    06-16_06-20-2008.csv
    06-23_06-27-2008.csv
    06-30_07-04-2008.csv
    07-07_07-11-2008.csv
    07-14_07-18-2008.csv
    07-21_07-25-2008.csv
    07-28_08-01-2008.csv
    08-04_08-08-2008.csv
    08-11_08-15-2008.csv
    08-18_08-22-2008.csv
    08-25_08-29-2008.csv
    09-01_09-05-2008.csv
    09-08_09-12-2008.csv
    09-15_09-19-2008.csv
    09-22_09-26-2008.csv
    09-29_10-03-2008.csv
    10-06_10-10-2008.csv
    10-13_10-17-2008.csv
    10-20_10-24-2008.csv
    10-27_10-31-2008.csv
    11-03_11-07-2008.csv
    11-10_11-14-2008.csv
    11-17_11-21-2008.csv
    12-01_12-05-2008.csv
    12-08_12-12-2008.csv
    12-15_12-19-2008.csv
    12-22_12-26-2008.csv
    12-29-2008_01-02-2009.csv
)
