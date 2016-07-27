/**************************************************************************
 Program:  Lihtc_address_parse.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/25/2016
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Parse address lists in DHCD LIHTC data into individual
 addresses. 

 Modifications:
**************************************************************************/

%macro Lihtc_address_parse( data=, out=, id=, addr= );

  %local MAX_NUMBERS;

  %let MAX_NUMBERS = 100;

  data &out;

    length 
      Address $ 120 _addresslist _buff $ 500 _number1-_number&MAX_NUMBERS $ 50 
      _street_name _unit $ 200 _number_suffix $ 8;
    
    array _number{*} _number1-_number&MAX_NUMBERS;

    set &data (keep=&id &addr);
    
    _addr_idx = 1;
    
    _addresslist = left( compbl( &addr ) );
    
    _addresslist = tranwrd( _addresslist, '&', ' & ' );
    _addresslist = tranwrd( _addresslist, ' -', '-' );
    _addresslist = tranwrd( _addresslist, '- ', '-' );
    _addresslist = tranwrd( _addresslist, 'W#', 'W #' );
    _addresslist = tranwrd( _addresslist, 'E#', 'E #' );
    _addresslist = tranwrd( _addresslist, '# ', '#' );
    
    _addresslist = left( compbl( _addresslist ) );

    do until ( _buff = '' );
    
      PUT / 'START OUTER LOOP ' _N_= (&id) (=);
      
      _street_name = '';
      _unit = '';
      
      do _num_idx = 1 to &MAX_NUMBERS;
        _number{_num_idx} = '';
      end;
      
      _num_idx = 1;  
    
      do until ( _buff = '' );
      
        _number_suffix = '';
        
        _buff = left( scan( _addresslist, _addr_idx, ' ' ) );
        put _buff= _street_name=;
        
        if ( indexc( substr( left( reverse( compress( _buff, ',' ) ) ), 1, 1 ), 'ABCDEFGH' ) > 0 ) and
           ( indexc( substr( left( reverse( compress( _buff, ',' ) ) ), 2, 1 ), '0123456789' ) > 0 ) then do;
          _number_suffix = substr( left( reverse( compress( _buff, ',' ) ) ), 1, 1 );
          _buff = left( reverse( substr( left( reverse( compress( _buff, ',' ) ) ), 2 ) ) );
          PUT _BUFF= _NUMBER_SUFFIX=;
        end;
        
        if ( indexc( substr( left( reverse( compress( _buff, ',' ) ) ), 1, 1 ), 'ABCDEFGH' ) > 0 ) and
           ( indexc( substr( left( reverse( compress( _buff, ',' ) ) ), 2, 1 ), '/' ) > 0 ) and
           ( indexc( substr( left( reverse( compress( _buff, ',' ) ) ), 3, 1 ), 'ABCDEFGH' ) > 0 ) and
           ( indexc( substr( left( reverse( compress( _buff, ',' ) ) ), 4, 1 ), '0123456789' ) > 0 ) then do;
          _number_suffix = substr( left( reverse( compress( _buff, ',' ) ) ), 1, 3 );
          _buff = left( reverse( substr( left( reverse( compress( _buff, ',' ) ) ), 4 ) ) );
          PUT _BUFF= _NUMBER_SUFFIX=;
        end;
        
        if input( compress( _buff, ',' ), ??8. ) > 0 then do;
          _number{_num_idx} = trim( compress( _buff, ',' ) ) || _number_suffix;
          PUT _NUMBER{_NUM_IDX}=;
          _num_idx = _num_idx + 1;
        end;
        else if indexc( _buff, '-' ) then do;
        
          ** number range **;
          _r1 = input( compress( scan( _buff, 1, '-' ), 'ABCDEFGH/' ), 8. );
          _r2 = input( scan( _buff, 2, '-' ), 8. );
          PUT _R1= _R2=;
          
          if _r2 < _r1 then do;
            %err_put( macro=LIHTC_address_parse, msg="Invalid address range: " _n_= _addresslist= _r1= _r2= )
          end;
          else do;
            do i = _r1 to _r2 by 2;
              _number{_num_idx} = left( put( i, 8. ) );
              PUT _NUMBER{_NUM_IDX}=;
              _num_idx = _num_idx + 1;
            end;
          end;
          
        end;
        else if upcase( _buff ) in ( 'AND', '&' ) then do;
          if _street_name ~= '' then leave;
        end;
        else if substr( _buff, 1, 1 ) = '#' then do;
          _unit = _buff;
        end;
        else do;
          
          _street_name = left( trim( _street_name ) || ' ' || _buff );
          
        end;
        
        _addr_idx = _addr_idx + 1;
        
      end;
      
      Addr_num = 1;
      
      do i = 1 to _num_idx - 1;
        Address = trim( left( _number{i} ) ) || ' ' || trim( _street_name ) || ' ' || _unit;
        if not missing( Address ) then do;
          output;
          Addr_num = Addr_num + 1;
        end;
      end;
      
      _addr_idx = _addr_idx + 1;
      
    end;
    
    label
      Address = 'Individual street address'
      Addr_num = 'Address number';
    
    keep &id Address Addr_num;

  run;

%mend Lihtc_address_parse;


