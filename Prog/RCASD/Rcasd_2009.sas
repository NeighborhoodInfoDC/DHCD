/**************************************************************************
 Program:  Rcasd_2009.sas
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
  year=2009, 
  infilelist=
    01-05_01-09-2009.csv
    01-12_01-16-2009_edited.csv
    01-19_01-23-2009.csv
    03-02_03-06-2009.csv
    03-09_03-13-2009.csv
    03-16_03-20-2009.csv
    03-23_03-27-2009.csv
    03-30_04-03-2009.csv
    04-06_04-10-2009.csv
    04-13_04-17-2009.csv
    04-20_04-24-2009.csv
    04-27_5-01-2009.csv
    05-05_05-09-2009.csv
    05-11_05-15-2009.csv
    05-18_05-22-2009.csv
    05-25_05-29-2009.csv
    06-01_06-05-2009.csv
    06-08_06-12-2009.csv
    06-15_06-19-2009.csv
    06-22_06-26-2009.csv
    06-29_07-03-2009.csv
    07-06_07-10-2009.csv
    07-13_07-17-2009.csv
    07-20_07-24-2009.csv
    07-27_07-31-2009.csv
    08-03_08-07-2009.csv
    08-10_08-14-2009.csv
    08-17_08-21-2009.csv
    08-24_08-28-2009.csv
    08-31_09-04-2009.csv
    09-07_09-11-2009.csv
    09-14_09-18-2009.csv
    09-21_09-25-2009.csv
    09-28_10-02-2009.csv
    10-05_10-09-2009.csv
    10-12_10-16-2009_edited.csv
    10-19_10-23-2009.csv
    10-26_10-30-2009.csv
    11-02_11-06-2009.csv
    11-09_11-13-2009.csv
    11-16_11-20-2009.csv
    11-23_11-27-2009.csv
    11-30_12-04-2009.csv
    12-07_12-11-2009.csv
    12-14_12-18-2009.csv
    12-21_12-25-2009.csv
)
