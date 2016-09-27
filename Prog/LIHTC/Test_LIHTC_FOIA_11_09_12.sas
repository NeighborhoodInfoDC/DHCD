/**************************************************************************
 Program:  Test_LIHTC_FOIA_11_09_12.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/13/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Test geocoding against property owner file.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )
%DCData_lib( RealProp )

proc sort data=Dhcd.Lihtc_foia_11_09_12 out=Lihtc;
  by ssl;

data A;

  merge
    Lihtc 
      (keep=ssl address dhcd_project_id
       in=inlihtc)
    RealProp.Parcel_base
      (keep=ssl ui_proptype)
    RealProp.Parcel_base_who_owns
      (keep=ssl ownercat ownername_full);
  by ssl;

  if inlihtc;
  
run;

proc freq data=A;
  tables ownercat ownername_full ui_proptype;
run;
