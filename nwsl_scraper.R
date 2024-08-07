library(usethis)
library(janitor)
####
library(tidyverse) #filter(); select(); readr();
library(readxl)    #read_excel()
library(ggplot2)
library(lubridate) 
library(stringr)
library(XML)   #webscraping
library(RCurl) #webscraping

## NWSL FBREF Scores web page
u24 <-"https://fbref.com/en/comps/182/schedule/NWSL-Scores-and-Fixtures"
u23 <-"https://fbref.com/en/comps/182/2023/schedule/2023-NWSL-Scores-and-Fixtures"

## Read in NWSL Sched and fixtures webpages and format into tibbles.        
## GetURL/ReadHTML performed on 2023 data produces a list of 3 dataframes: 
## (1) "sched_all" which we assume is all NWSL weeks including playoffs
## (2) "sched_2023_182_1" which we assume is non-playoff weeks
## (3) "sched_2023_182_2" which we assume is only playoff weeks

## GetURL/ReadHTML performed on 2024 data produces a list of 1 dataframes: 
## (1) "sched_2024_182_1" which we assume is the schedule to date
##
## We assume 2024 data will change at some point to resemble 2023 data structure?
## We do not, at this date (7/2024), understand what the "182" stands for...
##
## We currently (7/24) choose to read in data frame (1) in each list of dataframes 
## produced by GetURL/ReadHTML. This may change as FBREF modifies its data 
## structures.

xData24 <- getURL(u24) #2024 NWSL schedule and scores data
table24 = readHTMLTable(xData24, stringsAsFactors=F)
t24a <- table24[[1]]   #Read in the first dataframe in the list of dataframes
t24 <- as_tibble(t24a,.name_repair = "unique") #convert df to tibble

xData23 <- getURL(u23) #2023 NWSL schedule and scores data
table23 = readHTMLTable(xData23, stringsAsFactors=F)
t23a <- table23[[1]]  #Read in the first dataframe in the list of dataframes
t23 <- as_tibble(t23a,.name_repair = "unique") #convert df to tibble

#Remove blank rows. Assumes no blank "Home" teams in data file. So... If "Home"
#column is blank, assume row is blank, and delete it.
v23 <- t23 %>% filter(!(Home=="")) %>%
                mutate_at(vars(xG...7,xG...9), as.numeric)  %>%
                mutate_at(vars(Attendance), parse_number)    %>%
                rename("home_xG" = "xG...7","away_xG" = "xG...9",
                       "home" = "Home", "away" = "Away")
                
v24 <- t24 %>% filter(!(Home=="")) %>%
               mutate_at(vars(xG...6,xG...8), as.numeric)  %>%
               mutate_at(vars(Attendance), parse_number)    %>%
               rename("home_xG" = "xG...6","away_xG" = "xG...8",
                      "home" = "Home", "away" = "Away") %>%
               mutate("home_goals" = str_extract(Score,"[0123456789]")) %>%
               mutate_at(vars(home_goals),parse_number) %>%
               mutate("away_goals" = str_extract(Score,"[^-][0123456789]")) %>%
               mutate_at(vars(away_goals),parse_number) %>%
               mutate("game_played"= ifelse(is.na(home_xG),0,1)) %>%
               mutate("btts_yes" = ifelse(game_played==0,NA,
                                             ifelse((away_goals!=0 & home_goals != 0),T,F)) ) %>%
               mutate("game_score" = away_goals + home_goals) %>%
               mutate("u_0_5" = ifelse((game_score < 0.5),T,F)) %>%
               mutate("o_0_5" = ifelse((game_score > 0.5),T,F)) %>%
               mutate("u_1_5" = ifelse((game_score < 1.5),T,F)) %>%
               mutate("o_1_5" = ifelse((game_score > 1.5),T,F)) %>%
               mutate("u_2_5" = ifelse((game_score < 2.5),T,F)) %>%
               mutate("o_2_5" = ifelse((game_score > 2.5),T,F)) %>%
               mutate("u_3_5" = ifelse((game_score < 3.5),T,F)) %>%
               mutate("o_3_5" = ifelse((game_score > 3.5),T,F)) %>%
               mutate("u_4_5" = ifelse((game_score < 4.5),T,F)) %>%
               mutate("o_4_5" = ifelse((game_score > 4.5),T,F)) 

