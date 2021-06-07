#Import libraries
library(data.table)
library(readr)
library(dplyr)
library(haven)
library("doMC")
library(future)
library(vroom)
library(RCurl)
library(googledrive)
library(ipumsr)
library(zoo)
library(collections)
library(glue)
library(stringr)
library(tidyr)
library(Rfast)
plan(multisession)
#disable scientific notation
options(scipen=999)
registerDoMC(cores = 4)

#Set to my personal directory - adjust accordingly
setwd("~/Google Drive/Non-Academic Work/Research/Personal_FCC/Uyen_task_orig")

topProviders_dset <-  fread("Producables/topProviders.csv", sep = ",", showProgress = TRUE)
topProviders <- topProviders_dset$HocoFinal

addDate <- function(x) substr(x, str_locate_all(pattern = "20", x)[[1]][1]-3, 
                              str_locate_all(pattern = "20", x)[[1]][2] + 2)

readFile <- function(x) {
  fread(paste("Data/FCC Data/", x, sep = ""), sep = ",", showProgress = TRUE) %>%
    select(c(`BlockCode`,`TechCode`, `Consumer`)) %>%
    distinct() %>%
    filter(`Consumer` == 1)
}
directory <- "Data/FCC Data/"

fcc1 <- readFile(dir(directory)[1]) %>%
  mutate(DATE = addDate(dir(directory)[1]))
fcc2 <- readFile(dir(directory)[2]) %>%
  mutate(DATE = addDate(dir(directory)[2])) 
fcc3 <- readFile(dir(directory)[3]) %>%
  mutate(DATE = addDate(dir(directory)[3])) 
fcc4 <- readFile(dir(directory)[4]) %>%
  mutate(DATE = addDate(dir(directory)[4]))  
fcc5 <- readFile(dir(directory)[5]) %>%
  mutate(DATE = addDate(dir(directory)[5])) 
fcc6 <- readFile(dir(directory)[6]) %>%
  mutate(DATE = addDate(dir(directory)[6])) 
fcc7 <- readFile(dir(directory)[7]) %>%
  mutate(DATE = addDate(dir(directory)[7])) 
fcc8 <- readFile(dir(directory)[8]) %>%
  mutate(DATE = addDate(dir(directory)[8])) 
fcc9 <- readFile(dir(directory)[9]) %>%
  mutate(DATE = addDate(dir(directory)[9]))  
fcc <- rbindlist(list(fcc1, fcc2, fcc3, fcc4, fcc5, fcc6, fcc7, fcc8, fcc9))
fcc$FIPS <- substr(fcc$BlockCode, 1, 5)

fcc_grouped_date <- fcc %>% group_by(`FIPS`, `TechCode`, `DATE`) %>% 
  summarise(c = sum(Consumer))

fcc_grouped_date$year <- substr(fcc_grouped_date$DATE , 4, 7)

block_data <- fread("Data/Block Data/us2019/us2019.csv", sep = ",", showProgress = TRUE)
remCols <- foreach (i = 2010:2019, .combine = "c") %do% {
  c(paste("hu", i, sep = "") ,paste("hh", i, sep = ""))
}

block_data <- block_data %>% 
  select(-c(all_of(remCols),"pop2010", "pop2011", "pop2012", "pop2013"))
block_data$FIPS <-  substr(block_data$block_fips, 1, 5)
block_data <- block_data %>% group_by(FIPS) %>%
  summarise(pop2014 = sum(pop2014), pop2015 = sum(pop2015), pop2016 = sum(pop2016), 
            pop2017 = sum(pop2017),pop2018 = sum(pop2018), pop2019 = sum(pop2019))

#change it so that data is joined on county
joined <- block_data %>% inner_join(fcc_grouped_date)
joined <- joined %>% gather(`YEAR`, `POP`, pop2014:pop2019) %>% 
  filter(substr(`DATE`, 4, 7) == substr(`YEAR`, 4, 7))
joined <- joined %>% group_by(`FIPS`, `DATE`) %>% mutate(cTot = sum(c))

joined$share <- joined$c/joined$cTot
joined$c <- NULL
joined$cTot <- NULL
joined_wide <- joined %>% spread(`TechCode`, share)

fwrite(joined_wide, "Producables/joined_wide_tech.csv")

