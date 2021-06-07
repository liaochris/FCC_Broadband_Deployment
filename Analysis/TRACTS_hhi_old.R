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

directory <- "Data/export_tract/results/"

#reading in tract data
tract_data <- rbindlist(lapply(dir(directory), function (x) fread(paste(directory, x, sep = ""))))
#calculating percent market share
tract_data[, PctMarketShare:= prop.table(AreaPopCover) * 100, c("tract", "date", "year")]
#calculating HHI
tract_HHI <- tract_data[, sum(PctMarketShare^2), by = c("tract", "date", "year")]
colnames(tract_HHI)[4] <- "HHI"

#some summary statistics
tract_HHI <- tract_HHI[!is.na(tract_HHI$HHI)]

#ordering by tract and date
tract_HHI <- tract_HHI[order(tract, date)]

#add leading zeroes to match tracts with official values
addLeadingZeroes <- function (x) {
  paste(paste(rep(0, 6-str_length(x)), collapse = ""), x, collapse = "")
}
ModTracts <- gsub(" ", "", unlist(lapply(tract_HHI$tract, addLeadingZeroes)), fixed = TRUE)
tract_HHI$tract <- ModTracts

#summary statistics - high level
#decrease in aggregation over time - pre outlier removal
tract_HHI[, mean(HHI), by = "year"]
tract_HHI[, median(HHI), by = "year"]
tract_HHI[, sd(HHI), by = "year"]

#removing all data points above 98th percentiel
tract_HHI <- tract_HHI[, .SD[(HHI < quantile(HHI, probs = 0.99))]]

#summary statistics - high level
#decrease in aggregation over time - post outlier removal
#changes robust to outlier removal
tract_HHI[, mean(HHI), by = "year"]
tract_HHI[, median(HHI), by = "year"]
tract_HHI[, sd(HHI), by = "year"]

fwrite(tract_HHI, "Data/cleaned/tract_HHI.csv")