##
## Ok lets have some fun cutting up the data...
##
test <- v24 %>%  summarise(
                     tot_games_played = sum(game_played, na.rm = TRUE),
                     tot_goals        = sum(game_score, na.rm = TRUE),
                     tot_home_goals   = sum(home_goals, na.rm = TRUE),
                     tot_away_goals   = sum(away_goals, na.rm = TRUE),
                     tot_game_goals   = sum(home_goals + away_goals, na.rm = TRUE),
                     tot_btts_yes     = sum(btts_yes, na.rm = TRUE),
                     mean_goals       = mean(game_score, na.rm= TRUE),
                     sd_goals         = sd(game_score,na.rm=TRUE),
                     #median_gpg       = median(home_goals+away_goals, na.rm=TRUE),
                     median2_gpg      = median(game_score, na.rm=TRUE),
                     tot_u_0_5        = sum(u_0_5, na.rm = TRUE),
                     tot_o_0_5        = sum(o_0_5, na.rm = TRUE),
                     tot_u_1_5        = sum(u_1_5, na.rm = TRUE),
                     tot_o_1_5        = sum(o_1_5, na.rm = TRUE),
                     tot_u_2_5        = sum(u_2_5, na.rm = TRUE),
                     tot_o_2_5        = sum(o_2_5, na.rm = TRUE),
                     tot_u_3_5        = sum(u_3_5, na.rm = TRUE),
                     tot_o_3_5        = sum(o_3_5, na.rm = TRUE),
                     tot_u_4_5        = sum(u_4_5, na.rm = TRUE),
                     tot_o_4_5        = sum(o_4_5, na.rm = TRUE)
                    
                     
                 ) %>%
                 mutate("mean_gpg"   = tot_game_goals/tot_games_played  ) %>%
                 mutate("btts_yes_%" = tot_btts_yes/tot_games_played) %>%
                 mutate("u_0_5%" = tot_u_0_5/tot_games_played) %>%
                 mutate("o_0_5%" = tot_o_0_5/tot_games_played) %>% 
                 mutate("u_1_5%" = tot_u_1_5/tot_games_played) %>%
                 mutate("o_1_5%" = tot_o_1_5/tot_games_played) %>%
                 mutate("u_2_5%" = tot_u_2_5/tot_games_played) %>%
                 mutate("o_2_5%" = tot_o_2_5/tot_games_played) %>%
                 mutate("u_3_5%" = tot_u_3_5/tot_games_played) %>%
                 mutate("o_3_5%" = tot_o_3_5/tot_games_played) %>%
                 mutate("u_4_5%" = tot_u_4_5/tot_games_played) %>%
                 mutate("o_4_5%" = tot_o_4_5/tot_games_played) 
                        
w24 <- test %>%    mutate("avg_goals" = mean_goals)%>%
                   mutate("std_dev_goals" = sd_goals) %>%
                   mutate("btts_yes_odds" = 1/(tot_btts_yes/tot_games_played)) %>%
                   mutate("btts_no_odds" = 1/(1- `btts_yes_%`)) %>%
                   mutate("u_0_5_odds" = 1/(tot_u_0_5/tot_games_played)) %>%
                   mutate("o_0_5_odds" = 1/(tot_o_0_5/tot_games_played)) %>% 
                   mutate("u_1_5_odds" = 1/(tot_u_1_5/tot_games_played)) %>%
                   mutate("o_1_5_odds" = 1/(tot_o_1_5/tot_games_played)) %>%
  mutate("u_2_5_odds" = 1/(tot_u_2_5/tot_games_played)) %>%
  mutate("o_2_5_odds" = 1/(tot_o_2_5/tot_games_played)) %>%
  mutate("u_3_5_odds" = 1/(tot_u_3_5/tot_games_played)) %>%
  mutate("o_3_5_odds" = 1/(tot_o_3_5/tot_games_played)) %>%
  mutate("u_4_5_odds" = 1/(tot_u_4_5/tot_games_played)) %>%
  mutate("o_4_5_odds" = 1/(tot_o_4_5/tot_games_played)) 

w27 <- w24 %>%  mutate(across(where(is.numeric), ~round(.x, digits=3)))

