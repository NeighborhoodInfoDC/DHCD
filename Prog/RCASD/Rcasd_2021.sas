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
      report_3.csv  /** 1/26 **/
      
      report_4.csv  /** 2/4 **/
      report (4).csv  /** 2/8 to 2/12 **/
      report (1)_0_edited.csv  /** 2/16 to 2/17 **/
      report (3).csv  /** 2/22 to 2/26 **/
      
      report (5)_edited.csv  /** 3/1 to 3/5 **/
      TOPA report March 8 - March 12.csv
      Weekly Report March 15 - March 19_rev_edited.csv
      report_5.csv  /** 3/22 to 3/26 **/
      March 29 - April 2_edited.csv
      
      report (3)_0.csv  /** 4/5 to 4/8 **/
      Weekly Report April 12 - April 16.csv
      report (1)_1.csv  /** 4/19 to 4/23 **/
      report (4)_0.csv  /** 4/26 to 4/29 **/
      
      report (5)_0.csv  /** 5/3 to 5/6 **/
      report (6).csv  /** 5/17 to 5/20 **/
      May 24- May 28.csv
      May 31- June 4.csv
      
      Report for week of June 7-11.csv
      Weekly Report 06.18.2021.csv  /** 6/14 to 6/16 **/
      Week of June 21-25.csv
      Week of June 28-July 1.csv

      Weekly TOPA Report July 5 - 9.csv
      Weekly TOPA Report July 12-16.csv
      Weekly Report July 19-23.csv
      July 26-30_edited.csv
      
      Weekly TOPA Report August 2-6.csv
      Weekly TOPA Report August 9-13_new_edited.csv
      Weekly TOPA Report August 16-20_edited.csv
      Weekly TOPA Report August 23-27_new_edited.csv
      Weekly TOPA Report August 31-September 3.csv

      Weekly TOPA Report September 6-10_edited.csv
      Weekly TOPA Report September 13-17.csv
      Weekly TOPA Report September 20-24_edited.csv
      Weekly TOPA Report September 27- October 1.csv

      Weekly TOPA Report October 4-8_edited.csv
      Weekly TOPA Report October 11-15_edited.csv
      Oct 18-22.csv
      Weekly TOPA Report October 25-29.csv
      
      Weekly TOPA Report November 1-5.csv
      Weekly TOPA Report November 8-12.csv
      Weekly TOPA Report November 15-19.csv
      Weekly TOPA Report November 22-26.csv
      Weekly TOPA Report November 28-December 3_edited.csv
      
      Weekly TOPA Report December 6-10.csv
      Weekly TOPA Report December 13-17.csv
      Weekly TOPA Report December 20-24.txt
      Weekly TOPA Report December 27-31.txt
      
	)
