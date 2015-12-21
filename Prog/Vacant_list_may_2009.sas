/**************************************************************************
 Program:  Vacant_list_may_2009.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/16/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read 2009 Vacant List May.xls into SAS.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( RealProp )

*filename inXls dde "excel|d:\DCData\Libraries\DHCD\Raw\[2009 Vacant List May.xls]TOTAL!r2c1:r2220c3" lrecl=1000 notab;
filename inCSV  "d:\DCData\Libraries\DHCD\Raw\2009 Vacant List May TOTAL.csv" lrecl=1000;

data A;

  *infile inXls missover dsd dlm='09'x;
  infile inCSV dsd missover firstobs=2;

  input
    address : $80.
    xssl : $40.
    ward : $1.
  ;
  
  if not( missing( address ) );
  
  ** Reformat SSL **;
  
  length ssl $ 17 _buff _a _c $40 _b $1;
  
  _buff = left( upcase( translate( xssl, ' ', '-' ) ) );
  
  if _buff =: 'PAR' then do;
  
    _c = left( put( input( compress( substr( _buff, 4 ), ' ' ), 12.), z8. ) );
    
    ssl = 'PAR ' || _c;
  
  end;
  else do;
  
    _i = anyalpha( _buff );
    
    if _i > 0 then do;
    
      _a = left( put( input( compress( substr( _buff, 1, _i - 1 ), ' ' ), 12.), z4. ) );
      _b = substr( _buff, _i, 1 );
      _c = left( put( input( compress( substr( _buff, _i + 1 ), ' ' ), 12.), z4. ) );
    
    end;
    else do;
    
     _a = left( put( input( compress( scan( _buff, 1 ), ' ' ), 12.), z4. ) );
     _b = ' ';
     _c = left( put( input( compress( scan( _buff, 2 ), ' ' ), 12.), z4. ) );
    
    end;
    
    ssl = trim( _a ) || _b || '   ' || _c;
  
  end;
  
  drop _: ;

run;

proc sort data=A;
  by ssl;

data With_geo Without_geo (drop=ssl);

  merge 
    A (in=inA)
    RealProp.Parcel_base (keep=ssl ui_proptype in=inPB)
    RealProp.Parcel_geo (keep=ssl ward2002 geo2000);
  by ssl;
  
  if inA;
  
  if not inPB then output Without_geo;
  else output With_geo;
    
run;

** Start submitting commands to remote server **;

rsubmit;

proc upload status=no
  data=Without_geo 
  out=Without_geo;

run;

%DC_geocode(
  geo_match=Y,
  data=Without_geo,
  out=Without_geo_added,
  staddr=address,
  zip=,
  id=xssl,
  ds_label=,
  listunmatched=Y
)

proc sort data=Without_geo_added;
  by ssl;

proc download status=no
  data=Without_geo_added 
  out=Without_geo_added;

run;

endrsubmit;

** End submitting commands to remote server **;


data B;

  set With_geo Without_geo_added;
  by ssl;
  
run;


data DHCD.Vacant_list_may_2009;

  merge 
    B (in=inB)
    RealProp.Parcel_base (keep=ssl ui_proptype);
  by ssl;
  
  if inB;
  
  if missing( geo2000 ) then do;

    select ( ssl );
      when ( '1053    2001' ) do; 
        ward2002 = '6';
        geo2000 = '11001008001';
        ui_proptype = '11';
      end;
      when ( '2852    0034' ) do;
        ward2002 = '1';
        geo2000 = '11001003100';
        ui_proptype = '12';        
      end;
      when ( '3241    0812' ) do;
        ward2002 = '4';
        geo2000 = '11001002301';
        ui_proptype = '10';
      end;
    end;

  end;
  
  keep ssl xssl address ui_proptype geo2000 ward2002; 
  
run;

proc sort data=DHCD.Vacant_list_may_2009 nodupkey;
  by ssl;
run;

%File_info( data=DHCD.Vacant_list_may_2009, stats=, printobs=50, freqvars=ui_proptype ward2002 geo2000 )


/*
proc print data=RealProp.Parcel_base noobs;
  where ssl contains "PAR";
  var ssl;
run;
