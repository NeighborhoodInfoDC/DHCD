/**************************************************************************
 Program:  Rcasd_2011.sas
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
  year=2011, 
  infilelist=
    01-03_01-07-2011.csv
    01-10_01-14-2011.csv
    01-17_01-21-2011_edited.csv
    01-24_01-28-2011.csv
    01-31_02-04-2011.csv
    02-07_02-11-2011.csv
    02-14_02-18-2011.csv
    02-21_02-25-2011.csv
    02-28_03-04-2011.csv
    03-07_03-11-2011.csv
    03-14_03-18-2011.csv
    03-21_03-25-2011.csv
    04-04_04-08-2011.csv
    04-11_04-15-2011.csv
    04-18_04-22-2011_bis.csv
    04-25_04-29-2011.csv
    05-02_05-06-2011.csv
    05-09_05-13-2011.csv
    05-16_05-20-2011.csv
    05-23_05-27-2011.csv
    05-30_06-03-2011.csv
    06-06_06-10-2011.csv
    06-13_06-17-2011.csv
    06-20_06-24-2011.csv
    06-27_07-01-2011.csv
    07-04_07-08-2011.csv
    07-11_07-15-2011.csv
    07-18_07-22-2011.csv
    07-25_07-29-2011.csv
    08-01_08-05-2011.csv
    08-08_08-12-2011.csv
    08-15_08-19-2011.csv
    08-22_08-26-2011.csv
    08-29_09-02-2011.csv
    09-05_09-09-2011.csv
    09-12_09-16-2011.csv
    09-19_09-23-2011.csv
    09-26_09-30-2011.csv
    10-03_10-07-2011.csv
    10-10_10-14-2011.csv
    10-17_10-21-2011.csv
    10-24_10-28-2011.csv
    10-31_11-04-2011.csv
    11-07_11-11-2011.csv
    11-14_11-18-2011.csv
    11-21_11-25-2011.csv
    11-28_12-02-2011.csv
    12-05_12-09-2011_(Revised).csv
    12-12_12-16-2011_edited.csv
    12-19_12-23-2011.csv
    12-26_12-30-2011.csv
)
