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
u24 <- "https://fbref.com/en/comps/182/schedule/NWSL-Scores-and-Fixtures"
u23 <-"https://fbref.com/en/comps/182/2023/schedule/2023-NWSL-Scores-and-Fixtures"

## Read in webpage and format into tibbles.
## GetURL/ReadHTML performed on 2023 data produces a list of 3 dataframes: 
## (1) "sched_all" which we assume is all NWSL weeks including playoffs
## (2) "sched_2023_182_1" which we assume is non-playoff weeks
## (3) "sched_2023_182_2" which we assume is playoff weeks

## GetURL/ReadHTML performed on 2024 data produces a list of 1 dataframes: 
## (1) "sched_2024_182_1" which we assume is the schedule to date
##
## We assume 2024 data will change at some point to resemble 2023 data structure?
## We do not, at this date (7/2024), understand what the "182" stands for...

xData24 <- getURL(u24)
table24 = readHTMLTable(xData24, stringsAsFactors=F)
t24a <- table24[[1]]
t24 <- as_tibble(t24a,.name_repair = "unique")

xData23 <- getURL(u23)
table23 = readHTMLTable(xData23, stringsAsFactors=F)
t23a <- table23[[1]]
t23 <- as_tibble(t23a,.name_repair = "unique")
