/**************************************************************************
 Program:  Make_formats_rcasd.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  12/21/15
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Make formats for RCASD weekly report data.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )

proc format library=DHCD;

  value $rcasd_text2type 
    "CONDOMINIUMREGISTRATIONAPPLICATION" = "101"
    "NOT-A-HOUSINGACCOMMODATIONEXEMPTIONAPPLICATIONS" = "102"
    "VACANCYEXEMPTIONAPPLICATIONS" = "103"
    "LOWINCOMEEQUITYSHARECOOPERATIVECONVERSIONAPPLICATIONS" = "104"
    "TENANTELECTIONAPPLICATION" = "105"
    "HOUSINGASSISTANCEPAYMENTAPPLICATIONS" = "106"
    "PROPERTYTAXABATEMENTAPPLICATIONS" = "107"
    "NOTICESOFTRANSFER" = "201"
    "OTHERFILINGS" = "202"
    "NOTICESOFFORECLOSURE" = "203"
    "DCOPPORTUNITYTOPURCHASEACTNOTICES" = "204"
    "RAZEPERMITAPPLICATIONS" = "205"
    "PETITIONSFORDECLARATORYRELIEF" = "206"
    "TENANTORGANIZATIONREGISTRATIONAPPLICATIONS" = "207"
    "SINGLEFAMILYDWELLINGOFFERSOFSALE" = "208"
    "2-4RENTALUNITOFFERSOFSALE" = "209"
    "5+RENTALUNITOFFERSOFSALE" = "210"
    "RIGHTOFFIRSTREFUSAL" = "211"
    other = "";

  value $rcasd_notice_type
    "101" = "Condominium registration application"
    "102" = "Not-a-housing accommodation exemption application"
    "103" = "Vacancy exemption application"
    "104" = "Low income equity share cooperative conversion application"
    "105" = "Tenant election application"
    "106" = "Housing assistance payment application"
    "107" = "Property tax abatement application"
    "201" = "Notice of transfer"
    "202" = "Sale data":"" = " other filings"
    "203" = "Notice of foreclosure"
    "204" = "DC opportunity to purchase act notice"
    "205" = "Raze permit application"
    "206" = "Petition for declaratory relief"
    "207" = "Tenant organization registration application"
    "208" = "Single family dwelling offer of sale"
    "209" = "2-4 rental unit offer of sale"
    "210" = "5+ rental unit offer of sale"
    "211" = "Right of first refusal";

run;

proc catalog catalog=DHCD.Formats;
  modify rcasd_text2type (desc="Convert RCASD input text to notice type code") / entrytype=formatc;
  modify rcasd_notice_type (desc="RCASD notice type code") / entrytype=formatc;
  contents;
quit;

