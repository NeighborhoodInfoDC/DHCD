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

  %local is_2006_fmt is_old_fmt is_v3_fmt notice_count_total wrote_obs NOTICE_NAMES_BEGIN;
  
  %** List of beginnings of notice names used to identify possible notices **;
  
  %let NOTICE_NAMES_BEGIN = 
         '2-4 rental',
         '5+ rental',
         'assignment of',
         'condominium',
         'conversion -',
         'conversion election',
         'conversion exemption',
         'cooperative conversion',
         'd.c. opportunity to purchase',
         'dopa notice',
         'election correspondence',
         'exemption from',
         'foreclosure',
         'housing assistance payment',
         'low income equity',
         'not-a-housing',
         'not a housing',
         'notice of',
         'notices of',
         'offer of sale',
         'offers of sale',
         'other filings',
         'petitions for',
         'property tax abatement',
         'raze permit',
         'right of first',
         'sale and transfer -',
         'sfd',
         'single family dwelling',
         'tax abatement',
         'tenant association registration',
         'tenant conversion',
         'tenant election',
         'tenant organization registration',
         'topa complaint',
         'topa letter',
         'vacancy / coop exemption',
         'vacancy exemption'
       ;

  filename inf  "&path\&file" lrecl=2000;
  
  ** Check input file version **;

  %let is_2006_fmt = 0;
  %let is_old_fmt = 0;
  %let is_v3_fmt = 0;
  
  /*
  ** Identify input file version **;
  
  data _null_;
    length inbuff $ 2000;  
    infile inf dsd missover obs=1;
    input inbuff;
    if inbuff = "Condominium and Cooperative Conversion and Sales Branch" then do;
      ** 2006 file format **;
      call symput( 'is_2006_fmt', '1' );
    end;
    else if inbuff = "Department of Housing and Community Development" then do;
      ** Old file format **;
      call symput( 'is_old_fmt', '1' );
    end;
    else if inbuff =: "DHCD CASD Mail Log" then do;
      ** Version 3 format, Jan 14, 2019 or later **;
      call symput( 'is_v3_fmt', '1' );
    end;
  run;
  */
  
  ** Read input data file **;
  
  %let notice_count_total = 0;
  
  data &out;
  
    length Notice_type $ 3 Orig_address Notes _item $ 1000 Source_file $ 120 inbuff $ 2000;
    
    retain Notice_type "" Notices 0 Source_file "%lowcase(&file)";
    retain _read_notice 0 _notice_count _notice_count_total .;

    infile inf missover pad;
    
    input inbuff $2000.;

    PUT _N_= inbuff=;
    
    ** Initialize record specific vars **;
    
    Notice_date = .u;
    Notes = "";
    
    _is_notice_rec = 0;
    _first_number = .;
    
    ** Remove multiple blanks **;
    
    inbuff = left( compbl( inbuff ) );
    
    _i = 1;
    _size = countw( inbuff, ',', 'q' );
    
    PUT _SIZE=;
    
    do _i = 1 to _size;
    
      _item = left( dequote( scan( inbuff, _i, ',', 'q' ) ) );
      PUT _I= _ITEM= ;
      
      if lowcase( _item ) in: ( 
          'condominium and cooperative conversion', 
          'weekly report', 
          'department of housing and community development',
          'rental conversion and sale division',
          'week ending'
        ) then do;
      
        PUT '** Generic labels/headers, ignore and skip to next row **';
        
        leave;
        
      end;
      
      else if _item = "" then do;
      
        PUT '** Blank entry, do nothing and go to next item **';
        
        continue;
              
      end;
      
      else if lowcase( _item ) in: ( &NOTICE_NAMES_BEGIN ) then do;
      
        PUT 'LOOKS LIKE A NOTICE!';
        
        _is_notice_rec = 1;
     
        if put( compress( upcase( _item ), ' .' ), $rcasd_text2type. ) ~= "" then do;
        
          Notice_type = put( compress( upcase( _item ), ' .' ), $rcasd_text2type. );
          
          PUT NOTICE_TYPE=;
                              
        end;
        else do;
        
          %err_put( macro=Rcasd_read_one_file, msg="Unrecognized notice type: file=&file " _n_= _item= )
          %err_put( macro=Rcasd_read_one_file, msg="Update Prog\RCASD\Make_formats_rcasd.sas to add this notice to RCASD formats." )
          
          Notice_type = "";
        
        end;
        
      end;
      
      else if input( _item, anydtdte40. ) >= '01jan2006'd then do;
      
        Notice_date = input( _item, anydtdte40. );
        
        PUT NOTICE_DATE=;
      
      end;
      
      else if prxmatch( '/\bstreet|avenue|road|place|terrace|court|ave|rd|st|terr|ter|ct\b/i', _item ) then do;
      
        ** Contains an address key word **;
      
        Orig_address = _item;
        
        PUT ORIG_ADDRESS=;
      
      end;

      else if prxmatch( '/\d+\s*\/\s*\$?[0-9,\.]+/', _item ) then do;
      
        Num_units = input( scan( _item, 1, '/' ), 8. );
        Sale_price = input( scan( _item, 2, '/' ), dollar16. );
        
        PUT NUM_UNITS= SALE_PRICE=;
      
      end;
      
      else if prxmatch( '/^\d+ *$/', _item ) then do;
      
        ** A plain number **;
        
        if missing( _first_number ) then do;
          _first_number = input( _item, 8. );
          PUT _FIRST_NUMBER=;
        end;
        else do;
          PUT 'UNKNOWN NUMBER: ' _item=;
        end;
        
      end;
      
      else do;
      
        PUT 'NO MATCH: ' _item=;
        
        Notes = left( trim( Notes ) || ' ' || left( _item ) );
        
      end;
      
    end;
    
    if _is_notice_rec then do;
    
      if not( missing( _first_number ) ) then do;
        if _notice_count > 0 then do;
          %warn_put( 
            macro=Rcasd_read_one_file, 
            msg='Notice count does not match # of notices read (previous notice). ' source_file= _n_= 
          )
        end;
        _notice_count = _first_number;
        _notice_count_total = sum( _notice_count_total, _notice_count );
        PUT _NOTICE_COUNT= _NOTICE_COUNT_TOTAL=;
      end;
      else do;
        _notice_count = .;
      end;
      
    end;

    PUT NOTICE_TYPE= NOTICE_DATE= ORIG_ADDRESS=;
    
    ** If read both notice type and an address, write notice record **;

    if not( missing( notice_type ) or missing( orig_address ) ) then do;
    
      PUT 'WRITE NOTICE!';

      output;
      
      if _notice_count > 0 then do;
        _notice_count = _notice_count - 1;
        PUT _NOTICE_COUNT=;
      end;
      else if _notice_count = 0 then do;
        %warn_put( 
          macro=Rcasd_read_one_file, 
          msg='Notice count does not match # of notices read. ' source_file= _n_= notice_type= notice_date= orig_address=
        )
      end;
      
      Notices + 1;
      
    end;

    *************************************************;

    PUT NOTICES= _NOTICE_COUNT_TOTAL= /;
    
 /***********
    ** Remove leading commas from input. Skip to next record if blank. **;
    
    i = verify( inbuff, ', ' );
    
    if i > 0 then inbuff = left( substr( inbuff, i ) );
    else return;
    
    ** Remove extra commas from input. **;
    
    do while ( find( inbuff, ',,' ) );
    
      inbuff = trim( substr( inbuff, 1, find( inbuff, ',,' ) - 1 ) ) ||
               left( substr( inbuff, find( inbuff, ',,' ) + 1 ) );
    
    end;
    
    PUT INBUFF=;
    
    if input( scan( inbuff, 1, ',', 'q' ), ??8. ) then do;
    
      Count = Count + input( scan( inbuff, 1, ',', 'q' ), ??8. );
      
      Notice_type = put( compress( upcase( scan( inbuff, 2, ',', 'q' ) ), ' .' ), $rcasd_text2type. );

    end;
    else if put( compress( upcase( scan( inbuff, 1, ',', 'q' ) ), ' .' ), $rcasd_text2type. ) ~= "" then do;
    
      Notice_type = put( compress( upcase( scan( inbuff, 1, ',', 'q' ) ), ' .' ), $rcasd_text2type. );

      Count = Count + input( scan( inbuff, 2, ',', 'q' ), ??8. );
      
    end;

    PUT COUNT= NOTICE_TYPE= /;
***********/

    call symput( 'wrote_obs', put( Notices, 12. ) );
    call symput( 'notice_count_total', put( _notice_count_total, 12. ) );

    format Notice_date mmddyy10. Notice_type $rcasd_notice_type.;
    
  run;


