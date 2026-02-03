/**************************************************************************
 Program:  Rcasd_2026.sas
 Library:  DHCD
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  2/3/2026
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
  revisions=%str(Add notices for Dec 29, 2025 to Jan 23, 2026.),
  year=2026,
  infilelist=
    Weekly TOPA Report December 29-January 2.txt
    Weekly TOPA Report January 5-9.txt
    Weekly TOPA Report January 12-16.txt
    Weekly TOPA Report January 19-23.txt
)
