/**************************************************************************
 Program:  Rcasd_2019.sas
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
%DCData_lib( MAR, local=n )


%Rcasd_read_all_files( 
  revisions=%str(Recreate data with updated code.),
  year=2019, 
  infilelist=
  	/*
	2019-01-04.csv
	2019-1-11 Revised.csv
	Weekly Report January 14-18 2019.csv
	Weekly Report June 24 – 28 2019.csv
	Weekly Report June 17 – 21 2019.csv
	Week of June 10 – 24 2019 Revised.csv
	Weekly Report June 3 -7 2019.csv
	Weekly Report May 27-31 2019.csv
	Weekly Report May 20 - 24 2019.csv
	Weekly Report May 13-17 2019.csv
	Weekly Report May 6-10 2019.csv
	TOPA Weekly Report April 29-May 03 2019.csv
	TOPA-Related Filings – Weekly Report April 22 – 26 2019.csv
	topa week of 4-8 to 15 2019 revised.csv
	topa week of 4-1 to 5 2019.csv
	topa week of 3.25 - 3.29.csv
	topa week of 3.18 - 3.22.csv
	TOPA Weekly Report March 11-15.csv
	Week of March 4-8 2019.csv
	Weekly Report February 25- March 1 2019.csv
	2.11. to 2.15. 2019 report revised.csv
	topa report 2.8 to 22.19.csv
	*/
	2.4 - 2.8. 2019 report.csv
	/*
	TOPA-Related Filings  Weekly Report January 21-25 2019.csv
	TOPA Week of July 1 – 5 2019.csv
	Week of July 8 – 12 2019.csv
	Week of July 15 – 19 2019.csv
	TOPA Week of July 22 – 26 2019.csv
	Week of July 29 – August 2 2019.csv
	week of 8-5 to 8-9.csv
	Week of August 12 - 16 2019.csv
	Week of August 19 - 23 2019.csv
	Week of August 26 - 30 2019.csv
	Week of September 2 - 6 2019.csv
	Week of September 9 - 13 2019.csv
	Week of September 16 - 20 2019.csv
	Week of September 23 - 27 2019.csv
	Week of September 30 – October 4 2019.csv
	Week of October 7 - 11 2019.csv
	Week of October 14 - 18 2019.csv
	Week of October 21 - 25 2019.csv
	Week of October 28 - November 1 2019.csv
	Week of November 4 – 8 2019.csv
	Week of November 11 – 15 2019.csv
	Week of November 18 – 22 2019.csv
	Week of November 25 – 29 2019.csv
	Week of December 2 - 6 2019.csv
	Week of December 9 - 13 2019.csv
	Week of  December 16 - 20.csv
	Week of December 23 - 27 2019.csv
	Week of Dec. 30 – Jan. 3 2019.csv
	*/
	)

