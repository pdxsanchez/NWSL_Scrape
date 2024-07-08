library(usethis)
library(janitor)
####
library(tidyverse) #filter(); select(); 
library(readxl) #read_excel()
library(ggplot2)
library(lubridate) 
library(stringr)
library(XML) #webscraping
library(RCurl) #webscraping

## NWSL FBREF Scores web page
u <- "https://fbref.com/en/comps/182/schedule/NWSL-Scores-and-Fixtures"

## Read in the webpage, pop it into a table
xData <- getURL(u)
table = readHTMLTable(xData, stringsAsFactors=F)