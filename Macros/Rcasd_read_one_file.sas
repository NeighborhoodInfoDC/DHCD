/**************************************************************************
 Program:  Rcasd_read_one_file.sas
 Library:  DHCD
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/09/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read one RCASD input CSV file into a SAS data set.

 Modifications:
**************************************************************************/

/** Macro Rcasd_read_one_file - Start Definition **/

%macro Rcasd_read_one_file( file=, path=, out= );

  filename inf  "&path\&file" lrecl=1000;

  data &out;

    length Notice_type $ 3 Orig_address $ 160 Source_file $ 120 inbuff inbuff2 $ 1000;
    
    retain Notice_type "" Count 0 Source_file "%lowcase(&file)";

    infile inf dsd missover firstobs=6;
    
    input inbuff @;
    put _n_= inbuff=;
    
    if input( inbuff, ??8. ) > 0 then do;
      Count = input( inbuff, 8. );
      input inbuff;
      put _n_= count= inbuff=;
      
      Notice_type = put( compress( upcase( inbuff ), ' .' ), $rcasd_text2type. );
      
      if Notice_type = "" then do;
        %err_put( macro=, msg="Unrecognized notice type: file=&file " _n_= inbuff= )
        stop;
      end;
      
      do i = 1 to Count;
        
        input Notice_date :mmddyy10. Orig_address inbuff inbuff2;
        
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
  
  filename inf clear;

%mend Rcasd_read_one_file;

/** End Macro Definition **/

