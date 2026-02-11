/**************************************************************************
 Program:  Rcasd_2010.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  1/5/2026
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  
 
 Description:  Read RCASD weekly report of TOPA-related filings.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( MAR )

%Rcasd_read_all_files( 
  revisions=%str(New file.),
  year=2010, 
  infilelist=
    01-01-2010.csv
    01-04_01-08-2010.csv
    01-11_01-15-2010.csv
    01-18_01-22-2010.csv
    01-25_01-29-2010.csv
    02-01_02-05-2010.csv
    02-08_02-12-2010.csv
    02-15_02-19-2010.csv
    02-22_02-26-2010.csv
    03-01_03-05-2010.csv
    03-08_03-12-2010.csv
    03-15_03-19-2010.csv
    03-22_03-26-2010.csv
    03-29_04-02-2010.csv
    04-05_04-09-2010.csv
    04-12_04-16-2010.csv
    04-19_04-23-2010.csv
    04-26_04-30-2010.csv
    05-03_05-07-2010.csv
    05-10_05-14-2010.csv
    05-17_05-21-2010.csv
    05-24_05-28-2010.csv
    06-01_06-04-2010.csv
    06-07_06-11-2010.csv
    06-14_06-18-2010.csv
    06-21_06-25-2010_(Revised)_edited.csv
    06-28_07-02-2010.csv
    07-05_07-09-2010.csv
    07-12_07-16-2010.csv
    07-19_07-23-2010.csv
    07-26_07-30-2010_edited.csv
    08-02_08-06-2010.csv
    08-09_08-13-2010.csv
    08-16_08-20-2010.csv
    08-23_08-27-2010.csv
    08-30_09-03-2010.csv
    09-06_09-10-2010.csv
    09-13_09-17-2010.csv
    09-20_09-24-2010.csv
    09-27_10-01-2010.csv
    10-04_10-08-2010.csv
    10-11_10-15-2010.csv
    10-18_10-22-2010.csv
    10-25_10-29-2010.csv
    11-01_11-05-2010.csv
    11-08_11-12-2010.csv
    11-15_11-19-2010.csv
    11-22_11-26-2010.csv
    11-29_12-03-2010.csv
    12-06_12-10-2010.csv
    12-13_12-17-2010.csv
    12-20_12-24-2010.csv
    12-27_12-31-2010.csv
)
