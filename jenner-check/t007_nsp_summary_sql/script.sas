/**************************************************************************
 Bundle:   t007_nsp_summary_sql
 Source:   Prog/NSP_foreclosures.sas  (NeighborhoodInfoDC/DHCD)
 Original: P. Tatian, NeighborhoodInfo DC, 06/24/09

 Description (from source): Create a table of foreclosure data for DC NSP2
 neighborhoods. This bundle reproduces the pipeline core: a PROC SUMMARY
 with CHARTYPE that rolls foreclosure counts up by property type, report
 date and tract (keeping the all-up and tract-level _TYPE_ subsets), a
 PROC SQL left join to a tract unit-count table, and the DATA step that
 picks the year-matching unit column with SELECT( year( report_dt ) ) and
 computes per-1,000-unit foreclosure rates.

 Adaptation: the original reads HsngMon.Foreclosures_year_2009_2 and
 RealProp.Num_units_tr00 from external SAS libraries (DCData framework);
 here they are supplied as small inline samples with the columns the
 program reads. The PROC SUMMARY (chartype), PROC SQL join, and the
 SELECT/WHEN unit-assignment DATA step are reproduced as written; the
 trailing ODS-RTF report (a local D:\ path) is omitted so output renders
 to the listing. The source's colon name-prefix VAR list
 (var units_sf_: units_condo_:) is written out as the explicit column
 names in this sample so the four unit columns are summed directly.
**************************************************************************/

** Sample standing in for HsngMon.Foreclosures_year_2009_2 **;
data Foreclosures_year_2009_2;
  length geo2000 $ 11 ui_proptype $ 3;
  input geo2000 $ ui_proptype $ report_dt :date9.
        in_foreclosure_beg in_foreclosure_end foreclosure_start foreclosure_sale;
  format report_dt date9.;
  datalines;
11001007503 10 01jan2008 4 6 5 2
11001007503 11 01jan2008 2 3 3 1
11001007803 10 01jan2008 6 7 4 3
11001009904 11 01jan2008 1 2 2 0
11001007503 10 01jan2007 3 5 4 1
11001007803 10 01jan2007 5 6 3 2
;
run;

** Sample standing in for RealProp.Num_units_tr00 **;
data Num_units_tr00;
  length geo2000 $ 11;
  input geo2000 $ units_sf_2007 units_sf_2008 units_condo_2007 units_condo_2008;
  datalines;
11001007503 1200 1250 300 320
11001007803 900 950 150 160
11001009904 800 820 220 240
;
run;

proc summary data=Foreclosures_year_2009_2 chartype;
  where ui_proptype in ( '10', '11' );
  var in_foreclosure_beg in_foreclosure_end foreclosure_start foreclosure_sale;
  class ui_proptype report_dt geo2000;
  output out=Neighborhoods (where=(_type_ = '110' or _type_ = '111')) sum=;
run;

proc print data=Neighborhoods;
  title2 'File = Neighborhoods';
run;

proc summary data=Num_units_tr00 chartype;
  var units_sf_2007 units_sf_2008 units_condo_2007 units_condo_2008 ;
  class geo2000;
  output out=Units (where=(_type_ = '0' or _type_ = '1')) sum=;
run;

proc sql noprint;
  create table Neighborhoods_units as
  select * from
    Neighborhoods left join
    Units
  on Neighborhoods.geo2000 = Units.geo2000
  order by Neighborhoods._type_, Neighborhoods.ui_proptype, Neighborhoods.report_dt, Neighborhoods.geo2000;
quit;

data Neighborhoods_2;

  set Neighborhoods_units;

  if ui_proptype = '10' then do;

    select ( year( report_dt ) );
      when ( 2007 ) units = units_sf_2007;
      when ( 2008 ) units = units_sf_2008;
      otherwise units = units_sf_2008;
    end;

  end;

  else if ui_proptype = '11' then do;

    select ( year( report_dt ) );
      when ( 2007 ) units = units_condo_2007;
      when ( 2008 ) units = units_condo_2008;
      otherwise units = units_condo_2008;
    end;

  end;

  in_foreclosure_beg_rate = 1000 * in_foreclosure_beg / units;
  in_foreclosure_end_rate = 1000 * in_foreclosure_end / units;
  foreclosure_start_rate = 1000 * foreclosure_start / units;
  foreclosure_sale_rate = 1000 * foreclosure_sale / units;

  label
    foreclosure_start = 'New foreclosure starts'
    in_foreclosure_end_rate = 'Foreclosure inventory per 1,000 existing units (end of year)'
    foreclosure_start_rate = 'New foreclosure starts per 1,000 existing units'
    foreclosure_sale_rate = 'Foreclosure sales per 1,000 existing units'
  ;

  drop units_sf_: units_condo_: ;

run;

proc print data=Neighborhoods_2;
  var ui_proptype report_dt geo2000 in_foreclosure_end units foreclosure_start_rate;
  title2 'File = Neighborhoods_2';
run;
