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
library(parallel)
options( scipen=999)
# change directory as appropriate
setwd("~/Google Drive/Non-Academic Work/Research/Personal_FCC/")

fcc_fips <- fread("Data/cleaned/fcc_fips_agg.csv")
fcc_fips[,fips:=str_pad(fips, width = 5, pad = "0")]

fcc_tract <- fread("Data/cleaned/fcc_tract_agg.csv")
fcc_tract[,tract:=str_pad(tract, width = 11, pad = "0")]

##################################################
#FIPS ACQUISITIONS
##################################################


#Acquisition 1 - AT&T-Frontier, Dec 2014
HocoNums <- c(130077, 130258)
DATES <- c("dec2014", "jun2015")
acq1_fips <- unique(fcc_fips[HocoNum %in% HocoNums & 
                               DATE %in% DATES, fips])
fcc_fips[fips %in% acq1_fips & DATE == DATES[1], acq1:=0]
fcc_fips[fips %in% acq1_fips & DATE == DATES[2], acq1:=1]

#Acquisition 2 - AT&T-DirecTV, Dec 2015
# HocoNums <- c(130077, )
# DATES <- c("jun2015", "dec2015", "jun2016")
# acq2_fips <- unique(fcc_fips[HocoNum %in% HocoNums & 
#                                DATE %in% DATES, fips])
# fcc_fips[fips %in% acq2_fips & DATE == DATES[1], acq2:=-1]
# fcc_fips[fips %in% acq2_fips & DATE == DATES[2], acq2:=0]
# fcc_fips[fips %in% acq2_fips & DATE == DATES[3], acq2:=1]

#Acquisition 3 - Frontier-Verizon, Jun 2016
HocoNums <- c(130258, 131425)
DATES <- c("dec2015", "jun2016", "dec2016")
acq3_fips <- unique(fcc_fips[HocoNum %in% HocoNums & 
                               DATE %in% DATES, fips])
fcc_fips[fips %in% acq3_fips & DATE == DATES[1], acq3:=-1]
fcc_fips[fips %in% acq3_fips & DATE == DATES[2], acq3:=0]
fcc_fips[fips %in% acq3_fips & DATE == DATES[3], acq3:=1]

#Acquisition 4 - Bright House-Charter, Jun 2016
HocoNums <- c(130159, 130235)
DATES <- c("dec2015", "jun2016", "dec2016")
acq4_fips <- unique(fcc_fips[HocoNum %in% HocoNums & 
                               DATE %in% DATES, fips])
fcc_fips[fips %in% acq4_fips & DATE == DATES[1], acq4:=-1]
fcc_fips[fips %in% acq4_fips & DATE == DATES[2], acq4:=0]
fcc_fips[fips %in% acq4_fips & DATE == DATES[3], acq4:=1]

#Acquisition 5 - Time Warner-Charter, Jun 2016
HocoNums <- c(131352, 130235)
DATES <- c("dec2015", "jun2016", "dec2016")
acq5_fips <- unique(fcc_fips[HocoNum %in% HocoNums & 
                               DATE %in% DATES, fips])
fcc_fips[fips %in% acq5_fips & DATE == DATES[1], acq5:=-1]
fcc_fips[fips %in% acq5_fips & DATE == DATES[2], acq5:=0]
fcc_fips[fips %in% acq5_fips & DATE == DATES[3], acq5:=1]

#Acquisition 6 - XO Communications-Verizon, Jun 2017
HocoNums <- c(131513, 131425)
DATES <- c("dec2016", "jun2017", "dec2017")
acq6_fips <- unique(fcc_fips[HocoNum %in% HocoNums & 
                               DATE %in% DATES, fips])
fcc_fips[fips %in% acq6_fips & DATE == DATES[1], acq6:=-1]
fcc_fips[fips %in% acq6_fips & DATE == DATES[2], acq6:=0]
fcc_fips[fips %in% acq6_fips & DATE == DATES[3], acq6:=1]

#Acquisition 7 - CenturyLink and Level 3, Dec 2017
HocoNums <- c(130228, 130738)
DATES <- c("jun2017", "dec2017", "jun2018")
acq7_fips <- unique(fcc_fips[HocoNum %in% HocoNums & 
                               DATE %in% DATES, fips])
