/**************************************************************************
 Program:  Rcasd_address_parse.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/10/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Parse address lists in RCSAD data into individual
addresses. 

 Modifications:
**************************************************************************/

%macro Rcasd_address_parse( data=, out=, id=, addr=, keepin=Source_file, keepout=, debug=N );

  %local MAX_NUMBERS;

  %let MAX_NUMBERS = 200;

  data &out;

    length Address $ 120 _addresslist _buff $ 1000 _number1-_number&MAX_NUMBERS $ 50 _street_name _unit $ 200 _def_quad $ 2;
    
    array _number{*} _number1-_number&MAX_NUMBERS;

    set &data (keep=&id &addr &keepin);
    
    _addresslist = left( compbl( &addr ) );
    
    ** Remove parenthetical info (...) **;
    _addresslist = prxchange( 's/\(.*\)//', -1, _addresslist );

    _addresslist = tranwrd( _addresslist, '&', ' & ' );
    _addresslist = tranwrd( _addresslist, '–', '-' );    /** En dash **/
    _addresslist = tranwrd( _addresslist, ' -', '-' );
    _addresslist = tranwrd( _addresslist, '- ', '-' );
    _addresslist = tranwrd( _addresslist, '--', '-' );
    _addresslist = tranwrd( _addresslist, ',-', ',' );
    _addresslist = tranwrd( _addresslist, ',#', ' #' );    
    _addresslist = tranwrd( _addresslist, ', #', ' #' );    
    _addresslist = tranwrd( _addresslist, '#', ' #' );    
    _addresslist = tranwrd( _addresslist, '# ', '#' );
    _addresslist = tranwrd( _addresslist, ' ,', ',' );
    _addresslist = tranwrd( _addresslist, ',', ', ' );
    _addresslist = tranwrd( _addresslist, ';', ' ; ' );
    
    _addresslist = prxchange( 's/\bnorthwest\b/ NW /i', -1, _addresslist );
    _addresslist = prxchange( 's/\bnortheast\b/ NE /i', -1, _addresslist );
    _addresslist = prxchange( 's/\bsouthwest\b/ SW /i', -1, _addresslist );
    _addresslist = prxchange( 's/\b(southeast|souteast)\b/ SE /i', -1, _addresslist );

    _addresslist = left( compbl( _addresslist ) );
    
    if indexw( upcase( _addresslist ), 'NW' ) then _def_quad = 'NW';
    else if indexw( upcase( _addresslist ), 'SW' ) then _def_quad = 'SW';
    else if indexw( upcase( _addresslist ), 'NE' ) then _def_quad = 'NE';
    else if indexw( upcase( _addresslist ), 'SE' ) then _def_quad = 'SE';
    else _def_quad = '  ';
    
    Addr_num = 1;
    _addr_idx = 1;
    _buff = left( scan( _addresslist, _addr_idx, ' ' ) );
    
    do until ( _buff = '' );
    
      %if %mparam_is_yes( &debug ) %then %do;
        PUT / "START OUTER LOOP / " Source_file= / _addresslist= '/ ' _addr_idx=;
      %end;
      
      _street_name = '';
      _unit = '';
      
      do _num_idx = 1 to &MAX_NUMBERS;
        _number{_num_idx} = '';
      end;
      
      _num_idx = 1;  
    
      do until ( _buff = '' );
      
        %if %mparam_is_yes( &debug ) %then %do;
          PUT _buff= _street_name=;
        %end;
        
        if input( compress( _buff, ',' ), ??8. ) > 0 then do;
          /** NOTE: Can't include TERRACE in the list that follows because TERRACE is also a street name. **/
          if put( upcase( scan( _addresslist, _addr_idx + 1, ' ' ) ), $maraltsttyp. ) in ( 'STREET', 'PLACE', 'AVENUE', 'COURT' ) then do;
            ** Next word is street type, so number is a street name **;
            _street_name = left( trim( _street_name ) || ' ' || _buff );
          end;
          else do;
            ** Number is a street address number **;
            _number{_num_idx} = compress( _buff, ',' );
            _num_idx = _num_idx + 1;
          end;            
        end;
        else if substr( _buff, 1, 1 ) = '#' then do;
          _unit = compress( _buff, ',' );
          %if %mparam_is_yes( &debug ) %then %do;
            PUT _UNIT=;
          %end;
          leave;
        end;
        else if upcase( compress( _buff, ',' ) ) in ( 'UNIT', 'APT' ) then do;
          _addr_idx = _addr_idx + 1;
          _buff = left( scan( _addresslist, _addr_idx, ' ' ) );
          _unit = '#' || compress( _buff, ',#' );
          %if %mparam_is_yes( &debug ) %then %do;
            PUT _UNIT=;
          %end;
          leave;
        end;
        else if indexc( _buff, '-' ) then do;
        
          _r1 = input( scan( _buff, 1, '-' ), ??8. );
          _r2 = input( scan( _buff, 2, '-' ), ??8. );
          
          ** Check for abbreviated range (eg, "1461-65 Hollbrook Avenue NE") **;
          
          if 0 < _r2 < _r1 then do;
          
            if 0 <= _r2 <= 99 and mod( _r1, 2 ) = mod( _r2, 2 ) then do;
              if _r1 > 999 then _r2 = _r2 + ( 100 * floor( _r1 / 100 ) );
              else if _r1 > 99 then _r2 = _r2 + ( 10 * floor( _r1 / 10 ) );
            end;
          
          end;
          
          if missing( _r1 ) or missing( _r2 ) then do;
            ** Not a number range, process pieces separately **;
             _i = indexw( _addresslist, _buff, ' ' );
             substr( _addresslist, _i + ( indexc( substr( _addresslist, _i ), '-' ) - 1 ), 1 ) = ' ';
            _addr_idx = _addr_idx - 1;
            %if %mparam_is_yes( &debug ) %then %do;
              PUT _R1= _R2= _ADDRESSLIST= _I= _ADDR_IDX=;
            %end;
          end;
          else if 0 < _r1 <= _r2 then do;
            ** Valid number range **;
            do i = _r1 to _r2 by 2;
              _number{_num_idx} = left( put( i, 8. ) );
              _num_idx = _num_idx + 1;
            end;
          end;
          else do;
            %warn_put( macro=Rcasd_address_parse, msg="Invalid number range: " _r1 " to " _r2 "/ " _addresslist= )
          end;
          
        end;
        else if upcase( _buff ) in ( 'AND', '&', ';', 'OR' ) then do;
          if _street_name ~= '' then leave;
        end;
        else if left( reverse( _buff ) ) =: ',' and not( missing( input( scan( scan( _addresslist, _addr_idx + 1, ' ' ), 1, ',-&' ), ??8. ) ) ) then do;
          _street_name = left( trim( _street_name ) || ' ' || compress( _buff, ',' ) );
          leave;
        end;
        else do;
          
          _street_name = left( trim( _street_name ) || ' ' || compress( _buff, ',' ) );
          
        end;
        
        _addr_idx = _addr_idx + 1;
        _buff = left( scan( _addresslist, _addr_idx, ' ' ) );
        
      end;
      
      %if %mparam_is_yes( &debug ) %then %do;
        PUT _NUM_IDX=;
      %end;
      
      if _street_name ~= '' then do;
      
        if not( indexw( upcase( _street_name ), 'NW' ) or indexw( upcase( _street_name ), 'SW' ) or
           indexw( upcase( _street_name ), 'NE' ) or indexw( upcase( _street_name ), 'SE' ) ) then
           _street_name = trim( _street_name ) || ' ' || _def_quad;
           
        do i = 1 to _num_idx - 1;
          Address = trim( left( _number{i} ) ) || ' ' || trim( _street_name ) || ' ' || _unit;
          if not missing( Address ) then do;
            output;
            Addr_num = Addr_num + 1;
          end;
        end;
      end;
      else do;
        %warn_put( macro=Rcasd_address_parse, msg="No street name found at word #" _addr_idx "/ " _addresslist= )
      end;
      
      _addr_idx = _addr_idx + 1;
      _buff = left( scan( _addresslist, _addr_idx, ' ' ) );

    end;
    
    label
      Address = 'Individual street address'
      Addr_num = 'Address number';
    
    keep &id Address Addr_num &keepout;

  run;

