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

  %local is_old_fmt is_v3_fmt input_count wrote_obs;
  
  filename inf  "&path\&file" lrecl=1000;
  
  ** Check input file version **;

  %let is_old_fmt = 0;
  %let is_v3_fmt = 0;
  
  ** Identify input file version **;
  
  data _null_;
    length inbuff $ 2000;  
    infile inf dsd missover obs=1;
    input inbuff;
    if inbuff = "Department of Housing and Community Development" then do;
      ** Old file format **;
      call symput( 'is_old_fmt', '1' );
    end;
    else if inbuff =: "DHCD CASD Mail Log" then do;
      ** Version 3 format, Jan 14, 2019 or later **;
      call symput( 'is_v3_fmt', '1' );
    end;
  run;
  
  ** Read input data file **;
  
  %let wrote_obs = 0;

  %if &is_old_fmt %then %do;
  
    **** Old file format ****;

    data &out;

      length Notice_type $ 3 Orig_address Notes $ 1000 Source_file $ 120 inbuff inbuff2 $ 2000;
      
      retain Notice_type "" Count Notices 0 Source_file "%lowcase(&file)";

      infile inf dsd missover firstobs=6;
      
      input inbuff @;
      /*put _n_= inbuff=;*/
      
      if input( inbuff, ??8. ) > 0 then do;
        
        Count = Count + input( inbuff, 8. );
        
        call symput( 'input_count', put( Count, 12. ) );
        
        input inbuff;
        /*put _n_= count= inbuff=;*/
        
        Notice_type = put( compress( upcase( inbuff ), ' .' ), $rcasd_text2type. );
        
        if Notice_type = "" then do;
          %err_put( macro=, msg="Unrecognized notice type: file=&file " _n_= inbuff= )
          %err_put( macro=, msg="Update Prog\RCASD\Make_formats_rcasd.sas to add this notice to RCASD formats." )
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

  %else %if &is_v3_fmt %then %do;
  
    **** Version 3 file format (Jan 14, 2019 or later) ****;
    
    data &out;

      length Notice_type $ 3 Orig_address Notes $ 1000 Related_address Source_file $ 120 inbuff inbuff2 $ 2000;
      
      retain Notice_type "" Count Notices 0 Source_file "%lowcase(&file)";
      
      Notes = "";

      infile inf dsd missover firstobs=5;
      
      input @1 inbuff @;
      
      /***if scan( inbuff, 1, '|' ) in ( 'CONVERSION', 'SALE AND TRANSFER' ) then do;***/
      do while ( left( upcase( inbuff ) ) in: ( 'CONVERSION', 'SALE AND TRANSFER' ) );
      
        PUT "VERSION 3 FILE: " _N_= INBUFF=;
        inbuff = left( tranwrd( compbl( upcase( inbuff ) ), ' - ', ' | ' ) );

        i = index( inbuff, 'ITEM' );
        
        if i > 0 then do;
          j = index( reverse( substr( inbuff, 1, i - 1 ) ), '(' ) - 1;
          Count = Count + input( substr( inbuff, i - j, j ), 8. );
        end;
        else do;
          Count = .;
        end;
        
        call symput( 'input_count', put( Count, 12. ) );
        
        inbuff2 = left( scan( inbuff, 2, '|' ) );
        PUT INBUFF2= INBUFF=;
        
        if inbuff2 = '(EMPTY)' then do;
          inbuff2 = left( scan( inbuff, 3, '|' ) );
        PUT INBUFF2= INBUFF=;
          i = index( inbuff2, '(' );
          if i > 0 then inbuff2 = substr( inbuff2, 1, i - 1 );
        end;
      
        Notice_type = put( compress( left( inbuff2 ), " '.()" ), $rcasd_text2type. );
        
        if Notice_type = "" then do;
          %err_put( macro=, msg="Unrecognized notice type: file=&file " _n_= inbuff2= )
          %err_put( macro=, msg="Update Prog\RCASD\Make_formats_rcasd.sas to add this notice to RCASD formats." )
        end;
        
        Notice_date = .;
        
        ** Advance to first nonblank notice record **;
        
        do while( missing( Notice_date ) );
        
          input inbuff;
          
          input inbuff @;
          input Notice_date :mmddyy10. @; 
        
        end;          

        put _n_= count= Notice_date= inbuff= ;
        
        do while ( not missing( Notice_date ) );
        
          Num_units = .;
          Sale_price = .;
        
          input Orig_address Related_address @;
          input inbuff @;
          input inbuff @;
          input inbuff2;
          
          if inbuff ~= "" then do;
            Num_units = input( inbuff, 8. );
          end;
          
          if inbuff2 ~= "" then do;
            Sale_price = input( inbuff2, dollar16. );
          end;
          
          output;
          
          Notices + 1;

          call symput( 'wrote_obs', put( Notices, 12. ) );
          
          ** Advance to next record **;
          
          do while ( 1 );
          
            input inbuff @;
            
            Notice_date = .;
            
            if left( upcase( inbuff ) ) in: ( 'CONVERSION', 'SALE AND TRANSFER' ) then leave;

            input Notice_date :mmddyy10. @; 
            
            if not( missing( Notice_date ) ) then leave;
            else input;
            
          end;
          
        end;
        
        ***input;
        
      end;

      label Related_address = "Related address numbers";
      
      format Notice_type $rcasd_notice_type. Notice_date mmddyy10.;
      
      drop inbuff: count Notices i j;

    run;
    
  %end;
    
  %else %do;
  
    **** New file format (before Jan 14, 2019) ****;
    
    data &out;

      length Notice_type $ 3 Orig_address Notes $ 1000 Source_file $ 120 inbuff inbuff2 $ 2000;
      
      retain Notice_type "" Count Notices 0 Source_file "%lowcase(&file)";

      infile inf dsd missover firstobs=7;
      
      input inbuff @;
      input inbuff @;
      /*put _n_= inbuff=;*/
      
      if inbuff =: '# Received:' or input( inbuff, ??8. ) > 0 then do;
      
        if input( inbuff, ??8. ) > 0 then Count = Count + input( inbuff, 8. );
        else Count = Count + input( substr( inbuff, 12 ), 8. );
      
        call symput( 'input_count', put( Count, 12. ) );
        
        input inbuff @;
        input inbuff;
        /*put _n_= count= inbuff=;*/
        
        Notice_type = put( compress( upcase( inbuff ), " '.()" ), $rcasd_text2type. );
        
        if Notice_type = "" then do;
          %err_put( macro=, msg="Unrecognized notice type: file=&file " _n_= inbuff= )
          %err_put( macro=, msg="Update Prog\RCASD\Make_formats_rcasd.sas to add this notice to RCASD formats." )
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
    %if &wrote_obs ~= &input_count %then %do;
      %Warn_mput( macro=Rcasd_read_one_file, msg=Read notices not equal to input file count of &input_count.. )
    %end;
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

