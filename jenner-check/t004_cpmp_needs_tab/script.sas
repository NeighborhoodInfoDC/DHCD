/**************************************************************************
 Bundle:   t004_cpmp_needs_tab
 Source:   Prog/CPMP_2008_needs_tbl2.sas  (NeighborhoodInfoDC/DHCD)
 Original: P. Tatian, NeighborhoodInfo DC, 02/26/10

 Description (from source): Produce data for the CPMP tool Needs table
 (Needs.xls) for the DC ConPlan. This bundle reproduces the first table --
 housing needs by race/ethnicity -- a WEIGHTed PROC TABULATE that reports
 weighted sums and percents plus an unweighted sample-obs count, using the
 hhwt household weight and the program's user-defined classification
 formats.

 Adaptation: the original reads DHCD.CPMP_2008 from an external SAS
 library (DCData framework) and writes to an ODS HTML/XLS file on a local
 path; here the input is a small inline sample with the columns the table
 reads, and the ODS HTML wrapper (a local D:\ path) is omitted so the
 table renders to the listing. The PROC FORMAT block, the CLASS / VAR /
 WEIGHT / TABLE specification, and the formats are reproduced exactly as
 written in the source.
**************************************************************************/

** Sample standing in for DHCD.CPMP_2008 (ACS 2008 IPUMS extract) **;
data CPMP_2008;
  input hud_inc ownershp household_type race_eth
        total housing_problems cost_burden_30 cost_burden_50 hhwt;
  datalines;
1 2 1 2 1 1 1 0 120
1 2 2 1 1 1 0 0  95
2 1 3 5 1 0 1 1 140
3 2 4 2 1 1 1 0  80
1 2 1 3 1 1 1 1 110
2 2 2 2 1 1 1 0  60
3 1 3 1 1 0 0 0 150
1 2 4 5 1 1 1 1  90
2 2 1 2 1 1 0 0 130
3 2 2 4 1 0 1 0  70
;
run;

proc format;
  value hudinc
    1 = '<=30% MFI'
    2 = '>30 to <=50% MFI'
    3 = '>50 to <=80% MFI';
  value ownershp (notsorted)
    2 = 'Renter'
    1 = 'Owner';
  value hhtype
    1 = 'Elderly'
    2 = 'Small related'
    3 = 'Large related'
    4 = 'All other';
  value raceeth (notsorted)
    2 = 'Non-Hisp. black'
    1 = 'Non-Hisp. white'
    5 = 'Hispanic/Latino'
    3 = 'Non-Hisp. Asian'
    4 = 'Non-Hisp. other race';
run;

%fdate()

proc tabulate data=CPMP_2008 format=comma12.0 noseps missing;
  class hud_inc ownershp household_type race_eth / preloadfmt order=data;
  var total housing_problems cost_burden_30 cost_burden_50;
  weight hhwt;
  table
    /** Rows **/
    race_eth=' ' *
      ( total='Number of households'
        housing_problems='Any housing problems'
        cost_burden_30='Cost burden > 30%'
        cost_burden_50='Cost burden > 50%' ),
    /** Columns **/
    pctsum<total>='Current %'*f=comma10.2 sum='Current Number' n='Sample obs.'
    / rts=60 box="All Households, 2008"
  ;
  format hud_inc hudinc. ownershp ownershp. household_type hhtype. race_eth raceeth.;
  title2 "HOUSING NEEDS BY RACE/ETHNICITY";
  footnote1 "Source: ACS 2008 IPUMS file.";
  footnote2 "Prepared for DC DHCD by NeighborhoodInfo DC (&fdate)";

run;
