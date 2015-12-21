/**************************************************************************
 Program:  Make_formats.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/17/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Make formats.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( DHCD )

proc format library=DHCD;
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
      '11001008804' = 'Trinidad'
      '11001008903' = 'Trinidad'
      '11001008904' = 'Trinidad'
      other = ' ';
    value $nspnrtf
      ' ' = '\b Washington, DC'
      '11001007503' = '\line Anacostia'
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

run;

