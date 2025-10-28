/**************************************************************************
 Program:  Rcasd_2022.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/27/2025
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
  year=2022, 
  infilelist=

    Weekly TOPA Report October 10-14.txt

/***
    Weekly TOPA Report October 3-7.txt
    Weekly TOPA Report October 10-14.txt
    report_11.txt
    Weekly TOPA Report October 24-28.txt
    Weekly TOPA Report October 31- November 4.txt
    Weekly TOPA Report November 7-11.txt
    Weekly TOPA Report November 14-18.txt
    Weekly TOPA Report November 21-25.txt
    Weekly TOPA Report November 28-December 2.txt
    Weekly TOPA Report December 5-9.txt
    Weekly TOPA Report December 12-16.txt
    Weekly TOPA Report December 19-23.txt
    Weekly TOPA Report December 26-30.txt	
***/
)