%mend Rcasd_address_parse;


/******************** UNCOMMENT FOR TESTING ***********************************

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( MAR )

data A;

  length Orig_address $ 120;
  
  retain Source_file ' ';
  
  Orig_address = '1461-65 Hollbrook Avenue NE; 141-5 Uhland Terrace NE';
  output;
  
  Orig_address = '4337-4347 Martin Luther King Jr Avenue, 4353-4363 Martin Luther King Jr Avenue & 200-211 Elmira Street Southwest';
  output;
  
  Orig_address = '1709, 1715 or 1717 19th Street NW';
  output;
  
  Orig_address = '7019 Georgia Avenue NW; 2504 & 2520 10th Street SE; 1418 & 1424 Somerset Place NW; 1417 & 1423 Sheridan Place NW';
  output;
  
  Orig_address = '6220 – 6243 Clay Street; 6220-6242 Banks Place; 221-243 & 301-323 63rd Street NE';
  output;
  
  Orig_address = '255 G Street SW #111 unit B';
  output;
  
  Orig_address = '1250 4th Street SW #W 412';
  output;

  Orig_address = '273 56th Street # 1&2';
  output;
  
  Orig_address = '1227 Queen Street NE Apt 3&4';
  output;
  
  Orig_address = "1842 California Street NW #4 B";
  output;
  
  Orig_address = "3883 Connecticut Ave unit #105";
  output;
  
  Orig_address = "2505--2513 Bowen Road, 2604-2610 Sheridan Road & 2600-2608 Stanton Road SE";
  output;

  Orig_address = '1727 Massachusetts Ave, NW unit 112';
  output;

  Orig_address = '5011 14th Street NW';
  output;
  
  Orig_address = '300 Hamilton Street NE, 350 Galloway Street NE and 5210 3rd Street NE';
  output;
  
  Orig_address = '2804 Terrace Road SE #A-544';
  output;
  
  Orig_address = '3576 -3722 Hayes Street & 3539-3699 Jay Street NE';
  output;
  
  Orig_address = '4800-4822 & 4900-4903 Alabama Avenue SE, & 4400-441 Falls Terrace SE';
  output;

  Orig_address = '2000 New York Ave';
  output;

  Orig_address = '1200 Seaton Place';
  output;

run;

%Rcasd_address_parse( data=A, out=B, id=, addr=Orig_address, debug=y );

proc print data=A;
run;

proc print data=B;
run;

/******************** END TESTING *********************************************/
