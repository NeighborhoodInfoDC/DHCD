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
  year=2024,
  infilelist=
    Weekly TOPA Report January 1-5.txt
    Weekly TOPA Report January 8-12.txt
    Weekly TOPA Report January 15-19.txt
    Weekly TOPA Report January 22-26.txt
    Weekly TOPA Report January 29-February 2.txt
    Weekly TOPA Report February 5-9 revised.txt
    Weekly TOPA Report February 12-16.txt
    Weekly TOPA Report February 19-23.txt
    Weekly TOPA Report February 26-March 1.txt
    Weekly TOPA Report March 4-8.txt
    Weekly TOPA Report March 11-15.txt
    Weekly TOPA Report March 18-22.txt
    Weekly TOPA Report March 25-29.txt
    Weekly TOPA Report April 1-5.txt
    Weekly TOPA Report April 8-12.txt
    Weekly TOPA Report April 15-19.txt
    Weekly TOPA Report April 22-26.txt
    Weekly TOPA Report April 29-May 3.txt
    Weekly TOPA Report May 6-10.txt
    Weekly TOPA Report May 13-17.txt
    Weekly TOPA Report May 20-24.txt
    Weekly TOPA Report May 27-31.txt
    Weekly TOPA Report June 3-7.txt
    Weekly TOPA Report June 10-14.txt
    Weekly TOPA Report June 17-21.txt
    Weekly TOPA Report June 24-28.txt
    Weekly Report on Tenant Opportunity to Purchase Act %28TOPA%29 Filings %28July 1-5%29 .txt
    Weekly TOPA Report July 8-12.txt
    Weekly TOPA Report July 15-19.txt
    Weekly TOPA Report July 22-26.txt
    Weekly TOPA Report July 29-August 2.txt
    Weekly TOPA Report July August 5-9.txt
    Weekly TOPA Report August 12-16.txt
    Weekly TOPA Report August 19-23.txt
    Weekly TOPA Report August 26-30.txt
    Weekly TOPA Report September 2-6.txt
    Weekly TOPA Report September 9-13.txt
    Weekly TOPA Report September 16-20.txt
    Weekly TOPA Report September 23-27.txt
    Weekly TOPA Report September 30-October 4.txt
    Weekly TOPA Report October 7-11.txt
    Weekly TOPA Report October 14-18.txt
    Weekly TOPA Report October 21-25.txt
    Weekly TOPA Report October 28-Noveber 1.txt
    Weekly TOPA Report Noveber 4-8.txt
    Weekly TOPA Report Noveber 11-15.txt
    Weekly TOPA Report Noveber 18-22.txt
    Weekly TOPA Report November 25-29.txt
    Weekly TOPA Report December 2 - December 6%2C 2024.txt
    Weekly TOPA Report December 9 - December 13%2C 2024.txt
    Weekly TOPA Report December 16 - December 20%2C 2024.txt
    Weekly TOPA Report December 23 - December 27%2C 2024.pdf.txt
)
