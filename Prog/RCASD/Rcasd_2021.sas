/**************************************************************************
 Program:  Rcasd_2021.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/03/21
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
  year=2021, 
  infilelist=
	Weekly Report Jan 4 - 8 2021.csv
	Week of Jan 11 - 15 2021.csv
	Weekly Report Jan 18 - 24 2021.csv
	report_3.csv
	report_4.csv
	report (4).csv
	report (1)_0.csv
	report (3).csv
	TOPA report March 8 - March 12.csv
	Weekly Report March 15 - March 19_rev.csv
	report_5.csv
	March 29 - April 2.csv
	report (3)_0.csv
	Weekly Report April 12 - April 16.csv
	report (1)_1.csv
	report (5)_0.csv
	report (6).csv
	report (5).csv
	report (4)_0.csv
	May 24- May 28.csv
	May 31- June 4.csv
	Report for week of June 7-11.csv
	Weekly Report 06.18.2021.csv
	Week of June 21-25.csv
	Week of June 28-July 1.csv
	Weekly TOPA Report July 5 - 9.csv
	Weekly TOPA Report July 12-16.csv
	Weekly Report July 19-23.csv
	July 26-30.csv
	Weekly TOPA Report August 2-6.csv
	Weekly TOPA Report August 9-13_new.csv
	Weekly TOPA Report August 16-20.csv
	Weekly TOPA Report August 23-27_new.csv
	Weekly TOPA Report August 31-September 3.csv
	)
