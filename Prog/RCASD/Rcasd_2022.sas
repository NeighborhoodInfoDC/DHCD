/**************************************************************************
 Program:  Rcasd_2022.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/27/2025
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
  year=2022, 
  infilelist=

    Weekly_Report_on_TOPA_Filings_January_3-7.txt
    Weekly_Report_on_TOPA_Filings_January_10-14.txt
    Weekly_Report_on_TOPA_Filings_January_17-21.txt
    Weekly_Report_on_TOPA_Filings_January_24-28.txt
    Weekly_Report_on_TOPA_Filings_January_31-February_4.txt

    Weekly_Report_on_TOPA_Filings_February_7-11.txt
    Weekly_Report_on_TOPA_Filings_February_14-18.txt
    Weekly_Report_on_TOPA_Filings_February_21-25.txt
    Weekly_Report_on_TOPA_Filings_February_28-March_4.txt
    
    Weekly_Report_on_TOPA_Filings_March_7-11.txt
    Weekly_Report_on_TOPA_Filings_March_14-18.txt
    Weekly_Report_on_TOPA_Filings_March_21-25.txt
    Weekly_Report_on_TOPA_Filings_March_28-April_1.txt

    Weekly_Report_on_TOPA_Filings_April_4-8.txt
    Weekly_Report_on_TOPA_Filings_April_11-15.txt
    Weekly_Report_on_TOPA_Filings_April_18-22.txt
    Weekly_Report_on_TOPA_Filings_April_25-29.txt
    
    Weekly_Report_on_TOPA_Filings_May_2-6.txt
    weekly_Report_on_TOPA_Filings_May_9-13_edited.txt
    Weekly_Report_on_TOPA_Filings_May_16-20.txt
    Weekly_Report_on_TOPA_Filings_May_23-27_edited.txt
    Weekly_Report_on_TOPA_Filings_May_30-June_3.txt

    Weekly_Report_on_TOPA_Filings_June_6-10.txt
    weekly_Report_on_TOPA_Filings_June_13-17.txt
    Weekly_Report_on_TOPA_Filings_June_20-24.txt
    Weekly_Report_on_TOPA_Filings_June_27-July_1.txt

    Weekly_Report_on_TOPA_Filings_July_4-8.txt
    Weekly_Report_on_TOPA_Filings_July_11-15.txt
    Weekly_Report_on_TOPA_Filings_July_18-22_edited.txt
    Weekly_Report_on_TOPA_Filings_July_25-29_edited.txt

    Weekly_Report_on_TOPA_Filings_August_1-5.txt
    Weekly_Report_on_TOPA_Filings_August_8-12.txt
    Weekly_Report_on_TOPA_Filings_August_15-19.txt
    Weekly_Report_on_TOPA_Filings_August_22-26_edited.txt
    Weekly_Report_on_TOPA_Filings_August_29-September_2.txt
    
    Weekly_Report_on_TOPA_Filings_September_5-9_edited.txt
    Weekly_Report_on_TOPA_Filings_September_12-16.txt
    Weekly_Report_on_TOPA_Filings_September_19-23.txt
    Weekly_Report_on_TOPA_Filings_Septebmer_26-30_edited.txt

    Weekly TOPA Report October 3-7.txt
    Weekly TOPA Report October 10-14.txt
    report_11.txt
    Weekly TOPA Report October 24-28.txt
    Weekly TOPA Report October 31- November 4.txt

    Weekly TOPA Report November 7-11_edited.txt
    Weekly TOPA Report November 14-18.txt
    Weekly TOPA Report November 21-25.txt
    Weekly TOPA Report November 28-December 2.txt
    
    Weekly TOPA Report December 5-9.txt
    Weekly TOPA Report December 12-16.txt
    Weekly TOPA Report December 19-23.txt
    Weekly TOPA Report December 26-30.txt	
)
