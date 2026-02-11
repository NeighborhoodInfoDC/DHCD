/**************************************************************************
 Program:  Rcasd_2014.sas
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
  revisions=%str(Rerun with updated geocoding macro.),
  year=2014,
  infilelist=
    01-03-2014.csv
    01-06_01-10-2014 revised.csv
    01-13_01-17-2014_(Revised).csv
    01-20_01-24-2014.csv
    01-27_01-31-2014.csv
    02-03_02-07-2014.csv
    02-10_02-14-2014.csv
    02-17_02-21-2014.csv
    02-24_02-28-2014_revised_edited.csv
    03-03_03-07-2014_edited.csv
    03-10_03-14-2014.csv
    03-17_03-21-2014.csv
    03-24_03-28-2014_edited.csv
    03-31_04-04-2014.csv
    04-07_04-11-2014.csv
    04-14_04-18-2014.csv
    04-21_04-25-2014_Revised.csv
    04-28_05-02-2014.csv
    05-05_05-09-2014.csv
    05-12_05-16-2014_Revised_edited.csv
    05-26_05-30-2014_(Revised).csv
    06-02_06-06-2014.csv
    06-09_06-13-2014_Revised.csv
    06-16_06-20-2014_Revised.csv
    06-23_06-27-2014.csv
    06-30_07-04-2014.csv
    07-07_07-11-2014_revised.csv
    07-14_07-18-2014.csv
    07-21_07-25-2014_Revised_edited.csv
    07-28_08-01-2014.csv
    08-04_08-08-2014.csv
    08-11_08-15-2014 revised_edited.csv
    08-18_08-22-2014.csv
    08-25_08-29-2014.csv
    09-01_09-05-2014.csv
    09-08_09-12-2014.csv
    09-15_09-19-2014.csv
    09-22_09-26-2014_edited.csv
    09-29_10-03-2014.csv
    10-06_10-10-2014.csv
    10-06_10-10-2014_Revised_2.csv
    10-13_10-17-2014.csv
    10-20_10-24-2014_edited.csv
    10-27_10-31-2014.csv
    11-03_11-07-2014_Revised.csv
    11-10_11-14-2014_edited.csv
    11-17_11-21-2014.csv
    11-24_11-28-2014.csv
    12-08_12-12-2014.csv
    12-1_12-5-2014.csv
    12-15_12-19-2014.csv
    12-22_12-26-2014.csv
)
