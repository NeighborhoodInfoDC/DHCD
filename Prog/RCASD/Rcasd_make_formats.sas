/**************************************************************************
 Program:  Rcasd_make_formats.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  12/21/15
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Make formats for RCASD weekly report data.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )

proc format library=DHCD;

  value $rcasd_notice_type
    "101" = "Condominium registration application"
    "102" = "Not a housing accommodation exemption application"
    "103" = "Vacancy exemption application"
    "104" = "Low income equity share cooperative conversion application"
    "105" = "Tenant election application"
    "106" = "Housing assistance payment application"
    "107" = "Property tax abatement application"
    "108" = "Warrant claim correspondence - SFD Notice of Solicitation of Offer & Notice of Intent to Sell"
    "109" = "Conversion election request / information"
    "110" = "Condominium exemption request (vacant)"
    "111" = "Exemption from tenant election request (conversion from coop to condo)"
    "112" = "Election correspondence"
    "114" = "Conversion election"
    "115" = "Tenant conversion election application" 
    "117" = "Conversion election request (submitted by owner to tenants)"
    "118" = "Condominium conversion complaint"
    "120" = "Condominium exemption request (non-housing)"
    "121" = "Condominium registration application corrections - SFD notice of solicitation of offer & notice of intent to sell"
    "125" = "Conversion exemption request"
    "126" = "Conversion exemption information"
    "127" = "Election request for condo conversion"
    "130" = "Election request"
    "140" = "Conversion - Condominium registration application"
    "141" = "Conversion - Not a housing accommodation exemption application"
    "142" = "Conversion - Vacancy exemption application"
    "143" = "Conversion - Property tax abatement application"
    "144" = "Conversion - Tenant election correspondence - 5+ units right of first refusal"
    "145" = "Conversion - Not a housing accommodation exemption application - SFD notice of solicitation of offer & notice of intent to sell"
    "146" = "Conversion - Tenant election application"
    "147" = "Conversion - Warranty security bond - SFD notice of solicitation of offer & notice of intent to sell"
    "148" = "Conversion - Warranty claim - SFD notice of solicitation of offer & notice of intent to sell"
    "149" = "Conversion - Warranty Security Letter of Credit - SFD Notice of Solicitation of Offer & Notice of Intent to Sell"
    "150" = "Conversion - Limited equity share cooperative conversion application"
    "151" = "Conversion - Not a housing accommodation exemption application - Letter of interest (TOPA)"
    "152" = "Conversion - SFD Notice of solicitation of offer & notice of intent to sell"
    "153" = "Conversion - Condominium registration applications"
    "160" = "Letter of credit amendment - Letter of interest (TOPA)"
    "161" = "Not a housing accommodation exemption application - SFD notice of solicitation of offer & notice of intent to sell"
    "201" = "Notice of transfer"
    "202" = "Other filings"
    "203" = "Notice of foreclosure"
    "204" = "DC opportunity to purchase act notice"
    "205" = "Raze permit application"
    "206" = "Petition for declaratory relief"
    "207" = "Tenant organization registration application"
    "208" = "Single family dwelling offer of sale"
    "209" = "2-4 rental unit offer of sale"
    "210" = "5+ rental unit offer of sale"
    "211" = "Right of first refusal"
    "212" = "TOPA letter of interest"
    "213" = "TOPA assignment of rights"
    "214" = "TOPA complaints"
    "215" = "Single family notice of solicitation of offer & notice of intent to sell"
    "216" = "Tenant's notice to landlord"
    "217" = "Tenant's claim of elderly/disabled status"
    "218" = "Tenant's offer of sale response"
    "219" = "Notice of transfer (exemption from TOPA rights)"
    "220" = "Single family dwelling offer of sale with contract"
    "221" = "Single family dwelling offer of sale without contract"
    "224" = "2-4 units offer of sale with contract"
    "225" = "2-4 units offer of sale without contract"
    "227" = "2-4 units notice of transfer"
    "228" = "5+ units offer of sale with contract"
    "229" = "5+ units offer of sale without contract"
    "230" = "5+ units notice of transfer"
    "235" = "Tenant organzation registration (w/intent to purchase)"
    "237" = "Tenant statement of interest to purchase"
    "241" = "Single family dwelling right of first refusal"
    "242" = "2-4 units right of first refusal"
    "243" = "Single family dwelling notice of transfer"
    "244" = "Petition for reconsideration"
    "245" = "Warranty security release request"
    "246" = "5+ units right of first refusal"
    "247" = "Warranty security ? Letter of credit - SFD notice of solicitation of offer & notice of intent to sell"
    "250" = "Notice of transfer certification request"
    "260" = "Notice of intent to convert"
    "261" = "Notice of intent to convert (offer to purchase condominium unit)"
    "262" = "Notice of intent to convert (notice after conversion)"
    "265" = "Conversion fee / correspondence"
    "267" = "Conversion fee payment"
    "268" = "Conversion fee reduction request"
    "270" = "Offer of sale notice correspondence"
    "275" = "Offer of sale (misc. information)"
    "280" = "Condominium conversions vacancy exemption inspections listing"
    "282" = "Vacancy / Not a housing accomodation exemption application"
    "285" = "Conversion exemptions (vacant)"
    "290" = "Cooperative conversion exemption application"
    "291" = "Cooperative exemption application (vacant)"
    "295" = "Exemption request"
    "300" = "Miscellaneous information"
    "310" = "Termination of condominium"
    "312" = "Termination of sales contract"
    "320" = "Sales contract"
    "330" = "Disability survey for tenant election"
    "335" = "Intent to file petition"
    "900" = "Offer of sale (no property size given)"
    ;

run;

proc catalog catalog=DHCD.Formats;
  modify rcasd_notice_type (desc="RCASD notice type code") / entrytype=formatc;
  contents;
quit;

proc format library=DHCD fmtlib;
  select $rcasd_notice_type;
run;

