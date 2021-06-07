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
registerDoMC(cores = 8)

#Set to my personal directory - adjust accordingly
setwd("~/Google Drive/Non-Academic Work/Research/Personal_FCC/Uyen_task_orig")

topProviders_dset <-  fread("Producables/topProviders.csv", sep = ",", showProgress = TRUE)
topProviders <- topProviders_dset$ProviderName

#function for adding date column
addDate <- function(x) substr(x, str_locate_all(pattern = "20", x)[[1]][1]-3, 
                              str_locate_all(pattern = "20", x)[[1]][2] + 2)

#function for reading in files and filtering
readFile <- function(x) {
  fread(paste("Data/FCC Data/", x, sep = ""), sep = ",", showProgress = TRUE) %>% 
    filter(`ProviderName` %in% topProviders) %>%
    select(c(`ProviderName`, `FRN`, `BlockCode`,`TechCode`, `Consumer`)) %>%
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
fcc_grouped_date <- fcc %>% group_by(`FIPS`, `ProviderName`, `DATE`) %>% 
  summarise(c = sum(Consumer))

fcc_grouped_date$year <- substr(fcc_grouped_date$DATE , 4, 7)

#block data
block_data <- fread("Data/Block Data/us2019/us2019.csv", sep = ",", showProgress = TRUE)
remCols <- foreach (i = 2010:2019, .combine = "c") %do% {
  c(paste("hu", i, sep = "") ,paste("hh", i, sep = ""))
}

#selecting out unneeded columns
block_data <- block_data %>% 
  select(-c(all_of(remCols),"pop2010", "pop2011", "pop2012", "pop2013"))
block_data$FIPS <-  substr(block_data$block_fips, 1, 5)
block_data <- block_data %>% group_by(FIPS) %>%
  summarise(pop2014 = sum(pop2014), pop2015 = sum(pop2015), pop2016 = sum(pop2016), 
            pop2017 = sum(pop2017),pop2018 = sum(pop2018), pop2019 = sum(pop2019))

#joining block data
joined <- block_data %>% inner_join(fcc_grouped_date)
joined <- joined %>% gather(`YEAR`, `POP`, pop2014:pop2019) %>% 
  filter(substr(`DATE`, 4, 7) == substr(`YEAR`, 4, 7)) %>% 
  group_by(`FIPS`, `DATE`) %>% 
  mutate(cTot = sum(c))

#calculating share of each provider
joined$share <- joined$c/joined$cTot
#reformatting data
joined$c <- NULL
joined$cTot <- NULL

#crosswalk for names
joined$ProviderName <- gsub("Verizon New England Inc.", "Verizon", joined$ProviderName)
joined$ProviderName <- gsub("Verizon New York Inc.", "Verizon", joined$ProviderName)
joined$ProviderName <- gsub("Verizon Pennsylvania LLC", "Verizon", joined$ProviderName)
joined$ProviderName <- gsub("Verizon New Jersey Inc.", "Verizon", joined$ProviderName)

joined$indicator <- 0
#handling mergers
#centurylink/level 3 merger - cannot be done
#Verizon and XO merger on june 2017
joined[joined$ProviderName == "Verizon" & joined$DATE == "dec2016",]$indicator <- -1
joined[joined$ProviderName == "Verizon" & joined$DATE == "dec2017",]$indicator <- 1
joined[joined$ProviderName == "XO Communications Services, LLC" & joined$DATE == "dec2016",]$indicator <- -1
joined[joined$ProviderName == "XO Communications Services, LLC" & joined$DATE == "dec2017",]$indicator <- 1

#charter and time warner
joined[joined$ProviderName == "Charter Communications, Inc." & joined$DATE == "dec2015",]$indicator <- -1
joined[joined$ProviderName == "Charter Communications, Inc." & joined$DATE == "dec2016",]$indicator <- 1
joined[joined$ProviderName == "Time Warner Cable Inc." & joined$DATE == "dec2015",]$indicator <- -1
joined[joined$ProviderName == "Time Warner Cable Inc.`" & joined$DATE == "dec2016",]$indicator <- 1

#charter and bright house
joined[joined$ProviderName == "Charter Communications, Inc." & joined$DATE == "dec2015",]$indicator <- -1
joined[joined$ProviderName == "Charter Communications, Inc." & joined$DATE == "dec2016",]$indicator <- 1
joined[joined$ProviderName == "Bright House Networks, LLC" & joined$DATE == "dec2015",]$indicator <- -1
joined[joined$ProviderName == "Bright House Networks, LLC" & joined$DATE == "dec2016",]$indicator <- 1

#frontier and verizon - conflicts
#at&t and direcTV not available
#at&t and frontier 
joined[joined$ProviderName == "AT&T Services, Inc." & joined$DATE == "jun2014",]$indicator <- -1
joined[joined$ProviderName == "AT&T Services, Inc." & joined$DATE == "jun2015",]$indicator <- 1
joined[joined$ProviderName == "Frontier Communications Corporation" & joined$DATE == "jun2014",]$indicator <- -1
joined[joined$ProviderName == "Frontier Communications Corporation" & joined$DATE == "jun2015",]$indicator <- 1

#exporting data
fwrite(joined, "Producables/joined_provider.csv")