fcc_fips[fips %in% acq7_fips & DATE == DATES[1], acq7:=-1]
fcc_fips[fips %in% acq7_fips & DATE == DATES[2], acq7:=0]
fcc_fips[fips %in% acq7_fips & DATE == DATES[3], acq7:=1]


##################################################
#TRACT ACQUISITIONS
##################################################


#Acquisition 1 - AT&T-Frontier, Dec 2014
HocoNums <- c(130077, 130258)
DATES <- c("dec2014", "jun2015")
acq1_tract <- unique(fcc_tract[HocoNum %in% HocoNums & 
                               DATE %in% DATES, tract])
fcc_tract[tract %in% acq1_tract & DATE == DATES[1], acq1:=0]
fcc_tract[tract %in% acq1_tract & DATE == DATES[2], acq1:=1]

#Acquisition 2 - AT&T-DirecTV, Dec 2015
# HocoNums <- c(130077, )
# DATES <- c("jun2015", "dec2015", "jun2016")
# acq2_tract <- unique(fcc_tract[HocoNum %in% HocoNums & 
#                                DATE %in% DATES, tract])
# fcc_tract[tract %in% acq2_tract & DATE == DATES[1], acq2:=-1]
# fcc_tract[tract %in% acq2_tract & DATE == DATES[2], acq2:=0]
# fcc_tract[tract %in% acq2_tract & DATE == DATES[3], acq2:=1]

#Acquisition 3 - Frontier-Verizon, Jun 2016
HocoNums <- c(130258, 131425)
DATES <- c("dec2015", "jun2016", "dec2016")
acq3_tract <- unique(fcc_tract[HocoNum %in% HocoNums & 
                               DATE %in% DATES, tract])
fcc_tract[tract %in% acq3_tract & DATE == DATES[1], acq3:=-1]
fcc_tract[tract %in% acq3_tract & DATE == DATES[2], acq3:=0]
fcc_tract[tract %in% acq3_tract & DATE == DATES[3], acq3:=1]

#Acquisition 4 - Bright House-Charter, Jun 2016
HocoNums <- c(130159, 130235)
DATES <- c("dec2015", "jun2016", "dec2016")
acq4_tract <- unique(fcc_tract[HocoNum %in% HocoNums & 
                               DATE %in% DATES, tract])
fcc_tract[tract %in% acq4_tract & DATE == DATES[1], acq4:=-1]
fcc_tract[tract %in% acq4_tract & DATE == DATES[2], acq4:=0]
fcc_tract[tract %in% acq4_tract & DATE == DATES[3], acq4:=1]

#Acquisition 5 - Time Warner-Charter, Jun 2016
HocoNums <- c(131352, 130235)
DATES <- c("dec2015", "jun2016", "dec2016")
acq5_tract <- unique(fcc_tract[HocoNum %in% HocoNums & 
                               DATE %in% DATES, tract])
fcc_tract[tract %in% acq5_tract & DATE == DATES[1], acq5:=-1]
fcc_tract[tract %in% acq5_tract & DATE == DATES[2], acq5:=0]
fcc_tract[tract %in% acq5_tract & DATE == DATES[3], acq5:=1]

#Acquisition 6 - XO Communications-Verizon, Jun 2017
HocoNums <- c(131513, 131425)
DATES <- c("dec2016", "jun2017", "dec2017")
acq6_tract <- unique(fcc_tract[HocoNum %in% HocoNums & 
                               DATE %in% DATES, tract])
fcc_tract[tract %in% acq6_tract & DATE == DATES[1], acq6:=-1]
fcc_tract[tract %in% acq6_tract & DATE == DATES[2], acq6:=0]
fcc_tract[tract %in% acq6_tract & DATE == DATES[3], acq6:=1]

#Acquisition 7 - CenturyLink and Level 3, Dec 2017
HocoNums <- c(130228, 130738)
DATES <- c("jun2017", "dec2017", "jun2018")
acq7_tract <- unique(fcc_tract[HocoNum %in% HocoNums & 
                               DATE %in% DATES, tract])
fcc_tract[tract %in% acq7_tract & DATE == DATES[1], acq7:=-1]
fcc_tract[tract %in% acq7_tract & DATE == DATES[2], acq7:=0]
fcc_tract[tract %in% acq7_tract & DATE == DATES[3], acq7:=1]

fwrite(fcc_fips, "Data/cleaned/fcc_fips_instrument.csv")

fwrite(fcc_tract, "Data/cleaned/fcc_tract_instrument.csv")
