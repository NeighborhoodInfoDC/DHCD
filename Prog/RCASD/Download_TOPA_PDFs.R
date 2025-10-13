#**************************************************************************
# Program:  Download_TOPA_PDFs.R
# Library:  DHCD
# Project:  Urban-Greater DC
# Author:   P. Tatian
# Created:  10/13/25
# Version:  R
# Environment:  Local Windows session (desktop)
# GitHub issue:  132
# 
# Description:  Code to download PDF Weekly TOPA reports from DHCD website.
#
# Modifications:
#**************************************************************************/

library(rvest)
library(httr)
library(stringr)
library(tidyverse)

main_url <- "https://dhcd.dc.gov/page/weekly-report-tenant-opportunity-purchase-act-topa-filings"
output_root_folder <- "c:/temp/TOPA_PDFs"
date_pattern <- "\\b(January|February|March|April|May|June|July|August|September|October|November|December)\\b"

main_page <- read_html(main_url)

# Extract all <a> nodes
links <- main_page %>% html_nodes("a")

# Get href, link text, and report years
link_urls <- links %>% html_attr("href")
link_texts <- links %>% html_text(trim = TRUE)
link_years <- link_texts %>% str_extract( "\\b\\d{4}$\\b" )

# Combine into a data frame
link_df <- data.frame(url = link_urls, text = link_texts, report_year = link_years, stringsAsFactors = FALSE)

# Manual fix for missing year in link text
link_df$report_year[link_df$text=="February 27 - March 3" & is.na(link_df$report_year)] <- "2023"

# Function to extract and download PDF from a report page
download_pdf <- function(url) {
  
  print (url)
  
  # Check whether URL is a direct link to a PDF.
  # If so, download PDF directly. Otherwise, read PDF link from landing page.
  if ( str_detect(url,"\\.pdf$") ) { 
    file_name <- basename(url)
    dest_path <- str_replace_all( file.path(output_folder, file_name), "%20", " ")
    download.file(url, destfile = dest_path, mode = "wb")
  } else {
    page <- read_html(url)
    # Assume only 1 PDF per report page
    urls_pdf <- page %>% 
      html_elements("a") %>% 
      html_attr("href") %>% 
      str_subset("\\.pdf") 
    file_name <- basename(urls_pdf[1])
    dest_path <- str_replace_all( file.path(output_folder, file_name), "%20", " ")
    download.file(urls_pdf[1], destfile = dest_path, mode = "wb")
  }
}

# Create unique list of report years
link_years_unique <- link_years %>%
  unique() %>%
  na.omit()

# Process report pages by year (last year in date range)
for (year in link_years_unique) {
  
  output_folder <- file.path(output_root_folder, year)
  print( output_folder )
  dir.create(output_folder, showWarnings = FALSE, recursive = TRUE)
  
  # Filter links where the text contains a month and is for the selected year
  report_links <- link_df %>%
    filter(str_detect(text, date_pattern)) %>%
    filter(report_year == year) %>%
    mutate(full_url = ifelse(str_detect(url, "^http"), url, paste0("https://dhcd.dc.gov", url))) %>%
    pull(full_url)
  
  # Loop through each report link and download the PDF
  for (link in report_links) {
    download_pdf(link)
  }
  
}




