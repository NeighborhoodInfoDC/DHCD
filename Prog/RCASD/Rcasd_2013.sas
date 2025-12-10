/**************************************************************************
 Program:  Rcasd_2013.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/30/2025
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
  revisions=%str(New file.),
  year=2013,
  infilelist=
    01-04-2013.csv
    01-07_01-11-2013.csv
    01-14_01-18-2013.csv
    01-21_01-25-2013.csv
    01-28_02-01-2013_revised_edited.csv
    02-04_02-08-2013.csv
    02-11_02-15-2013_edited.csv
    02-18_02-22-2013.csv
    02-25_03-01-2013.csv
    03-04_03-08-2013.csv
    03-11_03-15-2013.csv
    03-18_03-22-2013_(Revised_4-11-13).csv
    03-25_03-29-2013.csv
    04-01_04-05-2013.csv
    04-08_04-12-2013_Revised_02.csv
    04-15_04-19-2013.csv
    04-22_04-26-2013_edited.csv
    04-29_05-03-2013.csv
    05-06_05-10-2013.csv
    05-13_05-17-2013.csv
    05-20_05-24-2013_Revised.csv
    05-27_05-31-2013.csv
    06-03_06-07-2013_edited.csv
    06-10_06-14-2013_Revised.csv
    06-17_06-21-2013.csv
    06-24_06-28-2013_Revised.csv
    07-01_07-05-2013.csv
    07-08_07-12-2013_Revised.csv
    07-15_07-19-2013.csv
    07-22_07-26-2013.csv
    07-29_08-02-2013.csv
    08-05_08-09-2013.csv
    08-12_08-16-2013.csv
    08-19_08-23-2013.csv
    08-26_08-30-2013.csv
    09-02_09-06-2013.csv
    09-09_09-13-2013.csv
    09-16_09-20-2013.csv
    09-23_09-27-2013.csv
    09-30_10-04-2013_edited.csv
    10-07_10-11-2013_edited.csv
    10-14_10-18-2013.csv
    10-21_10-25-2013_edited.csv
    10-28_11-01-2013_Revised.csv
    11-04_11-08-2013_(Revised_Report).csv
    11-11_11-15-2013_(Revised_Report).csv
    11-18_11-22-2013_(Revised_Report)_edited.csv
    11-25_11-29-2013_(Revised).csv
    12-02_12-06-2013_Revised.csv
    12-09_12-13-2013.csv
    12-16_12-20-2013_edited.csv
    12-23_12-27-2013_edited.csv
)
