/**************************************************************************
 Program:  Read_RCASD.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/04/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read RCASD condo conversion data files.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( DHCD )

/** Macro Read_RCASD - Start Definition **/

%macro Read_RCASD( file=, out=, sheet=Sheet1, start_row=5, end_row=100 );

  %let BUFF_DELIM = '|';
  %let MAX_COLS = 6;

  /** Macro Clean_buff - Start Definition **/

  %macro Clean_buff( b );

    trim( left( compbl( tranwrd( upcase( &b ), '|', ' ' ) ) ) ) 

  %mend Clean_buff;

  /** End Macro Definition **/

  filename xlsFile dde "excel|D:\DCData\Libraries\DHCD\Raw\RCASD\[&file]&sheet!r&start_row.c1:r&end_row.c&MAX_COLS" lrecl=2000 notab;

  data &out;

    length buff $ 2000 buff_a buff_b buff_c buff_d buff_e buff_f $ 500;
    length Source_file $ 80 Doc_name $ 100 Date 8 Address $ 40 Notes $ 500;
    
    retain Source_file "&file";
    retain row %eval( &start_row - 1 );
    
    infile xlsFile missover dsd dlm='09'x end=eof;
    
    rows_to_read = 0;
    doc = 0;

    do while ( not eof );
    
      row + 1;

      input buff_a buff_b buff_c buff_d buff_e buff_f;
      
      buff = %Clean_buff( buff_a ) || &BUFF_DELIM || %Clean_buff( buff_b ) || &BUFF_DELIM || %Clean_buff( buff_c ) || &BUFF_DELIM || 
             %Clean_buff( buff_d ) || &BUFF_DELIM || %Clean_buff( buff_e ) || &BUFF_DELIM || %Clean_buff( buff_f );
      
      *buff = left( compbl( upcase( buff ) ) );
      
      put row= buff=;
      
      if rows_to_read > 0 then do;
      
        ** Parse out date, address, and notes **;
        
        date = input( scan( buff, 1, &BUFF_DELIM ), anydtdte20. );
        address = scan( buff, 2, &BUFF_DELIM );
        
        if address = '' then do;
          %err_put( macro=Read_RCASD, 
                    msg="Number of documents does not match actual records. Please check input file. " Source_file= Doc_name= row= )
          %err_put( macro=Read_RCASD, 
                    msg="Execution of macro will stop. Data set may be incomplete." )
          stop;
        end;
        
        Notes = '';
        do i = 3 to &MAX_COLS;
          if scan( buff, i, &BUFF_DELIM ) ~= '' then do;
            if Notes = '' then Notes = scan( buff, i, &BUFF_DELIM );
            else Notes = trim( Notes ) || '; ' || scan( buff, i, &BUFF_DELIM );
          end;
        end;
      
        output;
        
        rows_to_read = rows_to_read - 1;
      
      end;
      else do;
      
        ** List of document names to be processed.
        ** NOTE: Document names must be in ALL CAPS. 
        **       You do not need to give the full document name, only the first part;
      
        select;
          when ( buff =: "CONDOMINIUM REGISTRATION APPLICATION" ) doc = 1;
          when ( buff =: "CONVERSION EXEMPTION APPLICATION" ) doc = 1;
          when ( buff =: "CONVERSION TENANT ELECTION APPLICATION" ) doc = 1;
          when ( buff =: "ELECTION CORRESPONDENCE" ) doc = 1;
          when ( buff =: "FORECLOSURE NOTICES" ) doc = 1;
          when ( buff =: "HOUSING ASSISTANCE PAYMENT" ) doc = 1;
          when ( buff =: "NOTICES OF TRANSFER" ) doc = 1;
          when ( buff =: "OFFER OF CORRESPONDENCE" ) doc = 1;
          when ( buff =: "OFFER OF SALE CORRESPONDENCE" ) doc = 1;
          when ( buff =: "OFFER OF SALE NOTICE" ) doc = 1;
          when ( buff =: "TENANT ASSOCIATION REGISTRATION" ) doc = 1;
          otherwise doc = 0;
        end;
        
        if doc then do;
          doc_name = scan( buff, 1, &BUFF_DELIM );
          rows_to_read = 0;
          do i = &MAX_COLS to 2 by -1;
            if anydigit( scan( buff, i, &BUFF_DELIM ) ) then do;
              rows_to_read = 1 * scan( buff, i, &BUFF_DELIM );
              leave;
            end;
          end;
        end;
        else do;
          doc_name = '';
        end;
        
        PUT '  ' DOC= DOC_NAME= ROWS_TO_READ=; 
        
      end;    
      
    end;
    
    stop;
    
    format date mmddyy10.;
    
    label 
      Source_file = 'Name of input file with source data'
      doc_name = 'Document/event name'
      address = 'Property address'
      date = 'Document/event date'
      notes = 'Notes';
    
    keep Source_file doc_name address date notes;

  run;

%mend Read_RCASD;

/** End Macro Definition **/


%Read_RCASD( file=%str(03-22-27,2009.xls), out=A )
%Read_RCASD( file=Book1 04-29-08.xls, sheet=sheet2, out=B )
%Read_RCASD( file=2009-08-03-07.xls, out=C )

data DHCD.RCASD_weekly_rpt (label="Rental Conversion and Sale Division Weekly Report");

  set A B C;
  
run;

proc sort data=DHCD.RCASD_weekly_rpt;
  by Date Doc_name;

%File_Info( data=DHCD.RCASD_weekly_rpt, printobs=10, freqvars=source_file )

proc freq data=DHCD.RCASD_weekly_rpt;
  tables date;
  format date yymms7.;
  title2 'Document dates by year/month';
run;

proc freq data=DHCD.RCASD_weekly_rpt;
  tables doc_name / nocum;
  title2 'Document names';
run;

title2;

run;

