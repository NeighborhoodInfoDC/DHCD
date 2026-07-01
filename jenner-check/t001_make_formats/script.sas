/**************************************************************************
 Bundle:   t001_make_formats
 Source:   Prog/Make_formats.sas  (NeighborhoodInfoDC/DHCD)
 Original: P. Tatian, NeighborhoodInfo DC, 06/17/09

 The PROC FORMAT VALUE statements below are reproduced verbatim from the
 repository's Make_formats.sas. The only adaptation: the original writes
 the formats to a permanent catalog (library=DHCD, defined by the DCData
 macro framework); here they build in the default (WORK) catalog so the
 program is self-contained.

 A short DATA step applies the $newptyp and $nspnbhd formats with PUT() --
 the same recoding pattern the repository uses elsewhere (e.g.
 Prog/NSP_forecl_address.sas: `nbrhd = put( geo2000, $nbrhd. );`) -- so the
 neighborhood and property-type labels appear directly in the output.
**************************************************************************/

proc format;
    value $newptyp
      10 = 'Single-family homes'
      11 = 'Condominiums'
      12 = 'Cooperative buildings'
      13 = 'Rental buildings'
      14 = 'Rental buildings (< 5 apts.)'
      15 = 'Rental buildings (5+ apts.)';
    value $newptyb
      10 = 'Single-family homes'
      11 = 'Condominium buildings'
      12 = 'Cooperative buildings'
      13 = 'Rental buildings'
      14 = 'Rental buildings (< 5 apts.)'
      15 = 'Rental buildings (5+ apts.)';
    value $nspnbhd
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
      '11001008904' = 'Trinidad'
      other = ' ';
run;

** Apply the repository formats to a few sample parcels so the recodes show **;
data parcel_labels;
  length geo2000 $ 11 proptype $ 2 neighborhood $ 40 property_type $ 40;
  input geo2000 $ proptype $;
  neighborhood  = put( geo2000,  $nspnbhd. );
  property_type = put( proptype, $newptyp. );
  datalines;
11001007503 10
11001007803 13
11001007901 14
11001008500 15
11001009904 11
99999999999 12
;
run;

proc print data=parcel_labels noobs;
  var geo2000 neighborhood proptype property_type;
  title 'DHCD parcel recodes via $nspnbhd. and $newptyp.';
run;
