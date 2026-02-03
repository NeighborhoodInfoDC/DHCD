/**************************************************************************
 Program:  Rcasd_read_one_file.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/09/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)

 Description:  Read one RCASD input CSV file into a SAS data set.
 
 Special tags added to input data sets:
   [SKIP] Add to start of row to skip processing that row entirely.
   [NOTE] Add to start of an item to indicate that entry should be processed as a note.
   [NO ADDRESS] Add to an item to indicate that it should be treated as an address entry,
                even though no address was provided.
   [END NOTICE] Add as a row after all notice entries have been processed.
                (Clears previous notice info.)

 Modifications:
**************************************************************************/

%macro Rcasd_read_one_file( file=, path=, out= );

  %local notice_count_total wrote_obs NOTICE_NAMES_BEGIN file_type;
  
  %let file_type = %lowcase( %scan( &file, -1, . ) );
  
  %** List of beginnings of notice names used to identify possible notices **;
  
  %let NOTICE_NAMES_BEGIN = 
         '2-4 rental',
         '2-4 units notice',
         '2-4 units offer',
         '2-4 units right',
         '5+ rental',
         '5+ units notice',
         '5+ units offer',
         '5+ units right',
         'application for',
         'assignment of',
         'complaint',
         'condominium',
         'conversion -',
         'conversion election',
         'conversion exemption',
         'conversion fee',
         'cooperative conversion',
         'd.c. opportunity to purchase',
         'dc opportunity to purchase',
         'disability survey',
         'dopa notice',
         'election correspondence',
         'election request',
         'exemption from',
         'exemption request',
         'exemption applications',
         'foreclosure',
         'housing assistance payment',
         'intent to',
         'letter of',
         'limited equity share cooperative conversion',
         'low income equity',
         'miscellaneous information',
         'not-a-housing',
         'not a housing',
         'notice of',
         'notices of',
         'offer of sale',
         'offers of sale',
         'ofs (',
         'other filings',
         'other offer of sale',
         'petition for',
         'petitions for',
         'property tax abatement',
         'raze permit',
         'right of first',
         'rights of first',
         'sale and transfer -',
         'sales contract',
         'sfd claim',
         'sfd letter',
         'sfd notice',
         'sfd offer',
         'sfd right',
         'single family dwelling',
         'statement of',
         'stmt of',
         'tax abatement',
         'tenant association registration',
         'tenant conversion',
         'tenant election',
         'tenant organization registration',
         'tenant response',
         'tenant statement',
         'tenants notice',
         'termination',
         'topa assignment',
         'topa complaint',
         'topa letter',
         'vacancy /',
         'vacancy application',
         'vacancy exemption',
         've ',
         'v.e.',
         'warranty security release'
       ;

  filename inf  "&path\&file" lrecl=2000;
  
  ** Read input data file **;
  
  %let notice_count_total = 0;
  
  data &out;
  
    length Notice_type $ 3 Orig_notice_desc $ 200 Orig_address Notes _item $ 1000 
           Source_file $ 120 _inbuff _inbuff2 _address_key_words $ 2000;
    
    retain Notice_type "" Orig_notice_desc "" _notices 0 Source_file "%lowcase(&file)";
    retain _read_notice 0 _notice_count _notice_count_total .;

    _address_key_words = cats(
      '/',
      '\balley\b|\bstreet\b|\bavenue\b|\bboulevard\b|\bcircle\b|\broad\b|\bplace\b|',
      '\bsquare\b|\bterrace\b|\bcourt\b|\bcrescent\b|\bdrive\b|\blane\b|\bparkway\b|\bwalk\b|\bway\b|',
      '\bave\b|\bblvd\b|\bdr\b|\brd\b|\bst\b|\bterr\b|\bter\b|\bct\b|\bpl\b',
      '/i'
    );

    infile inf missover pad;
    
    input _inbuff $2000.;

    /**PUT _N_= _inbuff=;**/
    
    ** Remove funky characters **;
    
    _inbuff = left( compress( _inbuff, "?–" ) );
    
    ** Initialize record specific vars **;
    
    Notice_date = .u;
    Notes = "";
    
    _is_notice_rec = 0;
    _first_number = .;
    
    %if &file_type = txt %then %do;
    
      ** Filter out time stamps in notice dates (eg, 10-09-2023 08:00 PM) **;
      
      _inbuff = prxchange( 's/^(\d\d-\d\d-\d\d\d\d)\s+\d\d:\d\d (AM|PM)/$1    /i', 1, _inbuff );
    
      ** Add comma delimiters for TXT file type **;

      ** Replace sequences of 3 blanks or more with a tilde (~) **;
      
      _inbuff2 = prxchange( 's/\s\s\s+/~/', -1, _inbuff );
      _inbuff = "";
      
      /**PUT _inbuff2=;**/
      
      ** Clean up items and create new comma-delimited list **;
      
      _i = 1;
      _item = scan( _inbuff2, _i, '~' );
      
      do while ( not( missing( _item ) ) );
      
        if indexc( _item, ',' ) then _item = quote( trim( _item ) );
        else _item = prxchange( 's/^(\d+)\s+(\d+)\s*$/$1,$2/', 1, _item );

        if _item ~= "" then _inbuff = catx( ',', _inbuff, _item );
        
        _i = _i + 1;
        _item = scan( _inbuff2, _i, '~' );
      
      end;

      /**PUT _inbuff=;**/
      
    %end;
    %else %do;
    
      _inbuff2 = "";
      
    %end;
    
    ** Separate parenthetical notes **;
    
    _inbuff = prxchange( 's/\(Note: +(.*)\)/,$1/i', 1, _inbuff );
    
    ** Remove multiple blanks **;
    
    _inbuff = left( compbl( _inbuff ) );
    
    _i = 1;
    _size = countw( _inbuff, ',', 'q' );
    
    /**PUT _SIZE=;**/
    
    ** Process each item in _inbuff **;
    
    do _i = 1 to _size;
    
      _item = left( dequote( scan( _inbuff, _i, ',', 'q' ) ) );
      /**PUT _I= _ITEM= ;**/
      
      ** Remove 'Sale and Transfer -' from start of notice label **;
      _item = left( prxchange( 's/^sale and transfer -/ /i', 1, _item ) );
      /**PUT _ITEM= ;**/
        
      ** Remove ' - (empty)' text from notice label **;
      _item = left( compbl ( prxchange( 's/(- |)\(empty\)( -|)/ /i', -1, _item ) ) );
      ***_item = compbl( tranwrd( _item, '- (empty)', '' ) );
      /**PUT _ITEM= ;**/
        
      if lowcase( _item ) in: ( 
          'condominium and cooperative conversion', 
          'conversion election report'
          'created by',
          'election report',
          'exemption report',
          'weekly report', 
          'updated weekly report',
          'department of housing and community development',
          'rental conversion and sale division',
          'week ending',
          'conversion fee or exemption applications',
          'election correspondence, materials and notices to vacate',
          'offer of sale correspondence /',
          'offer of sale, misc.',
          '[skip]'
        ) then do;
      
        /**PUT '** Generic labels/headers, ignore and skip to next row **';**/
        
        Notice_type = '';
        Orig_notice_desc = '';
        
        leave;
        
      end;
      
      else if _item = "" then do;
      
        /**PUT '** Blank entry, do nothing and go to next item **';**/
        
        continue;
              
      end;
      
      else if lowcase( _item ) = '[end notice]' then do;
      
        /**PUT '** Stop reading current notice **';**/
      
        Notice_type = '';
        Orig_notice_desc = '';
        _notice_count = .;
        
      end;        
      
      else if lowcase( _item ) =: '[note]' then do;
      
        /**PUT '** Tagged as a note **';**/
        
        Notes = left( trim( Notes ) || ' ' || left( substr( _item, 7 ) ) );
        
      end;
      
      else if lowcase( _item ) in: ( &NOTICE_NAMES_BEGIN ) then do;
      
        /**PUT 'LOOKS LIKE A NOTICE!';**/
        
        ** Check for '(n Items)' in label **;
        
        _p = prxmatch( '/\(\d+ item(s|)( record(s|)|)\)/i', _item );
        
        if _p > 0 then do;
        
          _first_number = input( scan( substr( _item, _p + 1 ), 1 ), 8. );
          /**PUT _FIRST_NUMBER= ;**/
          
          _item = substr( _item, 1, _p - 1 );
          /**PUT _ITEM= ;**/
        
        end;
        
        ** Do not flag as new notice record if an offer of sale notice with or without contract **;
        
        if not( Notice_type in ( '208', '209', '210', '220', '221', '224', '225', '228', '229', '900' ) and lowcase( _item ) =: 'offer of sale w' ) then do;
          _is_notice_rec = 1;
          Orig_notice_desc = _item;
        end;
        
        /**PUT _IS_NOTICE_REC=;**/
        
        ** Check for offer of sale (OFS) notices **;
        
        if prxmatch( '/offer of sale|offers of sale|ofs \(/i', _item ) and not( prxmatch( '/response|correspondence|information|documents/i', _item ) ) then do;
        
          /**PUT '** This is an offer of sale notice **';**/
          
          if prxmatch( '/w\/( |)contract/i', _item ) then do;
          
            ** OFS with a contract **;
            
            ** Check property size **;
            
            select;
              when ( prxmatch( '/sfd|\bsf\b|\bsdf\b|single family/i', _item ) )
                Notice_type = '220';
              when ( prxmatch( '/2 to 4|2-4|\(2\+4\)/i', _item ) )
                Notice_type = '224';
              when ( prxmatch( '/5 or more|5+/i', _item ) )
                Notice_type = '228';
              otherwise do;
                ** No property size given **;
                %err_put( macro=Rcasd_read_one_file, msg="Notice of sale without property size: file=&file " _n_= _item= )
              end;
            end;

          end;
          
          else if prxmatch( '/w\/o contract/i', _item ) then do;
          
            ** OFS without a contract **;
            
            ** Check property size **;
            
            select;
              when ( prxmatch( '/sfd|\bsf\b|single family/i', _item ) )
                Notice_type = '221';
              when ( prxmatch( '/2 to 4|2-4/i', _item ) )
                Notice_type = '225';
              when ( prxmatch( '/5 or more|5+/i', _item ) )
                Notice_type = '229';
              otherwise do;
                ** No property size given **;
                %err_put( macro=Rcasd_read_one_file, msg="Notice of sale without property size: file=&file " _n_= _item= )
                Notice_type = '';
              end;
            end;

          end;
          
          else do;
          
            ** Contract status not given **;
        
            ** Check property size **;
            
            select;
              when ( prxmatch( '/sfd|\bsf\b|single family/i', _item ) )
                Notice_type = '208';
              when ( prxmatch( '/2 to 4|2-4/i', _item ) )
                Notice_type = '209';
              when ( prxmatch( '/5 or more|5+/i', _item ) )
                Notice_type = '210';
              otherwise 
                Notice_type = '900';
            end;

          end;
        
        end;
        
        else if put( compress( upcase( _item ), ' .' ), $rcasd_text2type. ) ~= "" then do;
        
          /**PUT '** Another notice type other than OFS **';**/
        
          Notice_type = put( compress( upcase( _item ), ' .' ), $rcasd_text2type. );
          Orig_notice_desc = _item;
          
          /**PUT NOTICE_TYPE=;**/
                              
        end;
        else do;
        
          %err_put( macro=Rcasd_read_one_file, msg="Unrecognized notice type: file=&file " _n_= _item= )
          %err_put( macro=Rcasd_read_one_file, msg="Update Macros\Rcasd_text2type_fmt.sas to add this notice to RCASD formats." )
          
          Notice_type = "";
        
        end;
          
      end;
      
      else if input( _item, anydtdte40. ) >= '01jan2006'd then do;
      
        Notice_date = input( _item, anydtdte40. );
        
        /**PUT NOTICE_DATE=;**/
      
      end;
      
      else if ( prxmatch( _address_key_words, _item ) or
        prxmatch( '/\bbulk notices\b|\bapartments\b|\[no address\]/i', _item ) ) and 
        Orig_address = "" then do;
      
        ** Contains an address key word **;
      
        Orig_address = _item;
        
        /**PUT ORIG_ADDRESS=;**/
      
      end;

      else if prxmatch( '/\d+\s*\/\s*\$?[0-9,\.]+/', _item ) then do;
      
        ** Combined "Units / Price" item **;
      
        Num_units = input( scan( _item, 1, '/' ), 8. );
        Sale_price = input( scan( _item, 2, '/' ), dollar20. );
        
        /**PUT NUM_UNITS= SALE_PRICE=;**/
      
      end;
      
      else if prxmatch( '/($|)[\d,]+,\d\d\d/', _item ) then do;
      
        ** Sales price **;
        
        Sale_price = input( _item, dollar20. );
        
        /**PUT SALE_PRICE=;**/
        
      end;
      
      else if prxmatch( '/^\d+ *$/', _item ) then do;
      
        ** A plain number, which could be Source_address_id, Num_units, or Sale_price, depending on file format **;
        
        _number = input( _item, 16. );
        /**PUT _NUMBER=;**/
        
        if _is_notice_rec then do;
        
          if missing( _first_number ) then do;
            _first_number = _number;
            /**PUT _FIRST_NUMBER=;**/
          end;
          else do;
            %warn_put( macro=Rcasd_read_one_file, msg="Unknown number on notice record. " source_file= _n_= notice_date= _number= _inbuff= );
          end;
          
        end;
        else do;
        
          select;
          
            when ( missing( notice_date ) ) /** Do nothing **/;
          
            when ( '1feb2019'd <= notice_date ) do;
             
              if missing( Source_address_id ) then Source_address_id = _number;
              else if missing( num_units ) then num_units = _number;
              else if missing( sale_price ) then sale_price = _number;
              else do;
                %warn_put( macro=Rcasd_read_one_file, msg="Unknown number on notice record. " source_file= _n_= notice_date= _number= _inbuff= );
              end;
            
            end;
            
            when ( '1apr2013'd <= notice_date ) do;
             
              if missing( num_units ) then num_units = _number;
              else if missing( sale_price ) then sale_price = _number;
              else do;
                %warn_put( macro=Rcasd_read_one_file, msg="Unknown number on notice record. " source_file= _n_= notice_date= _number= _inbuff= );
              end;
            
            end;
            
            when ( ( '1jan2007'd <= notice_date <= '31dec2008'd ) and _number = 1) do;
            
              /** Extra 1's included in these notices as part of notice counts. Ignore. **/
              
            end;
            
            otherwise do;
            
              %warn_put( macro=Rcasd_read_one_file, msg="Unknown number on notice record. " source_file= _n_= notice_date= _number= _inbuff= );
              
            end;
            
          end;
          
          /**PUT Source_address_id= NUM_UNITS= SALE_PRICE=;**/
          
        end;
        
      end;
      
      else if lowcase( _item ) =: '# received' then do;
      
        _first_number = input( substr( _item, 12 ), 8. ); 
        /**PUT _FIRST_NUMBER=;**/
      
      end;
      
      else do;
      
        /**PUT 'NO MATCH: ' _item=;**/
        
        Notes = left( trim( Notes ) || ' ' || _item );
        
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
        /**PUT _NOTICE_COUNT= _NOTICE_COUNT_TOTAL=;**/
      end;
      else do;
        _notice_count = .;
      end;
      
    end;

    /**PUT NOTICE_TYPE= NOTICE_DATE= ORIG_ADDRESS=;**/
    
    ** If read both notice type and an address, write notice record **;

    if not( missing( notice_type ) or missing( orig_address ) ) then do;
    
      /**PUT 'WRITE NOTICE!';**/

      output;
      
      if missing( notice_date ) then do;
          %warn_put( 
          macro=Rcasd_read_one_file, 
          msg='Notice missing date. ' source_file= _n_= notice_type= orig_address=
        )
      end;
      
      
      if _notice_count > 0 then do;
        _notice_count = _notice_count - 1;
        /**PUT _NOTICE_COUNT=;**/
      end;
      else if _notice_count = 0 then do;
        %warn_put( 
          macro=Rcasd_read_one_file, 
          msg='Notice count does not match # of notices read. ' source_file= _n_= notice_type= notice_date= orig_address=
        )
      end;
      
      _notices + 1;
      
    end;
 

    /**PUT _notices= _NOTICE_COUNT_TOTAL= /;**/
    
    ** Create macro variables with count of wrote obs and total notice entries **;
    
    call symput( 'wrote_obs', put( _notices, 12. ) );
    call symput( 'notice_count_total', put( _notice_count_total, 12. ) );
    
    label
      Orig_notice_desc = "Original notice description from source file"
      Source_address_id = "MAR address ID from source file (2019 or later only)";

    format Notice_date mmddyy10. Notice_type $rcasd_notice_type.;
    
    drop _: ;
  
  run;


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

  /*TESTING CODE**
  proc sort data=&out;
    by Notice_type Notice_date;
  run;
  
  title2 "Source=&file";
  proc print data=&out n;
    by Notice_type;
    var Notice_date Orig_address Source_address_id Num_units Sale_price Notes;
  run;
  /**/

%mend Rcasd_read_one_file;

