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
#disable scientific notation
options(scipen=999)
registerDoMC(cores = 4)

#Set to my personal directory - adjust accordingly
setwd("~/Google Drive/Non-Academic Work/Research/Personal_FCC/Uyen_task_orig")

#reading in all the FCC data and combining it into one file 
totData <- foreach (i = dir("Data/FCC Data/"), .combine = "rbind") %dopar% {
  temp <- fread(paste("Data/FCC Data/", i, sep = ""), sep = ",", showProgress = TRUE, nrows = 100000) %>%
    select(c(`ProviderName`,`BlockCode`, `TechCode`, `Consumer`)) %>%
    filter(Consumer == 1)
  
  ind <- str_locate_all(pattern = "20", i)[[1]]
  start <- ind[1]-3
  end <- ind[2] + 2
  temp$DATE <- substr(i, start, end)
  temp
}

block_data <- fread("Data/Block Data/us2019/us2019.csv", sep = ",", showProgress = TRUE)
remCols <- foreach (i = 2010:2019, .combine = "c") %do% {
  c(paste("hu", i, sep = "") ,paste("hh", i, sep = ""))
}
block_data <- block_data %>% 
  select(-c(all_of(remCols),"pop2010", "pop2011", "pop2012", "pop2013"))
  
joined <- block_data %>% inner_join(totData, by = c("block_fips" = "BlockCode"))
joined$FIPS <- substr(joined$block_fips, 1, 5)
joined$TRACT <- substr(joined$block_fips, 6, 11)

is.nan.data.frame <- function(x)
  do.call(cbind, lapply(x, is.nan))

joined_provider <- joined
joined_provider$TechCode <- NULL
joined_provider <- joined_provider %>% distinct()
joined_provider <- joined_provider %>% group_by(`block_fips`, `DATE`) %>% mutate(count = n())

joined_tech <- joined
joined_tech$ProviderName <- NULL
joined_tech <- joined_tech %>% distinct()
joined_tech <- joined_tech %>% group_by(`block_fips`, `DATE`) %>% mutate(count = n())

#Provider share tract
joined_cs <- joined_provider
joined_cs$Consumer <- joined_cs$Consumer/joined_cs$count
joined_cs[3:8] <- joined_cs[3:8]/joined_cs$count
joined_cs <- joined_cs %>% 
  group_by(`TRACT`, `DATE`, `ProviderName`, `Consumer`) %>% 
  summarise(pop2014 = sum(pop2014), pop2015 = sum(pop2015), pop2016 = sum(pop2016), 
            pop2017 = sum(pop2017),pop2018 = sum(pop2018), pop2019 = sum(pop2019)) %>% 
  gather(YEAR, POP, pop2014:pop2019)
joined_cs$YEAR <- substr(joined_cs$YEAR, 4, 7)
joined_cs <- joined_cs[(joined_cs$YEAR == substr(joined_cs$DATE, 4, 7)),]
joined_cs$Consumer <- joined_cs$Consumer * joined_cs$POP
joined_cs <- joined_cs %>% group_by(`TRACT`, `DATE`, `YEAR`, `ProviderName`) %>%
  summarise(Consumer = sum(Consumer), POP = sum(POP))

joined_cs_wide <- joined_cs %>% spread(ProviderName, Consumer)
numcols <- ncol(joined_cs_wide)
joined_cs_wide[5:numcols][is.na(joined_cs_wide[5:numcols])] <- 0
joined_cs_wide$POP <- rowSums(joined_cs_wide[5:numcols])

joined_cs_wide <- joined_cs_wide %>% 
  group_by(`TRACT`, `DATE`, `YEAR`) %>% summarise_all(sum)
joined_cs_wide[5:numcols] <- joined_cs_wide[5:numcols]/joined_cs_wide$POP 
joined_cs_wide[5:numcols][is.nan(joined_cs_wide[5:numcols])] <- 0

joined_cs_long <- joined_cs_wide %>% 
  gather("ProviderName", "Share", colnames(joined_cs_wide)[5:183]) %>% 
  filter(Share != 0) %>% 
  arrange(`TRACT`, `DATE`)

#manual name crosswalk
joined_cs_long$ProviderName <- gsub("Verizon New England Inc.", "Verizon", joined_cs_long$ProviderName)
joined_cs_long$ProviderName <- gsub("Verizon New York Inc.", "Verizon", joined_cs_long$ProviderName)
joined_cs_long$ProviderName <- gsub("Verizon Pennsylvania LLC", "Verizon", joined_cs_long$ProviderName)
joined_cs_long$ProviderName <- gsub("Verizon California Inc.", "Verizon", joined_cs_long$ProviderName)
joined_cs_long$ProviderName <- gsub("Verizon Virginia LLC", "Verizon", joined_cs_long$ProviderName)
joined_cs_long$ProviderName <- gsub("Verizon Maryland LLC", "Verizon", joined_cs_long$ProviderName)
joined_cs_long$ProviderName <- gsub("Verizon Florida LLC", "Verizon", joined_cs_long$ProviderName)
joined_cs_long$ProviderName <- gsub("Verizon Delaware LLC", "Verizon", joined_cs_long$ProviderName)
joined_cs_long$ProviderName <- gsub("Verizon Washington, DC Inc.", "Verizon", joined_cs_long$ProviderName)

joined_cs_long$indicator <- 0

