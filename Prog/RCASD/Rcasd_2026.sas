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
  revisions=%str(Add notices for Apr 27 to May 15, 2026.),
  year=2026,
  infilelist=
    Weekly TOPA Report December 29-January 2.txt
    Weekly TOPA Report January 5-9.txt
    Weekly TOPA Report January 12-16.txt
    Weekly TOPA Report January 19-23.txt
    Weekly TOPA Report January 26-30.txt
    Weekly TOPA Report February 2-6.txt
    Weekly TOPA Report February 9-13.txt
    Weekly TOPA Report February 16-20.txt
    Weekly TOPA Report February 23-27.txt
    Weekly TOPA Report March 2-6.txt
    Weekly TOPA Report March 9-13.txt
    Weekly TOPA Report March 16-20_1.txt
    Weekly TOPA Report March 23-27.txt
    Weekly Report on Tenant Opportunity to Purchase Act %28TOPA%29 Filings %28March 30-April 3%2C 2026%29.txt
    Weekly TOPA Report April 6-10.txt
    Weekly TOPA Report April 13-17.txt
    Weekly TOPA Report April 20-24.txt
    Weekly TOPA Report April 27-May 1.txt
    Weekly TOPA Report May 4-8.txt
    Weekly TOPA Report May 11-15.txt
)
