/**************************************************************************
 Program:  CPMP_2008.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/26/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create data set from Ipums data for creating summaries
 for ConPlan CPMP tool. 

 Modifications:
  3/22/10 PAT Added vars. school upuma puma sploc.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( IPUMS )

data Age_person_2;

  set Ipums.Acs_2008_dc (keep=serial pernum age diffcare diffmob);
  where pernum = 2;

  if diffcare = 2 or diffmob = 2 then disabled_person_2 = 1;
  else disabled_person_2 = 0;

  drop pernum diffcare diffmob;
  
  rename age=age_person_2;
  
run;

data DHCD.CPMP_2008 (label="CPMP tool data from ACS 2008, DC");

  merge 
    Ipums.Acs_2008_dc 
      (keep=year serial pernum hhwt gq numprec hhincome ownershp age 
            famsize rentgrs owncost rooms kitchen plumbing race hispan
            school upuma puma sploc builtyr2 diffcare diffmob)
    Ipums.Acs_2008_fam_pmsa99 (keep=serial is_family)
    Age_person_2;
  by serial;
  
  ** Only keep record for HH head **;
  if pernum = 1;

  ** Only keep households (not persons in group quarters) **;
  if gq in ( 1, 2 );
  
  ** Table total var **;
  
  total = 1;
  
  ** HUD income categories **;
  %Hud_inc_all()
  
  ** Race/ethnicity **;
  
  if hispan = 0 then do;
    select ( race );
      when ( 1 ) race_eth = 1;
      when ( 2 ) race_eth = 2;
      when ( 4, 5, 6 ) race_eth = 3;
      otherwise race_eth = 4;
    end;
  end;
  else race_eth = 5;
  
  ** Household types **;
  
  if numprec in ( 1, 2 ) and ( age >= 62 or age_person_2 >= 62 ) then household_type = 1; /** Elderly **/
  else if numprec >= 2 and is_family and famsize = numprec then do;
    if numprec <= 4 then household_type = 2;  /** Small related **/
    else household_type = 3;  /** Large related **/
  end;
  else household_type = 4;  /** Other **/
  
  if ownershp = 1 then housing_costs = owncost;
  else housing_costs = rentgrs;
  
  if housing_costs = 0 then cost_burden = 0;
  else if missing( hhincome ) then cost_burden = .u;
  else if hhincome > 0 then cost_burden = ( 100 * 12 * housing_costs ) / hhincome;
  else cost_burden = 100;
  
  if cost_burden > 30 then cost_burden_30 = 1;
  else if 0 <= cost_burden <= 30 then cost_burden_30 = .;
  
  if cost_burden > 50 then cost_burden_50 = 1;
  else if 0 <= cost_burden <= 50 then cost_burden_50 = .;
  
  if numprec / rooms >= 1.01 then crowded = 1;
  else crowded = .;
  
  if cost_burden > 30 or crowded or kitchen = 1 or plumbing = 10 then housing_problems = 1;
  else housing_problems = .;
  
  if kitchen = 1 then dkitchen = 1;
  else dkitchen = .;
  
  if plumbing = 10 then dplumbing = 1;
  else dplumbing = .;
  
  ** Lead hazard **;
  
  if 1 <= builtyr2 <= 5 then dleadhaz = 1;
  else if 6 <= builtyr2 then dleadhaz = .;
  else dleadhaz = .n;

  ** Disability **;
  
  if diffcare = 2 or diffmob = 2 then disabled_person_1 = 1;
  else disabled_person_1 = 0;

  if disabled_person_1 or disabled_person_2 then disabled = 1;
  else disabled = 0;

run;

%File_info( data=DHCD.CPMP_2008, freqvars=gq numprec famsize hud_inc ownershp rooms 
            kitchen plumbing household_type crowded housing_problems race_eth 
            school puma builtyr2 disabled )

proc format;
  value cstbrdn
    0 - 30 = '<= 30%'
    30 <- high = '> 30%';
  value kitchen
    1 = 'Inadeq'
    4 = 'Adeq';
  value plumbing
    10 = 'Inadeq'
    20 = 'Adeq';
  value hhtype
    1 = 'Elderly'
    2 = 'Small related'
    3 = 'Large related'
    4 = 'Other';
  value raceeth
    1 = 'Non-Hisp. white'
    2 = 'Non-Hisp. black'
    3 = 'Non-Hisp. Asian'
    4 = 'Non-Hisp. other race'
    5 = 'Hispanic/Latino';
run;

proc freq data=DHCD.CPMP_2008;
  tables housing_problems * cost_burden * crowded * kitchen * plumbing / list nocum;
  tables race_eth * race * hispan / list nocum;
  format cost_burden cstbrdn. housing_problems crowded dyesno. kitchen kitchen. plumbing plumbing.
         race_eth raceeth.;
run;
