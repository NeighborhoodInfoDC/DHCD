/**************************************************************************
 Program:  Rcasd_all.sas
 Library:  DHCD
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  12/10/25
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  121
 
 Description:  Create view that aggregates all TOPA notice data across years. 

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )

data DHCD.Rcasd_all (label="Rental Conversion and Sale Division, TOPA-related filings, 2012-2025") / view=DHCD.Rcasd_all;

  set
    DHCD.Rcasd_2012
    DHCD.Rcasd_2013
    DHCD.Rcasd_2014
    DHCD.Rcasd_2015
    DHCD.Rcasd_2016
    DHCD.Rcasd_2017
    DHCD.Rcasd_2018
    DHCD.Rcasd_2019
    DHCD.Rcasd_2020
    DHCD.Rcasd_2021
    DHCD.Rcasd_2022
    DHCD.Rcasd_2023
    DHCD.Rcasd_2024
    DHCD.Rcasd_2025
  ;
  by nidc_rcasd_id addr_num;

run;

%File_info( data=DHCD.Rcasd_all )

%Dc_update_meta_file(
  ds_lib=DHCD,
  ds_name=Rcasd_all,
  creator_process=Rcasd_all.sas,
  restrictions=None,
  revisions=%str(New file.)
)
