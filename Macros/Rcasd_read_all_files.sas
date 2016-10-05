/**************************************************************************
 Program:  Rcasd_read_all_files.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/09/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read and process list of RCASD input CSV files.

 Modifications:
**************************************************************************/

%macro Rcasd_read_all_files( 
  year=, 
  infilelist=, 
  revisions=,
  path=&_dcdata_r_path\DHCD\Raw\RCASD\&year
);
 
  %local i v out outlib outlist;
  
  %if &_remote_batch_submit %then %let outlib = DHCD;
  %else %let outlib = Work;
  
  %let out = Rcasd_&year;
  
  %** Read individual input data sets **;

  %let i = 1;
  %let v = %scan( &infilelist, &i, %str( ) );
  %let outlist = ;

  %do %until ( %length(&v) = 0 );

    %Rcasd_read_one_file( file=&v, out=_rcasd_&i, path=&path )

    %let outlist = &outlist _rcasd_&i;
    
    %let i = %eval( &i + 1 );
    %let v = %scan( &infilelist, &i, %str( ) );

  %end;

  data _Rcasd_read_all_files;

    length Nidc_rcasd_id $ 12;
    
    retain Doc_num 1;
    
    set &outlist;
    
    if year( Notice_date ) ~= &year then do;
      %Warn_put( macro=Rcasd_read_all, msg="Notice not from &year. Will be dropped. " Notice_date= Source_file= )
      delete;
    end;
    else do;
      Nidc_rcasd_id = "&year-" || left( put( doc_num, z5. ) );
      doc_num + 1;
    end;

    drop doc_num;

  run;
  
  ** Split out individual addresses **;
  
  %Rcasd_address_parse( data=_Rcasd_read_all_files, out=_Rcasd_read_all_files_addr, id=Nidc_rcasd_id, addr=Orig_address )
  
  data _Rcsad_indiv_addr;
  
    merge
      _Rcasd_read_all_files
      _Rcasd_read_all_files_addr;
    by Nidc_rcasd_id;
    
  run;
  
  ** Run addresses through geocoder **;
  
  %DC_mar_geocode(
    geo_match=Y,
    data=_Rcsad_indiv_addr,
    out=&outlib..&out,
    staddr=address,
    zip=,
    id=Nidc_rcasd_id addr_num Source_file,
    ds_label="Rental Conversion and Sale Division, TOPA-related filings, &year",
    listunmatched=Y,
    streetalt_file=&_dcdata_l_path\DHCD\Prog\RCASD\StreetAlt.txt
  )
  
  proc datasets library=&outlib memtype=(data) nolist;
    modify &out (sortedby=Nidc_rcasd_id);
      label
        Nidc_rcasd_id = "NIDC unique RCASD notice ID"
        Notice_date = "Notice date"
        Notice_type = "RCASD notice type"
        Num_units = "Number of housing units (if applicable)"
        Orig_address = "Street address field from RCASD source file"
        Sale_price = "Sale price (if applicable)"
        Source_file = "RCASD data source file";
  quit;

  %File_info( data=&outlib..&out, printobs=5, freqvars=Notice_type )
  
  ** Create export data set **;
  
  filename fexport "&_dcdata_r_path\DHCD\Raw\RCASD\&out..csv" lrecl=2000;

  proc export data=&outlib..&out
      outfile=fexport
      dbms=csv replace;

  run;

  filename fexport clear;

  ** Cleanup temporary data sets **;

  proc datasets library=work nolist nowarn;
    delete _Rcasd_: /memtype=data;
  quit;
  
  %** Register metadata only if final batch submit **;
  
  %if &_remote_batch_submit %then %do;
  
    ** Register metadata **;

    proc sql noprint;
      select put( max( Notice_date ), mmddyy10. ) into :last_notice from &outlib..&out;
    quit;
    
    %if &revisions = %then %let revisions = Updated with notices through &last_notice..;
     
    %put revisions=&revisions;
    
    %Dc_update_meta_file(
      ds_lib=&outlib,
      ds_name=&out,
      creator_process=&out..sas,
      restrictions=None,
      revisions=%str(&revisions)
    )
    
  %end;
    
%mend Rcasd_read_all_files;

