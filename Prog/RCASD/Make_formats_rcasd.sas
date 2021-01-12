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
    "CONDOMINIUMREGISTRATIONAPPLICATION",
    "CONDOMINIUMREGISTRATIONAPPLICATIONS",
	"CONDOMINIUMREGISTRATIONAPPLICATION(AMENDED&RESTATED)",
	"CONDOMINIUMREGISTRATIONAPPLICATIONCORRECTIONS" = "101"
    
    "NOT-A-HOUSINGACCOMMODATIONEXEMPTIONAPPLICATIONS",
    "NOTAHOUSINGACCOMODATIONAPPLICATION",
    "NOTAHOUSINGACCOMODATION",
    "NOTAHOUSINGACCOMMODATIONAPPLICATIONS",
    "NOTAHOUSINGACCOMMODATIONEXEMPTIONAPPLICATION" = "102"
    
    "VACANCYEXEMPTIONAPPLICATIONS","VACANCYEXEMPTIONAPPLICATION" = "103"
    
    "LOWINCOMEEQUITYSHARECOOPERATIVECONVERSIONAPPLICATIONS","LIMITEDEQUITYSHARECOOPERATIVECONVERSIONAPPLICATION" = "104"
    
    "TENANTELECTIONAPPLICATIONS",
    "TENANTELECTIONAPPLICATION" = "105"
    
    "HOUSINGASSISTANCEPAYMENTAPPLICATIONS" = "106"
    
    "PROPERTYTAXABATEMENTAPPLICATIONS","PROPERTYTAXABATEMENTAPPLICATION" = "107"

	"WARRANTYCLAIMCORRESPONDENCE" = "108"
    
    "NOTICESOFTRANSFER" = "201"
    
    "OTHERFILINGS" = "202"
    
    "NOTICESOFFORECLOSURE",
    "FORECLOSURENOTICE" = "203"
    "DCOPPORTUNITYTOPURCHASEACTDOPANOTICES",
    "DCOPPORTUNITYTOPURCHASEACTNOTICES",
    "DCOPPORTUNITYTOPURCHASENOTICE" = "204"
    
    "RAZEPERMITAPPLICATIONS", "RAZEPERMITAPPLICATION" = "205"
    
    "PETITIONSFORDECLARATORYRELIEF", "PETITIONFORDECLARATORYRELIEF" = "206"
    
    "TENANTORGANIZATIONREGISTRATIONAPPLICATION",
	"TENANTORGANIZATIONREGISTRATIONAPPLICATIONS","TENANTORGANIZATIONREGISTRATION" = "207"
    
    "SINGLEFAMILYDWELLINGOFFERSOFSALE" = "208"
    
    "2-4RENTALUNITOFFERSOFSALE" = "209"
    
    "5+RENTALUNITOFFERSOFSALE" = "210"
    
    "RIGHTSOFFIRSTREFUSAL",
    "RIGHTOFFIRSTREFUSAL","SFDRIGHTOFFIRSTREFUSAL" = "211"
    
    "TOPALETTEROFINTEREST",
    "LETTEROFINTERESTTOPA","LETTEROFINTEREST(TOPA)",
    "LETTEROFINTEREST" = "212"
    
    "TOPAASSIGNMENTOFRIGHTS",
    "ASSIGNMENTOFRIGHTTOPA",
    "ASSIGNEMETOFRIGHTTOPA", "ASSIGNMENTOFRIGHTS" = "213"
    
    "TOPACOMPLAINT","TOPACOMPLAINTS", "TOPACOMPLIANT", "COMPLAINT" = "214"
    
    "SFDNOTICEOFSOLICITATIONOFOFFER&NOTICEOFINTENTTOSELL",
    "SINGLEFAMILYDWELLINGNOTICEOFSOLICITATIONOFOFFER&NOTICEOFINTENTTOSELL" = "215"
    
    "SFDLETTERTOLANDLORD","TENANTSNOTICETOLANDLORD",
    "TENANTSLETTERTOLANDLORD"= "216"
    "SFDCLAIMOFELDERLYORDISABLEDSTATUS",
    "TENANTSCLAIMOFELDERLY/DISABLEDSTATUS" = "217"
    
    "SINGLEFAMILYDWELLINGOFFERSOFSALEW/CONTRACT",
    "SFDOFFEROFSALEW/CONTRACT" = "220"
    
    "SINGLEFAMILYDWELLINGOFFERSOFSALEW/OCONTRACT",
    "SFDOFFEROFSALEW/OCONTRACT" = "221"
    
    "2-4UNITSOFFEROFSALEW/CONTRACT" = "224"
    
    "2-4UNITSOFFEROFSALEW/OCONTRACT" = "225"

	"2-4UNITSNOTICEOFTRANSFER" = "227"
    
    "5+UNITSOFFEROFSALEW/CONTRACT" = "228"
    
    "5+UNITSOFFEROFSALEW/OCONTRACT" = "229"
    
    "5+UNITSNOTICEOFTRANSFER" = "230"
    
    "2-4UNITSRIGHTOFFIRSTREFUSAL" = "242"

	"SFDNOTICEOFTRANSFER" = "243"

	"PETITIONFORRECONSIDERATION" = "244"

	"WARRANTYSECURITYRELEASEREQUEST" = "245"
	
	"5+UNITSRIGHTOFFIRSTREFUSAL" = "246"

	"WARRANTYSECURITYLETTEROFCREDIT", 
	"WARRANTYSECURITY?LETTEROFCREDIT"  = "247"
    
    other = " ";

  value $rcasd_notice_type
    "101" = "Condominium registration application"
    "102" = "Not a housing accommodation exemption application"
    "103" = "Vacancy exemption application"
    "104" = "Low income equity share cooperative conversion application"
    "105" = "Tenant election application"
    "106" = "Housing assistance payment application"
    "107" = "Property tax abatement application"
	"108" = "Warrant claim correspondence - SFD Notice of Solicitation of Offer & Notice of Intent to Sell"
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
    "220" = "Single family dwelling offer of sale with contract"
    "221" = "Single family dwelling offer of sale without contract"
    "224" = "2-4 units offer of sale with contract"
    "225" = "2-4 units offer of sale without contract"
	"227" = "2-4 units notice of transfer"
    "228" = "5+ units offer of sale with contract"
    "229" = "5+ units offer of sale without contract"
    "230" = "5+ units notice of transfer"
    "242" = "2-4 units right of first refusal"
	"243" = "SFD notice of transfer"
	"244" = "Petition for reconsideration"
	"245" = "Warranty Security Release Request"
	"246"= "5+ units right of first refusal"
	"247"= "Warranty Security ? Letter of Credit - SFD Notice of Solicitation of Offer & Notice of Intent to Sell"
    ;

run;

proc catalog catalog=DHCD.Formats;
  modify rcasd_text2type (desc="Convert RCASD input text to notice type code") / entrytype=formatc;
  modify rcasd_notice_type (desc="RCASD notice type code") / entrytype=formatc;
  contents;
quit;

proc format library=DHCD fmtlib;
  select $rcasd_text2type $rcasd_notice_type;
run;

