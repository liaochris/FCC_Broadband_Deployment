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

readFile <- function(x) {
  fread(paste("FCC Data/", x, sep = ""), sep = ",", showProgress = TRUE) %>% 
    select(c(`ProviderName`, `BlockCode`,`TechCode`, `Consumer`)) %>%
    filter(`Consumer` == 1)
}

addDate <- function(x) substr(x, str_locate_all(pattern = "20", x)[[1]][1]-3, 
                              str_locate_all(pattern = "20", x)[[1]][2] + 2)
#this is the june 2016 file
fcc8 <- readFile("fbd_us_with_satellite_jun2016_v4.csv") %>%
  mutate(DATE = addDate("fbd_us_with_satellite_jun2016_v4.csv"))
fcc <- fcc8
fcc$FIPS <- substr(fcc$BlockCode, 1, 5)

#group by providers and counties 
fcc_fips_grouped <- fcc %>% group_by(`FIPS`, `ProviderName`, `DATE`) %>% 
  summarise(c = sum(Consumer))

block_data <- fread("Data/Block Data/us2019/us2019.csv", sep = ",", showProgress = TRUE)
remCols <- foreach (i = 2010:2019, .combine = "c") %do% {
  c(paste("hu", i, sep = "") ,paste("hh", i, sep = ""))
}
block_data <- block_data %>% 
  select(-c(all_of(remCols),"pop2010", "pop2011", "pop2012", "pop2013"))

block_data$fips <- substr(block_data$block_fips, 1, 5)
block_data <- block_data %>% group_by(`fips`) %>%
  summarise(pop16 = sum(pop2016))

fips_pop16 <- dict(items = block_data$pop16, keys = block_data$fips)
f <- function(x, y) y$get(x)

fcc_fips_grouped$YEAR <- substr(fcc_fips_grouped$DATE , 4, 7)
fcc_fips_grouped$pop <- unlist(lapply(fcc_fips_grouped$FIPS, f, fips_pop16))

fcc_fips_grouped$c_weight <- fcc_fips_grouped$c/1 * fcc_fips_grouped$pop 
fcc_fips_grouped <- fcc_fips_grouped %>% group_by(`ProviderName`) %>% 
  summarise(wc_sum = sum(c_weight)) %>%
  arrange(desc(wc_sum))
topProviders <- fcc_fips_grouped[1:25,]

topProviders$`ProviderName`
topProviders <- rbind(topProviders,
                      c("XO Communications Services, LLC",NA),
                      c("DirecTV",NA), 
                      c("Level 3 Communications, LLC", NA))

fwrite(topProviders, "Producables/topProviders.csv")

