/**************************************************************************
 Bundle:   t008_rcasd_make_formats
 Source:   Prog/RCASD/Rcasd_make_formats.sas  (NeighborhoodInfoDC/DHCD)
 Original: P. Tatian, NeighborhoodInfo DC, 12/21/15

 Description (from source): Make formats for the RCASD (Rental Conversion
 and Sale Division) weekly report data. The $rcasd_notice_type format maps
 the three-digit RCASD notice-type codes to their descriptions; this bundle
 recodes a sample of notice-type codes into their labels with PUT() and
 tabulates them with PROC FREQ.

 Adaptation: the original writes the format to a permanent catalog
 (library=DHCD, defined by the DCData macro framework); here it builds in
 the default (WORK) catalog so the program is self-contained. The
 $rcasd_notice_type VALUE entries below are reproduced verbatim from the
 source for the codes the sample uses (the full source format defines the
 complete code list). The recode and PROC FREQ follow the source's own
 usage pattern (Notice_type is formatted with $rcasd_notice_type.).
**************************************************************************/

proc format;

  value $rcasd_notice_type
    "101" = "Condominium registration application"
    "102" = "Not a housing accommodation exemption application"
    "103" = "Vacancy exemption application"
    "105" = "Tenant election application"
    "201" = "Notice of transfer"
    "203" = "Notice of foreclosure"
    "204" = "DC opportunity to purchase act (DOPA) notice"
    "207" = "Tenant organization registration application"
    "211" = "Right of first refusal"
    "212" = "TOPA letter of interest"
    "214" = "TOPA complaints"
    other = "(unrecognized)";

run;

** Sample RCASD weekly-report notice records (Notice_type as 3-char code) **;
data rcasd_notices;
  length Notice_type $ 3 Notice_desc $ 120;
  input Notice_type $;
  Notice_desc = put( Notice_type, $rcasd_notice_type. );
  datalines;
101
203
211
212
101
204
102
211
207
103
214
211
105
201
;
run;

proc print data=rcasd_notices noobs;
  var Notice_type Notice_desc;
  title 'RCASD notice codes recoded via $rcasd_notice_type.';
run;

proc freq data=rcasd_notices order=freq;
  table Notice_desc / nocum;
  title 'Distribution of RCASD notice types';
run;
