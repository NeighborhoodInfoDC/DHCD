/**************************************************************************
 Program:  Rcasd_2020.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/01/19
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read RCASD weekly report of TOPA-related filings.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( MAR )


%Rcasd_read_all_files( 
  year=2020, 
  infilelist=
  	Week of January 6 - 10 2020.csv
	Week of January 13 - 17 2020.csv
	Week of January 20 - 24 2020.csv
	Week of January 27 - 31 2020.csv
	Week of February 3 - 7 2020.csv
	Week of February 10 - 14 2020.csv
	Week of February 17 - 23 2020.csv
	Week of February 24-28 2020.csv
	Week of March 2 2020.csv
	Weekly Report March 9 - 13.csv
	Weekly Report March 16 - 20.csv
	Week of March 23 - 26 2020.csv
	Week of March 30 - April 3 2020.csv
	Week of April 6 - 8 2020.csv
	Week of April 13 - 16 2020.csv
	Week of April 20 - 24 2020.csv
	Week of April 27 – May 1 2020.csv
	Week of May 4 - 8 2020.csv
	Week of May 11 - 15 2020.csv
	Week of May 18 – 22 2020.csv
	)

