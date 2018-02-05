/**************************************************************************
 Program:  Export_parcels_rent_control.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/06/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Export DHCD.Parcels_rent_control data set to CSV.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( RealProp )

/** Macro Export - Start Definition **/

%macro Export( data=, out=, desc= );

  %local lib file;
  
  %if %scan( &data, 2, . ) = %then %do;
    %let lib = work;
    %let file = &data;
  %end;
  %else %do;
    %let lib = %scan( &data, 1, . );
    %let file = %scan( &data, 2, . );
  %end;

  %if &out = %then %let out = &file;
  
  %if %length( &desc ) = 0 %then %do;
    proc sql noprint;
      select memlabel into :desc from dictionary.tables
        where upcase(libname)=upcase("&lib") and upcase(memname)=upcase("&file");
      quit;
    run;
  %end;

  filename fexport "&out_folder\&out..csv" lrecl=2000;

  proc export data=&data
      outfile=fexport
      dbms=csv replace;

  run;
  
  filename fexport clear;

  proc contents data=&data out=_cnt_&out (keep=varnum name label label="&desc") noprint;

  proc sort data=_cnt_&out;
    by varnum;
  run;      
  
  %let file_list = &file_list &out;

%mend Export;

/** End Macro Definition **/


/** Macro Dictionary - Start Definition **/

%macro Dictionary( );

  %local desc;

  ** Start writing to XML workbook **;
    
  ods listing close;

  ods tagsets.excelxp file="&out_folder\Data dictionary.xls" style=Normal 
      options( sheet_interval='Proc' orientation='landscape' );

  ** Write data dictionaries for all files **;

  %local i k;

  %let i = 1;
  %let k = %scan( &file_list, &i, %str( ) );

  %do %until ( &k = );
   
    proc sql noprint;
      select memlabel into :desc from dictionary.tables
        where upcase(libname)="WORK" and upcase(memname)=upcase("_cnt_&k");
      quit;
    run;

    ods tagsets.excelxp 
        options( sheet_name="&k" 
                 embedded_titles='yes' embedded_footnotes='yes' 
                 embed_titles_once='yes' embed_footers_once='yes' );

    proc print data=_cnt_&k label;
      id varnum;
      var name label;
      label 
        varnum = 'Col #'
        name = 'Name'
        label = 'Description';
      title1 bold "Data dictionary for file: &k..csv";
      title2 bold "&desc";
      title3 height=10pt "Prepared by NeighborhoodInfo DC on %left(%qsysfunc(date(),worddate.)).";
      footnote1;
    run;

    %let i = %eval( &i + 1 );
    %let k = %scan( &file_list, &i, %str( ) );

  %end;

  ** Close workbook **;

  ods tagsets.excelxp close;
  ods listing;

  run;
  
%mend Dictionary;

/** End Macro Definition **/


%global file_list out_folder;

** DO NOT CHANGE - This initializes the file_list macro variable **;
%let file_list = ;

** Fill in the folder location where the export files should be saved **;
%let out_folder = &_dcdata_r_path\DHCD\Raw\Export;


data Parcels_rent_control 
       (label="DC real property parcels possibly subject to rent control"
        drop=owner_add owner_add_count Ownername_count Trust1 Sub_all_proj Rent_controlled_2011);

  set Dhcd.Parcels_rent_control;
  
  label 
    owneraddress = "Owner's property tax address"
    owneraddress_std = 'Owner''s property tax address (standardized by %DC_Geocode)'
    Excluded_Nontaxable = "Excluded because nontaxable"
    Exempt_built1978 = "Exempt because built 1978 or later"
    AYB_assumption = "Properties built 1976 or later"
    AYB_missing = "Year built is missing"
    Exempt_assisted = "Exempt because assisted housing"
    Units_mar = "Unit count from MAR"
    Units_full = "Unadjusted full unit count (includes imputations)"
    Unit_count_pred_flag = "Unit count is imputed"
    units5plus_realprop = "Use code in OTR data is 5 units or more"
    adj_unit_count = "Adjusted full unit count (includes imputations)"
    units5plus_flag = "Property has 5 or more units"
    adj_unit_count_owner_add_sum = "Total units with same owner address"
    adj_unit_count_ownername_sum = "Total units with same owner name"
    owns5plus_assump_flag = "Same owner address or name has 5 or more units"
    Exempt_lt5units_ALL = "Owner has fewer than 5 units"
    Indiv = "Owner is an individual"
    Exempt_lt5units_Indiv = "Exempt because owner is individual with fewer than 5 units"
    Exempt_govowned = "Exempt because US or DC-government owned"
    Excluded_Foreign = "Exempt because foreign government owned"
    Trust_flag = "Owner is a trust"
    Rent_controlled = "Possibly subject to rent control (no identifiable exemptions or exclusions)"
    Receive_Exempt = "Has one or more rent control exemptions";
    
  format 
    Excluded_Nontaxable Exempt_built1978 AYB_assumption
    AYB_missing Exempt_assisted owns5plus_assump_flag
    Exempt_lt5units_ALL Indiv Exempt_lt5units_Indiv OwnerDC
    Exempt_govowned Excluded_Foreign Trust_flag Receive_Exempt
    Unit_count_pred_flag units5plus_realprop units5plus_flag
    dyesno.;
    
run;

%File_info( data=Parcels_rent_control, stats=n min max, printobs=0 )


** Export individual data sets **;
%Export( data=Parcels_rent_control )

** Create data dictionary **;
%Dictionary()

run;

