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

%macro Rcasd_address_parse( data=, out=, id=, addr= );

  %local MAX_NUMBERS;

  %let MAX_NUMBERS = 100;

  data &out;

    length Address $ 120 _addresslist _buff $ 500 _number1-_number&MAX_NUMBERS $ 50 _street_name _unit $ 200 _def_quad $ 2;
    
    array _number{*} _number1-_number&MAX_NUMBERS;

    set &data (keep=&id &addr Source_file);
    
    _addresslist = left( compbl( &addr ) );
    
    ** Remove parenthetical info (...) **;
    _addresslist = prxchange( 's/\(.*\)//', -1, _addresslist );

    _addresslist = tranwrd( _addresslist, '&', ' & ' );
    _addresslist = tranwrd( _addresslist, ' -', '-' );
    _addresslist = tranwrd( _addresslist, '- ', '-' );
    _addresslist = tranwrd( _addresslist, ',-', ',' );
    _addresslist = tranwrd( _addresslist, ',#', ' #' );    
    _addresslist = tranwrd( _addresslist, ', #', ' #' );    
    _addresslist = tranwrd( _addresslist, '#', ' #' );    
    _addresslist = tranwrd( _addresslist, '# ', '#' );
    _addresslist = tranwrd( _addresslist, ' ,', ',' );
    _addresslist = tranwrd( _addresslist, ',', ', ' );
    
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
    
      PUT / "START OUTER LOOP / " Source_file= / _addresslist= '/ ' _addr_idx=;
      
      _street_name = '';
      _unit = '';
      
      do _num_idx = 1 to &MAX_NUMBERS;
        _number{_num_idx} = '';
      end;
      
      _num_idx = 1;  
    
      do until ( _buff = '' );
      
        put _buff= _street_name=;
        
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
          PUT _UNIT=;
          leave;
        end;
        else if indexc( _buff, '-' ) then do;
        
          _r1 = input( scan( _buff, 1, '-' ), ??8. );
          _r2 = input( scan( _buff, 2, '-' ), ??8. );
          
          if missing( _r1 ) or missing( _r2 ) then do;
            ** Not a number range, process pieces separately **;
             _i = indexw( _addresslist, _buff, ' ' );
             substr( _addresslist, _i + ( indexc( substr( _addresslist, _i ), '-' ) - 1 ), 1 ) = ' ';
            _addr_idx = _addr_idx - 1;
            PUT _R1= _R2= _ADDRESSLIST= _I= _ADDR_IDX=;
          end;
          else if 0 < _r1 <= _r2 then do;
            ** Valid number range **;
            do i = _r1 to _r2 by 2;
              _number{_num_idx} = left( put( i, 8. ) );
              _num_idx = _num_idx + 1;
            end;
          end;
          else do;
            %warn_put( macro=Rcasd_address_parse, msg="Invalid number range: " _r1 " to " _r2 "/ " &addr= )
          end;
          
        end;
        else if upcase( _buff ) in ( 'AND', '&' ) then do;
          if _street_name ~= '' then leave;
        end;
        else if left( reverse( _buff ) ) =: ',' then do;
          _street_name = left( trim( _street_name ) || ' ' || compress( _buff, ',' ) );
          leave;
        end;
        else do;
          
          _street_name = left( trim( _street_name ) || ' ' || _buff );
          
        end;
        
        _addr_idx = _addr_idx + 1;
        _buff = left( scan( _addresslist, _addr_idx, ' ' ) );
        
      end;
      
      PUT _NUM_IDX=;
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
        %warn_put( macro=Rcasd_address_parse, msg="No street name found. " &addr= )
      end;
      
      _addr_idx = _addr_idx + 1;
      _buff = left( scan( _addresslist, _addr_idx, ' ' ) );

    end;
    
    label
      Address = 'Individual street address'
      Addr_num = 'Address number';
    
    keep &id Address Addr_num;

  run;

%mend Rcasd_address_parse;


