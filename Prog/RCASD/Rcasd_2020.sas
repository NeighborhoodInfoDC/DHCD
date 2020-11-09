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

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

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
	Week of February 24-28 2020 edit.csv
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
	Week of May 25 - 29 2020.csv
	Week of June 1-5 2020.csv
	Week of June 8-12 2020.csv
	Week of June 15-19 2020.csv
	Week of June 22-26 2020.csv
	Week of June 29- July 3 2020.csv
	Week of July 6-10 2020.csv
	Week of July 13 - 17 2020.csv
	Week of July 20 - 24 2020.csv
	July 27 - 31.csv
	Week of August 3 - 7 2020.csv
	Week of August 10 - 14 2020.csv
	August 17 - 21 2020.csv
	Week of August 24 - 28 2020.csv
	Week of August 31 – September 4 2020.csv
	Week of September 7 - 11 2020.csv
	Week of September 14 - 18 2020.csv
	Week of September 21 - 25 2020.csv
	Week of September 28 – October 2 2020.csv
	Weekly Report October 5 - October 9 2020.csv
	Week of October 12 - 16 2020.csv
	Week of October 19 - 23 2020.csv
	)

