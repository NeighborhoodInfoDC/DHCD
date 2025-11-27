/**************************************************************************
 Program:  Rcasd_TEST.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/1/22
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  132
 
 Description:  Read RCASD weekly report of TOPA-related filings.
 
 Program for testing different file formats.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( MAR )

%Rcasd_read_all_files( 
  revisions=%str(New file.),
  year=Test, 
  infilelist=
    Weekly_TOPA_Report_December_27-31.csv
  /*
    01-01_01-05-2007.csv
    05-14_05-18-2007.csv
    10-29_11-02-2007_updated revised.csv
    05-16_05-20-2011.csv
    06-07_06-11-2010 revised.csv
    2016-09-02 revised.csv
  /*
  /*
    10-29_11-02-2007_updated - No counts.csv
    10-29_11-02-2007_updated - Error count 1.csv
    10-29_11-02-2007_updated - Error count 2.csv
    2016-09-02 revised - Error count 1.csv
    2016-09-02 revised - Error count 2.csv
  */
)

