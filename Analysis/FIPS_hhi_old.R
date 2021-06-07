library(readr)
library(vroom)
library(collections)
library(dplyr)
library(glue)
library(stringr)
library(data.table)
library(sjmisc)
library(tidyr)
library(foreach)
options(scipen=999)

# change directory as appropriate
setwd("~/Google Drive/Non-Academic Work/Research/Personal_FCC/")

directory <- "Data/export_fips/results/"

#reading in fips data
fips_data <- rbindlist(lapply(dir(directory), function (x) fread(paste(directory, x, sep = ""))))
#calculating percent market share
fips_data[, PctMarketShare:= prop.table(AreaPopCover) * 100, c("fips", "date", "year")]
#calculating HHI
fips_HHI <- fips_data[, sum(PctMarketShare^2), by = c("fips", "date", "year")]
colnames(fips_HHI)[4] <- "HHI"

#some summary statistics
fips_HHI <- fips_HHI[!is.na(fips_HHI$HHI)]

#ordering by fips and date
fips_HHI <- fips_HHI[order(fips, date)]

#add leading zeroes to match fipss with official values
addLeadingZeroes <- function (x) {
  paste(paste(rep(0, 5-str_length(x)), collapse = ""), x, collapse = "")
}
Modfipss <- gsub(" ", "", unlist(lapply(fips_HHI$fips, addLeadingZeroes)), fixed = TRUE)
fips_HHI$fips <- Modfipss

#summary statistics - high level
#decrease in aggregation over time - pre outlier removal
fips_HHI[, mean(HHI), by = "year"]
fips_HHI[, median(HHI), by = "year"]
fips_HHI[, sd(HHI), by = "year"]

#removing all data points above 98th percentiel
fips_HHI <- fips_HHI[, .SD[(HHI < quantile(HHI, probs = 0.99))]]

#summary statistics - high level
#decrease in aggregation over time - post outlier removal
#changes robust to outlier removal
fips_HHI[, mean(HHI), by = "year"]
fips_HHI[, median(HHI), by = "year"]
fips_HHI[, sd(HHI), by = "year"]

fwrite(fips_HHI, "Data/cleaned/fips_HHI.csv")