%MACRO SKIP;
  %if &is_2006_fmt %then %do;
  
    **** 2006 file format ****;

    data &out;

      length Notice_type $ 3 Orig_address Notes $ 1000 Source_file $ 120 inbuff inbuff2 $ 2000;
      
      retain Notice_type "" Count Notices 0 Source_file "%lowcase(&file)";

      infile inf dsd missover dlm='~' firstobs=4;
      
      input inbuff;
      PUT _N_= inbuff=;
      
      if input( scan( inbuff, 2, ',' ), ??8. ) > 0 then do;
        
        Count = Count + input( scan( inbuff, 2, ',' ), 8. );
        PUT COUNT=;
        
        call symput( 'input_count', put( Count, 12. ) );
        
        Notice_type = put( compress( upcase( scan( inbuff, 1, ',' ) ), ' .' ), $rcasd_text2type. );
        PUT NOTICE_TYPE=;
        
        if Notice_type = "" then do;
          %err_put( macro=, msg="Unrecognized notice type: file=&file " _n_= inbuff= )
          %err_put( macro=, msg="Update Prog\RCASD\Make_formats_rcasd.sas to add this notice to RCASD formats." )
        end;
        
        ***input Notice_date :mmddyy10. @; 
        input inbuff;
        PUT _N_= inbuff=;
        
        Notice_date = input( scan( inbuff, 2, ',', 'q' ), mmddyy10. );
        
        do while ( not missing( Notice_date ) );
        
          Orig_address = compress( scan( inbuff, 1, ',', 'q' ), '"' );
          
        /***
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
          ***/
          
          output;
          Notices + 1;
          
          input inbuff;
          PUT _N_= inbuff=;
        
          Notice_date = input( scan( inbuff, 2, ',', 'q' ), mmddyy10. );
          
        end;
        
        /*input;*/
        
      end;
      else do;
        /*input;*/
     end;
     
     call symput( 'wrote_obs', put( Notices, 12. ) );
     
     format Notice_type $rcasd_notice_type. Notice_date mmddyy10.;
     
     drop inbuff: count Notices;

    run;
    
  %end;

  %else %if &is_old_fmt %then %do;
  
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
        
        /*input;*/
        
      end;
      else do;
        /*input;*/
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
      
      do while ( left( upcase( inbuff ) ) in: ( 'CONVERSION', 'SALE AND TRANSFER' ) );
      
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
        
        if inbuff2 = '(EMPTY)' then do;
          inbuff2 = left( scan( inbuff, 3, '|' ) );
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
  
  %MEND SKIP;
    
  filename inf clear;
  
  %** Check whether observations were written to file and that number of notices matches counts provided (if any) **;
  
  %if &wrote_obs > 0 %then %do;
    %Note_mput( macro=Rcasd_read_one_file, msg=&wrote_obs notices read from &file.. )
    %if &notice_count_total > 0 and &wrote_obs ~= &notice_count_total %then %do;
      %Warn_mput( macro=Rcasd_read_one_file, msg=Read notices not equal to input file count of %left(&notice_count_total) notices. )
    %end;
  %end;
  %else %do;
    %Err_mput( macro=Rcasd_read_one_file, msg=No notices read from &file.. )
  %end;

  /**/
  proc print data=&out;
    by Source_file;
    var Notice_date Notice_type Orig_address Notes Num_units Sale_price;
  run;
  /**/

%mend Rcasd_read_one_file;

