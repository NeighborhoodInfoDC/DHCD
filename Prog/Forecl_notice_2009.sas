/**************************************************************************
 Program:  Forecl_notice_2009.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/27/09
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Foreclosure notices for 2009 (to date).

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( Rod )
%DCData_lib( RealProp )

proc format;
    value $newptyp
      10 = 'Single-family homes'
      11 = 'Condominium'
      12 = 'Cooperative building'
      14 = 'Rental building (< 5 apts.)'
      15 = 'Rental building (5+ apts.)';
    value $nbrhd
      '11001007503' = 'Anacostia'
      '11001007504' = 'Anacostia'
      '11001007601' = 'Anacostia'
      '11001007803' = 'Deanwood'
      '11001007806' = 'Deanwood'
      '11001007807' = 'Deanwood'
      '11001007808' = 'Deanwood'
      '11001007809' = 'Deanwood'
      '11001009904' = 'Deanwood'
      '11001009905' = 'Deanwood'
      '11001009906' = 'Deanwood'
      '11001007901' = 'Trinidad'
      '11001007903' = 'Trinidad'
      '11001008500' = 'Trinidad'
      '11001008802' = 'Trinidad'
      '11001008803' = 'Trinidad'
      '11001008804' = 'Trinidad'
      '11001008903' = 'Trinidad'
      '11001008904' = 'Trinidad'
      other = ' ';

rsubmit;

data Forecl_address;

  set Rod.Foreclosures_2009;

  where ward2002 = '5' and ui_instrument = 'F1';

run;

** Create address list **;

proc sql noprint;
  create table Foreclosure_list as
  select * from 
    Forecl_address as f
    left join (
      select * from 
        RealProp.Parcel_base (keep=ssl premiseadd ownername ownname2 hstd_code address: assess_val) as p1
      /*
        left join
        RealProp.Parcel_geo as p2
      on p1.ssl = p2.ssl
      */
    ) as p
    on f.ssl = p.ssl
  order by FilingDate
;

run;

** Reformat owner address into single field **;

data Foreclosure_list;

  set Foreclosure_list;
  
  length owner_addr $ 500;
  
  if address2 = '' then 
    owner_addr = left( trim( address1 ) ) || ', ' || left( address3 );
  else 
    owner_addr = left( trim( address2 ) ) || ', ' || left( trim( address1 ) ) || ', ' || left( address3 );

run;

proc download status=no
  data=Foreclosure_list 
  out=Foreclosure_list;

run;

endrsubmit;

/*
** Add owner_occ_sale flag **;

%create_own_occ( inds=Foreclosure_list, outds=Foreclosure_list )
*/

ods tagsets.excelxp file="D:\DCData\Libraries\DHCD\Prog\Forecl_notice_2009.xls" style=minimal
      options( sheet_interval='page' );

ods listing close;

ods tagsets.excelxp options( sheet_name="Foreclosure notices 2009");

proc print data=Foreclosure_list label noobs;
  var Ward2002 FilingDate /*DocumentNo*/ Geo2000 ui_proptype SSL PREMISEADD 
      Zip Anc2002 Cluster_tr2000
      /*owner_occ_sale Grantee*/ OWNERNAME OWNNAME2 owner_addr hstd_code assess_val /*Grantor Verified*/;
  format Cluster_tr2000 $clus00f. Zip $5.;
  label 
    assess_val = 'Current assessed value ($)'
    Verified = 'Verified by ROD'
    UI_instrument = 'Instrument'
    FilingDate = 'Filing date'
    new_proptype = 'Property type' 
    SSL = 'Square/suffix/lot'
    PREMISEADD = 'Property address' 
    Zip = 'ZIP'
    Ward2002 = 'Ward'
    Anc2002 = 'ANC'
    Geo2000 = 'Census tract'
    Cluster_tr2000 = 'Neighborhood cluster'
    Grantee = 'Owner (from notice)'
    OWNERNAME = '1st owner name (from OTR)'
    owner_occ_sale = 'Owner occupied?'
    OWNNAME2 = '2nd owner name (from OTR)'
    owner_addr = 'Owner address (from OTR)'
    hstd_code = 'Homestead exemp. (from OTR)'
    Grantor = 'Lender/servicer/agent';

run;

ods tagsets.excelxp close;

ods listing;

run;

signoff;
