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

## Read in the webpage, pop it into a table
xData24 <- getURL(u24)
table24 = readHTMLTable(xData24, stringsAsFactors=F)
t24a <- table24[[1]]
t24 <- as_tibble(table24,.name_repair = "unique")

xData23 <- getURL(u23)
table23 = readHTMLTable(xData23, stringsAsFactors=F)
t23a <- table23[[1]]
t23 <- as_tibble(t23a,.name_repair = "unique")
