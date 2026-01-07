/**************************************************************************
 Program:  Rcasd_yyyy.sas
 Library:  DHCD
 Project:  Urban-Greater DC
 Author:   
 Created:  
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
  revisions=%str(Add notices for xxxx to xxxx.),
  year=yyyy,
  infilelist=
    /** Add input file list here **/
)
