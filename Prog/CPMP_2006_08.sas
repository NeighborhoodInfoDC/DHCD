/**************************************************************************
 Program:  CPMP_2006_08.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/26/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create data set from Ipums data for creating summaries
 for ConPlan CPMP tool. 

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( IPUMS )

data Age_person_2;

  set Ipums.Acs_2006_08_dc (keep=serial pernum age);
  where pernum = 2;

  drop pernum;
  
  rename age=age_person_2;
  
run;

data DHCD.CPMP_2006_08 (label="CPMP tool data from ACS 2008, DC");

  merge 
    Ipums.Acs_2006_08_dc 
      (keep=year serial pernum hhwt gq numprec hhincome ownershp age 
            famsize rentgrs owncost rooms kitchen plumbing)
    Ipums.Acs_2006_08_fam_pmsa99 (keep=serial is_family)
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
  
  ** Household types **;
  
  if numprec in ( 1, 2 ) and ( age >= 62 or age_person_2 >= 62 ) then household_type = 1; /** Elderly **/
  else if is_family and famsize = numprec then do;
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
  else crowded = 0;
  
  if cost_burden > 30 or crowded or kitchen = 1 or plumbing = 10 then housing_problems = 1;
  else housing_problems = .;
  
run;

%File_info( data=DHCD.CPMP_2006_08, freqvars=gq numprec famsize hud_inc ownershp rooms 
            kitchen plumbing household_type crowded housing_problems )

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
run;

proc freq data=DHCD.CPMP_2006_08;
  tables housing_problems * cost_burden * crowded * kitchen * plumbing / list nocum;
  format cost_burden cstbrdn. housing_problems crowded dyesno. kitchen kitchen. plumbing plumbing.;
run;
