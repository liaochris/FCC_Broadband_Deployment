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

# change directory as appropriate
setwd("~/Google Drive/Non-Academic Work/Research/Personal_FCC/")

directory <- "Data/export_uptake/results"

fcc_fips <- rbindlist(foreach(i = 1:9, .packages = c("data.table")) %do% {
  fread(paste(directory, dir(directory)[i], sep = "/"))
  })
fcc_fips[, YEAR:=substr(DATE, 4, 7)]
fcc_fips[,fips := str_pad(fips, 5, pad = "0")]

#HocoNum == -1 is for outside option
fips_uptake <- distinct(fcc_fips[,c("DATE", "YEAR", "fips", "county_approx_uptake", "fips_pop")])
fips_uptake[, HocoNum := -1]
fips_uptake[, fipsPopCovered := 0]
fips_uptake[, fipsPopCovered_uptake := (1-county_approx_uptake) * fips_pop]
fips_uptake[, fipsShare:=0]
fips_uptake[, fipsShare_uptake:=(1-county_approx_uptake)]
fcc_fips <- rbind(fcc_fips, fips_uptake)
setorder(fcc_fips, "fips", "YEAR", desc("DATE"), "HocoNum")

fcc_tract <- rbindlist(foreach(i = 10:18, .packages = c("data.table")) %do% {
  fread(paste(directory, dir(directory)[i], sep = "/"))
})
setnames(fcc_tract, "pcat_all_num", "tractUptake")
fcc_tract[,tract := str_pad(tract, 11, pad = "0")]
fcc_tract[,fips := str_pad(fips, 5, pad = "0")]

#HocoNum == -1 is for outside option
tract_uptake <- distinct(fcc_tract[,c("DATE", "YEAR", "tract", "fips", "pcat_all", "tractUptake", "tract_pop")])
tract_uptake[, HocoNum := -1]
tract_uptake[, tractPopCovered := 0]
tract_uptake[, tractPopCovered_uptake := (1-tractUptake) * tract_pop]
tract_uptake[, tractShare:=0]
tract_uptake[, tractShare_uptake:=(1-tractUptake)]
fcc_tract <- rbind(tract_uptake, fcc_tract)
setorder(fcc_tract, "tract", "YEAR", "DATE", "HocoNum")

fwrite(fcc_tract, "Data/cleaned/fcc_tract_agg.csv")
plot(fcc_tract[HocoNum!=-1, sum(tractPopCovered_uptake)/sum(tractPopCovered), "YEAR"])
fwrite(fcc_fips, "Data/cleaned/fcc_fips_agg.csv")
plot(fcc_fips[HocoNum!=-1, sum(fipsPopCovered_uptake)/sum(fipsPopCovered), "YEAR"])

tract_hhi <- fcc_tract[,c("tract", "DATE", "YEAR", "HocoNum", "tractShare_uptake")]
tract_hhi[,tractShare_uptake := (tractShare_uptake * 100)^2]
tract_hhi <- tract_hhi[HocoNum != -1,sum(tractShare_uptake), c("tract", "DATE", "YEAR")]
setnames(tract_hhi, "V1", "HHI")
fwrite(tract_hhi, "Data/cleaned/tract_hhi_new.csv")
plot(tract_hhi[,mean(HHI),"YEAR"])

fips_hhi <- fcc_fips[,c("fips", "DATE", "YEAR", "HocoNum", "fipsShare_uptake")]
fips_hhi[,fipsShare_uptake := (fipsShare_uptake * 100)^2]
fips_hhi <- fips_hhi[HocoNum != -1,sum(fipsShare_uptake), c("fips", "DATE", "YEAR")]
setnames(fips_hhi, "V1", "HHI")
fwrite(tract_hhi, "Data/cleaned/fips_hhi_new.csv")
plot(fips_hhi[,mean(HHI),"YEAR"])
