/**************************************************************************
 Program:  Rent_controlled_v2_table.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/02/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Table showing rent controlled summary.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )

proc tabulate data=DHCD.PARCELS_RENT_CONTROL format=comma12.0 noseps missing;
  class Rent_controlled;
  var Units_full;
  table 
    /** Rows **/
    all='Total database' rent_controlled='Rent controlled',
    /** Columns **/
    n='Properties' sum='Units' * units_full
  ;


run;
