/**************************************************************************
 Program:  Rcasd_2015_12_04.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  12/22/15
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read RCASD weekly report of TOPA-related filings.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( DHCD )

%let path = D:\DCData\Libraries\DHCD\Raw\RCASD;
%let file = 2015-12-4.csv;
%let out = Rcasd_2015_12_04;

filename inf  "&path\&file" lrecl=1000;

data &out;

  length inbuff inbuff2 $ 1000 Notice_type $ 3 Address $ 160;
  
  retain Notice_type "" Count;

  infile inf dsd missover firstobs=6;
  
  input inbuff @;
  put _n_= inbuff=;
  
  if input( inbuff, ??8. ) > 0 then do;
    Count = input( inbuff, 8. );
    input inbuff;
    put _n_= count= inbuff=;
    
    Notice_type = put( compress( upcase( inbuff ), ' .' ), $rcasd_text2type. );
    
    if Notice_type = "" then do;
      %err_put( macro=, msg="Unrecognized notice type: " _n_= inbuff= )
      stop;
    end;
    
    do i = 1 to Count;
      
      input Notice_date :mmddyy10. Address inbuff inbuff2;
      
      if inbuff ~= "" then do;
      end;
      
      if inbuff2 ~= "" then do;
        Num_units = input( scan( inbuff2, 1, '/' ), 8. );
        Sale_price = input( scan( inbuff2, 2, '/' ), dollar16. );
      end;
      output;
    end;
    
  end;
  else do;
    input;
 end;
 
 format Notice_type $rcasd_notice_type. Notice_date mmddyy10.;
 
 drop inbuff: i count;

run;

%File_info( data=&out, printobs=100, freqvars=Notice_type )

