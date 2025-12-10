#**************************************************************************
# Program:  PDF_to_text_2022.R
# Library:  DHCD
# Project:  Urban-Greater DC
# Author:   P. Tatian
# Created:  12/5/25
# Version:  R
# Environment:  Local Windows session (desktop)
# GitHub issue:  132
# 
# Description:  Convert PDF Weekly TOPA reports to TXT files. 2022.
#
# Modifications:
#**************************************************************************/

# install.packages('pdftools', repos = c('https://ropensci.r-universe.dev', 'https://cloud.r-project.org'))

library(pdftools)

file_list <-
  c( 
    "Weekly_Report_on_TOPA_Filings_April_4-8",
    "Weekly_Report_on_TOPA_Filings_April_11-15",
    "Weekly_Report_on_TOPA_Filings_April_18-22",
    "Weekly_Report_on_TOPA_Filings_April_25-29",
    "Weekly_Report_on_TOPA_Filings_August_1-5",
    "Weekly_Report_on_TOPA_Filings_August_8-12",
    "Weekly_Report_on_TOPA_Filings_August_15-19",
    "Weekly_Report_on_TOPA_Filings_August_22-26",
    "Weekly_Report_on_TOPA_Filings_August_29-September_2",
    "Weekly_Report_on_TOPA_Filings_February_7-11",
    "Weekly_Report_on_TOPA_Filings_February_14-18",
    "Weekly_Report_on_TOPA_Filings_February_21-25",
    "Weekly_Report_on_TOPA_Filings_February_28-March_4",
    "Weekly_Report_on_TOPA_Filings_January_3-7",
    "Weekly_Report_on_TOPA_Filings_January_10-14",
    "Weekly_Report_on_TOPA_Filings_January_17-21",
    "Weekly_Report_on_TOPA_Filings_January_24-28",
    "Weekly_Report_on_TOPA_Filings_January_31-February_4",
    "Weekly_Report_on_TOPA_Filings_July_4-8",
    "Weekly_Report_on_TOPA_Filings_July_11-15",
    "Weekly_Report_on_TOPA_Filings_July_18-22",
    "Weekly_Report_on_TOPA_Filings_July_25-29",
    "Weekly_Report_on_TOPA_Filings_June_6-10",
    "weekly_Report_on_TOPA_Filings_June_13-17",
    "Weekly_Report_on_TOPA_Filings_June_20-24",
    "Weekly_Report_on_TOPA_Filings_June_27-July_1",
    "Weekly_Report_on_TOPA_Filings_March_7-11",
    "Weekly_Report_on_TOPA_Filings_March_14-18",
    "Weekly_Report_on_TOPA_Filings_March_21-25",
    "Weekly_Report_on_TOPA_Filings_March_28-April_1",
    "Weekly_Report_on_TOPA_Filings_May_2-6",
    "weekly_Report_on_TOPA_Filings_May_9-13",
    "Weekly_Report_on_TOPA_Filings_May_16-20",
    "Weekly_Report_on_TOPA_Filings_May_23-27",
    "Weekly_Report_on_TOPA_Filings_May_30-June_3",
    "Weekly_Report_on_TOPA_Filings_Septebmer_26-30",
    "Weekly_Report_on_TOPA_Filings_September_5-9",
    "Weekly_Report_on_TOPA_Filings_September_12-16",
    "Weekly_Report_on_TOPA_Filings_September_19-23"
  )

path <- "//sas1/DCDATA/Libraries/DHCD/Raw/RCASD/2022/"

for ( file in file_list ) {
  text <- pdf_text(paste0(path, file, ".pdf"))
  writeLines(text,con=paste0(path, file, ".txt"))
}
