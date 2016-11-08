/**************************************************************************
 Program:  Rcasd_read_one_file.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/09/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read one RCASD input CSV file into a SAS data set.

 Modifications:
**************************************************************************/

%macro Rcasd_read_one_file( file=, path=, out= );

  %local is_old_fmt wrote_obs;
  
  ** Check input file version **;

  %let is_old_fmt = 0;
  
  filename inf  "&path\&file" lrecl=1000;
  
  data _null_;
    length inbuff $ 2000;  
    infile inf dsd missover obs=1;
    input inbuff;
    if inbuff = "Department of Housing and Community Development" then do;
      call symput( 'is_old_fmt', '1' );
    end;
  run;
  
  ** Read input data file **;
  
  %let wrote_obs = 0;

  %if &is_old_fmt %then %do;
  
    **** Old file format ****;

    data &out;

      length Notice_type $ 3 Orig_address Notes $ 160 Source_file $ 120 inbuff inbuff2 $ 2000;
      
      retain Notice_type "" Count Notices 0 Source_file "%lowcase(&file)";

      infile inf dsd missover firstobs=6;
      
      input inbuff @;
      /*put _n_= inbuff=;*/
      
      if input( inbuff, ??8. ) > 0 then do;
        
        Count = input( inbuff, 8. );
        
        input inbuff;
        /*put _n_= count= inbuff=;*/
        
        Notice_type = put( compress( upcase( inbuff ), ' .' ), $rcasd_text2type. );
        
        if Notice_type = "" then do;
          %err_put( macro=, msg="Unrecognized notice type: file=&file " _n_= inbuff= )
          %err_put( macro=, msg="No further records will be read from this file." )
          stop;
        end;
        
        input Notice_date :mmddyy10. @; 
          
        do while ( not missing( Notice_date ) );
        
          Num_units = .;
          Sale_price = .;

          input Orig_address inbuff inbuff2;
          
          if inbuff ~= "" then do;
            if prxmatch( '/\d+\s*\/\s*\$?[0-9,\.]+/', inbuff ) then do;
              Num_units = input( scan( inbuff, 1, '/' ), 8. );
              Sale_price = input( scan( inbuff, 2, '/' ), dollar16. );
            end;
            else do;
              Notes = left( compbl( inbuff ) );
            end;
          end;
          
          if prxmatch( '/\d+\s*\/\s*\$?[0-9,\.]+/', inbuff2 ) then do;
            Num_units = input( scan( inbuff2, 1, '/' ), 8. );
            Sale_price = input( scan( inbuff2, 2, '/' ), dollar16. );
          end;
          
          output;
          Notices + 1;
          
          input Notice_date :mmddyy10. @; 
          
        end;
        
        input;
        
      end;
      else do;
        input;
     end;
     
     call symput( 'wrote_obs', put( Notices, 12. ) );
     
     format Notice_type $rcasd_notice_type. Notice_date mmddyy10.;
     
     drop inbuff: count Notices;

    run;
    
  %end;
  %else %do;
  
    **** New file format ****;
    
    data &out;

      length Notice_type $ 3 Orig_address Notes $ 160 Source_file $ 120 inbuff inbuff2 $ 2000;
      
      retain Notice_type "" Count Notices 0 Source_file "%lowcase(&file)";

      infile inf dsd missover firstobs=7;
      
      input inbuff @;
      input inbuff @;
      /*put _n_= inbuff=;*/
      
      if inbuff =: '# Received:' or input( inbuff, ??8. ) > 0 then do;
      
        if input( inbuff, ??8. ) > 0 then Count = input( inbuff, 8. );
        else Count = input( substr( inbuff, 12 ), 8. );
      
        input inbuff @;
        input inbuff;
        /*put _n_= count= inbuff=;*/
        
        Notice_type = put( compress( upcase( inbuff ), ' .()' ), $rcasd_text2type. );
        
        if Notice_type = "" then do;
          %err_put( macro=, msg="Unrecognized notice type: file=&file " _n_= inbuff= )
          %err_put( macro=, msg="No further records will be read from this file." )
          stop;
        end;
        
        input inbuff @;
        input inbuff @;
        input Notice_date :mmddyy10. @; 
        
        do while ( not missing( Notice_date ) );
        
          Num_units = .;
          Sale_price = .;
        
          input Orig_address inbuff inbuff2;
          
          if inbuff ~= "" then do;
            if prxmatch( '/\d+\s*\/\s*\$?[0-9,\.]+/', inbuff ) then do;
              Num_units = input( scan( inbuff, 1, '/' ), 8. );
              Sale_price = input( scan( inbuff, 2, '/' ), dollar16. );
            end;
            else do;
              Notes = left( compbl( inbuff ) );
            end;
          end;
          
          if prxmatch( '/\d+\s*\/\s*\$?[0-9,\.]+/', inbuff2 ) then do;
            Num_units = input( scan( inbuff2, 1, '/' ), 8. );
            Sale_price = input( scan( inbuff2, 2, '/' ), dollar16. );
          end;
          
          output;
          Notices + 1;
          
          input inbuff @;
          input inbuff @;
          input Notice_date :mmddyy10. @; 
          
        end;
        
        input;
        
      end;
      else do;
        input;
     end;
     
     call symput( 'wrote_obs', put( Notices, 12. ) );
     
     format Notice_type $rcasd_notice_type. Notice_date mmddyy10.;
     
     drop inbuff: count Notices;

    run;
    
  %end;
    
  filename inf clear;
  
  %** Check whether observations were written from file **;
  
  %if &wrote_obs > 0 %then %do;
    %Note_mput( macro=Rcasd_read_one_file, msg=&wrote_obs notices read from &file.. )
  %end;
  %else %do;
    %Err_mput( macro=Rcasd_read_one_file, msg=No notices read from &file.. )
  %end;

  /*
  proc print data=&out;
    var Notice_date Notice_type Orig_address Notes Source_file Num_units Sale_price;
  run;
  */

%mend Rcasd_read_one_file;

