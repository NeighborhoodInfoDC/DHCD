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

%macro Rcasd_read_all_files( year=, fileid=, infilelist=, path=&_dcdata_r_path\DHCD\Raw\RCASD );
 
  %local i v out outlist;
  
  %if &_remote_batch_submit %then %let out = DHCD.Rcasd_&year._&fileid;
  %else %let out = Work.Rcasd_&year._&fileid;
  
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

  data _Rcasd_read_all_files_1;

    length Nidc_id $ 12;
    
    retain Doc_num 1;
    
    set &outlist;

    Nidc_id = "&year-&fileid-" || left( put( doc_num, z3. ) );
    
    doc_num + 1;

    drop doc_num;

  run;
  
  ** Split out individual addresses **;
  
  %Rcasd_address_parse( data=_Rcasd_read_all_files_1, out=_Rcasd_read_all_files_addr, id=Nidc_id, addr=Orig_address )
  
  data &out;
  
    merge
      _Rcasd_read_all_files_1
      _Rcasd_read_all_files_addr;
    by Nidc_id;
    
  run;

  %File_info( data=&out, printobs=5, freqvars=Notice_type )
    
  data export;
  
    set &out (keep=Nidc_id Address);
    
  run;
    
  filename fexport "&_dcdata_l_path\dhcd\raw\rcasd\&out._geocode.csv" lrecl=2000;

  proc export data=export
      outfile=fexport
      dbms=csv replace;

  run;

  filename fexport clear;

%mend Rcasd_read_all_files;

