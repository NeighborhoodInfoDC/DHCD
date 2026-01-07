/**************************************************************************
 Program:  Rcasd_2023.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/29/2025
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
  revisions=%str(Rerun with updated geocoding macro.),
  year=2023,
  infilelist=
    Weekly TOPA Report Jan 2-6.txt
    Weekly TOPA Report Jan 9-13.txt
    Weekly TOPA Report January 16-20.txt
    Weekly TOPA Report January 23-27.txt
    Weekly TOPA Report January 30-February 3.txt
    Weekly TOPA Report January February 6-10.txt
    Weekly TOPA Report January February 13-17.txt
    Weekly TOPA Report February 20-24.txt
    Weekly TOPA Report February 27-March 3.txt
    Weekly TOPA Report March 6-10.txt
    Weekly TOPA Report March 13-17.txt
    Weekly TOPA Report March 20-24.txt
    Weekly TOPA Report March 27-31.txt
    Weekly TOPA Report April 3-7.txt
    Weekly TOPA Report April 10-14.txt
    Weekly TOPA Report April 17-21.txt
    Weekly TOPA Report April 24-28_edited.txt
    Weekly TOPA Report May 1-5.txt
    Weekly TOPA Report May 8-12.txt
    Weekly TOPA Report May 15-19.txt
    Weekly TOPA Report May 22-26.txt
    Weekly TOPA Report May 29-June 2 revised_edited.txt
    Weekly TOPA Report June 5-9.txt
    Weekly TOPA Report June 12-16.txt
    Weekly TOPA Report June 19-23.txt
    Weekly TOPA Report June 26-30_edited.txt
    Weekly TOPA Report July 3-7.txt
    Weekly TOPA Report July 10-14.txt
    Weekly TOPA Report July 17-21.txt
    Weekly TOPA Report July 24-28.txt
    Weekly TOPA Report July 31-August 4_edited.txt
    Weekly TOPA Report August 7-11.txt
    Weekly TOPA Report August 14-18.txt
    Weekly TOPA Report August 21-25.txt
    Weekly TOPA Report August 28-September 1_edited.txt
    Weekly TOPA Report September 4-8.txt
    Weekly TOPA Report September 11-15.txt
    Weekly TOPA Report September 18-22.txt
    Weekly TOPA Report September 25-29.txt
    Weekly TOPA Report October 2-6.txt
    Weekly TOPA Report October 9-13.txt
    Weekly TOPA Report October 16-20_0.txt
    Weekly TOPA Report October 23-27_edited.txt
    Weekly TOPA Report October 30 - November 3_edited.txt
    Weekly TOPA Report November 6-10.txt
    Weekly -OPA-Report-November-13-17.txt
    Weekly TOPA Report November 20-24.txt
    Weekly_TOPA_Report_November_27-December 1.txt
    Weekly TOPA Report December 4 - December 8.txt
    Weekly TOPA Report December 11 - December 15.txt
    Weekly_TOPA_Report_December_18-December_22_edited.txt
    Weekly TOPA Report December 25-29.txt
)
