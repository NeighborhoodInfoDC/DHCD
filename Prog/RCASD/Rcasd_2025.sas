/**************************************************************************
 Program:  Rcasd_2024.sas
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
  revisions=%str(New file.),
  year=2025,
  infilelist=
  
    Weekly TOPA Report December 30 - January 3%2C 2025.txt
    Weekly TOPA Report January 6-10.txt
    Weekly TOPA Report January 13-17.txt
    Weekly TOPA Report January 20-24.txt
    Weekly TOPA Report January 27-31.txt
    Weekly TOPA Report February 3-7.txt
    Weekly TOPA Report February 10-14.txt
    Weekly TOPA Report February 17-21.txt
    Weekly TOPA Report February 24-28.txt
    Weekly TOPA Report March 3-7.txt
    Weekly TOPA Report March 10-14 revised_edited.txt
    Weekly TOPA Report March 17-21_edited.txt
    Weekly TOPA Report March 24-28.txt
    Weekly TOPA Report March 31-April 4_edited.txt
    Weekly TOPA Report April 7-11.txt
    Weekly TOPA Report April 14-18.txt
    Weekly TOPA Report April 21-25.txt
    Weekly TOPA Report April 28-May 2.txt
    Weekly TOPA Report May 5-9.txt
    Weekly TOPA Report May 12-16 edited.txt
    Weekly TOPA Report May 19-23.txt
    Weekly TOPA Report May 26-30.txt
    Weekly TOPA Report June 2-6.txt
    Weekly TOPA Report June 9-13.txt
    Weekly TOPA Report June 16-20.txt
    Weekly TOPA Report June 23-27_edited.txt
    Weekly TOPA Report June 30-July 4.txt
    Weekly TOPA Report July 7-11.txt
    Weekly TOPA Report July 14-18.txt
    Weekly TOPA Report July 21-25_edited.txt
    Weekly TOPA Report July 28-August 1.txt
    Weekly TOPA Report August 4-8_edited.txt
    Weekly TOPA Report August 11-15.txt
    Weekly TOPA Report August 18-22.txt
    Weekly TOPA Report August 25-29.pdf.txt
    Weekly TOPA Report September 1-5.txt
    Weekly TOPA Report September 8-12.txt
    Weekly TOPA Report Septeber 15-19.txt
    Weekly TOPA Report Septeber 22-26.txt
    Weekly TOPA Report Septeber 29-October 3.txt
    Weekly TOPA Report October 6-10.txt
    CORRECTION - Weekly TOPA Report October 13-17_edited.txt
    Weekly TOPA Report October 20-24_0.txt
    Weekly TOPA Report October 27-31.txt
    Weekly TOPA Report November 3-7.txt
    Weekly TOPA Report November 10-14.txt
    Weekly TOPA Report November 17-21.txt
    Weekly TOPA Report November 24-28_edited.txt

)
