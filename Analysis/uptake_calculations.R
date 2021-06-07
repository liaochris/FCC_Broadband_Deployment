# Import libraries
library(data.table)
library(readr)
library(dplyr)
library(haven)
library("doMC")
library(future)
library(vroom)
library(RCurl)
library(zoo)
library(collections)
library(glue)
library(stringr)
library(tidyr)
library(Rfast)
library(parallel)
library(doParallel)
plan(multisession)
# disable scientific notation
options(scipen = 999)
registerDoMC(cores = 100)

setwd("~/Google Drive/Non-Academic Work/Research/Personal_FCC/")

directory <- "Data/uptake"

fcc <- rbindlist(foreach(i=1:length(dir(directory))) %do% {
  fname <- dir(directory)[i]
  temp <- fread(paste(directory, fname, sep = "/"))
  date <- substr(fname, str_length(fname)-11, str_length(fname)-4)
  temp[, date := date]
  temp
}, fill = TRUE)

fcc <- fcc[,c("tract_fips", "tractcode", "rfc_per_1000_hhs", "rfhsc_per_1000_hhs", "pcat_all", "date")]
fcc <- fcc[,tractcode:=coalesce(tractcode, tract_fips)]
fcc <- fcc[,pcat_all:=coalesce(pcat_all, rfc_per_1000_hhs, rfhsc_per_1000_hhs)]
fcc_uptake <- fcc[,c("tractcode", "pcat_all", "date")]

fcc_uptake[,tractcode := str_pad(tractcode, 11, pad = 0)]

cat_to_num <- function(x) {
  ifelse(x==0, 0, (2*x - 1)/10)
}
fcc_uptake[, pcat_all_num:=cat_to_num(pcat_all)]
fcc_uptake[, fips:=substr(tractcode, 1, 5)]
fcc_uptake[,date:=paste(substr(date, 1, 3), substr(date, 5, 8), sep = "")]
fcc_uptake[,year:=substr(date, 4, 7)]

# block data
block_data <- fread("Data/FCC_Imported_Data/Block Data/us2019/us2019.csv", sep = ",", nThread = 100)
remCols <- foreach(i = 2010:2019, .combine = "c") %do% {
  c(paste("hu", i, sep = ""), paste("hh", i, sep = ""))
}

# selecting out unneeded columns
block_data <- block_data %>%
  select(-c(all_of(remCols)))

# creating FIPS and tract columns
block_data$block_fips <- str_pad(block_data$block_fips, 15, pad = "0")
block_data$fips <- substr(block_data$block_fips, 1, 5)
block_data$tract <- substr(block_data$block_fips, 1, 11)
block_data <- block_data[,-"stateabbr"]

# transforming years into row entries
colnames(block_data)[2:11] <- "2010":"2019"
block_data_long <- melt(block_data, measure.vars = c(colnames(block_data)[2:11]),
                        variable.name = "year", value.name = "pop")
block_data_long <- data.table(block_data_long)

tract_pop <- block_data_long[, sum(pop), by=c("tract", "fips", "year")] 
setnames(tract_pop, "V1", "pop")

fcc_uptake[tract_pop, "pop" := list(pop), on = c(tractcode = "tract", "fips", "year")]
fcc_uptake <- fcc_uptake[!is.na(pop)]
fcc_uptake[, pop_covered:= pop * pcat_all_num]
fips_uptake <- fcc_uptake[, list(sum(pop_covered), sum(pop)), c("fips", "date", "year")]
setnames(fips_uptake, c("V1", "V2"), c("pop_covered", "tot_pop"))

fips_uptake[, prop_covered:=pop_covered/tot_pop]
fwrite(fips_uptake, "Data/cleaned/fips_uptake.csv")
