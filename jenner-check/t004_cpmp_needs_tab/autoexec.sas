options obs=100;

/* The DCData framework provides %fdate, which sets the &fdate macro var
   to a formatted run date used in report footnotes. A deterministic stub
   is defined here so the bundle output is reproducible. */
%macro fdate;
  %global fdate;
  %let fdate = (run date);
%mend fdate;