#handling mergers
#centurylink/level 3 merger - possibility that it cannot be done
joined_cs_long[joined_cs_long$ProviderName == "CenturyLink, Inc." & joined_cs_long$DATE == "june2017",]$indicator <- -1
joined_cs_long[joined_cs_long$ProviderName == "CenturyLink, Inc." & joined_cs_long$DATE == "june2018",]$indicator <- 1
joined_cs_long[joined_cs_long$ProviderName == "Level 3 Communications, LLC" & joined_cs_long$DATE == "dec2016",]$indicator <- -1
joined_cs_long[joined_cs_long$ProviderName == "Level 3 Communications, LLC" & joined_cs_long$DATE == "dec2017",]$indicator <- 1
#Verizon and XO merger on june 2017
joined_cs_long[joined_cs_long$ProviderName == "Verizon" & joined_cs_long$DATE == "dec2016",]$indicator <- -1
joined_cs_long[joined_cs_long$ProviderName == "Verizon" & joined_cs_long$DATE == "dec2017",]$indicator <- 1
joined_cs_long[joined_cs_long$ProviderName == "XO Communications Services, LLC" & joined_cs_long$DATE == "dec2016",]$indicator <- -1
joined_cs_long[joined_cs_long$ProviderName == "XO Communications Services, LLC" & joined_cs_long$DATE == "dec2017",]$indicator <- 1
#charter and time warner on june 2016
joined_cs_long[joined_cs_long$ProviderName == "Charter Communications, Inc." & joined_cs_long$DATE == "dec2015",]$indicator <- -1
joined_cs_long[joined_cs_long$ProviderName == "Charter Communications, Inc." & joined_cs_long$DATE == "dec2016",]$indicator <- 1
joined_cs_long[joined_cs_long$ProviderName == "Time Warner Cable Inc." & joined_cs_long$DATE == "dec2015",]$indicator <- -1
joined_cs_long[joined_cs_long$ProviderName == "Time Warner Cable Inc.`" & joined_cs_long$DATE == "dec2016",]$indicator <- 1
#charter and bright house on june 2016
joined_cs_long[joined_cs_long$ProviderName == "Charter Communications, Inc." & joined_cs_long$DATE == "dec2015",]$indicator <- -1
joined_cs_long[joined_cs_long$ProviderName == "Charter Communications, Inc." & joined_cs_long$DATE == "dec2016",]$indicator <- 1
joined_cs_long[joined_cs_long$ProviderName == "Bright House Networks, LLC" & joined_cs_long$DATE == "dec2015",]$indicator <- -1
joined_cs_long[joined_cs_long$ProviderName == "Bright House Networks, LLC" & joined_cs_long$DATE == "dec2016",]$indicator <- 1
#frontier and verizon - conflicts
#at&t and direcTV on June 2015 - conflicts + possibility it cannot be done
#at&t and frontier on december 2014
joined_cs_long[joined_cs_long$ProviderName == "AT&T Services, Inc." & joined_cs_long$DATE == "jun2014",]$indicator <- -1
joined_cs_long[joined_cs_long$ProviderName == "AT&T Services, Inc." & joined_cs_long$DATE == "jun2015",]$indicator <- 1
joined_cs_long[joined_cs_long$ProviderName == "Frontier Communications Corporation" & joined_cs_long$DATE == "jun2014",]$indicator <- -1
joined_cs_long[joined_cs_long$ProviderName == "Frontier Communications Corporation" & joined_cs_long$DATE == "jun2015",]$indicator <- 1

joined_provider_tract <- joined_cs_long
fwrite(joined_provider_tract, "Producables/joined_provider_tract.csv")

#Technology share tract
joined_cs <- joined_tech
joined_cs$Consumer <- joined_cs$Consumer/joined_cs$count
joined_cs[3:8] <- joined_cs[3:8]/joined_cs$count
joined_cs <- joined_cs %>% 
  group_by(`TRACT`, `DATE`, `TechCode`, `Consumer`) %>% 
  summarise(pop2014 = sum(pop2014), pop2015 = sum(pop2015), pop2016 = sum(pop2016), 
            pop2017 = sum(pop2017),pop2018 = sum(pop2018), pop2019 = sum(pop2019)) %>% 
  gather(YEAR, POP, pop2014:pop2019)

joined_cs$YEAR <- substr(joined_cs$YEAR, 4, 7)
joined_cs <- joined_cs[(joined_cs$YEAR == substr(joined_cs$DATE, 4, 7)),]
joined_cs$Consumer <- joined_cs$Consumer * joined_cs$POP
joined_cs <- joined_cs %>% group_by(`TRACT`, `DATE`, `YEAR`, `TechCode`) %>%
  summarise(Consumer = sum(Consumer), POP = sum(POP))
joined_cs_wide <- joined_cs %>% spread(TechCode, Consumer)
numcols <- ncol(joined_cs_wide)
joined_cs_wide[5:numcols][is.na(joined_cs_wide[5:numcols])] <- 0
joined_cs_wide$POP <- rowSums(joined_cs_wide[5:numcols])
joined_cs_wide <- joined_cs_wide %>% 
  group_by(`TRACT`, `DATE`, `YEAR`) %>% summarise_all(sum)
joined_cs_wide[5:numcols] <- joined_cs_wide[5:numcols]/joined_cs_wide$POP 
joined_cs_wide[5:numcols][is.nan(joined_cs_wide[5:numcols])] <- 0
joined_tech_tract <- joined_cs_wide
fwrite(joined_provider_tract, "Producables/joined_tech_tract.csv")
