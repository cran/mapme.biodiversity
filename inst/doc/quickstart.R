## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, message=FALSE-----------------------------------------------------
library(mapme.biodiversity)
library(sf)
library(dplyr)
library(tidyr)

aoi_path <- system.file("extdata", "gfw_sample.gpkg", package = "mapme.biodiversity")
aoi <- st_read(aoi_path, quiet = TRUE)
aoi

## ----simplify-aoi, echo = FALSE-----------------------------------------------
aoi <- st_simplify(aoi, preserveTopology = TRUE, dTolerance = 500)

## ----init-data-dir, echo=FALSE------------------------------------------------
outdir <- file.path(tempdir(), "mapme-resources")
mapme.biodiversity:::.copy_resource_dir(outdir)

## ----portfolio-opts-----------------------------------------------------------
outdir <- file.path(tempdir(), "mapme-resources")
dir.create(outdir, showWarnings = FALSE)

mapme_options(
  outdir = outdir,
  verbose = TRUE
)

## ----query-indicator----------------------------------------------------------
available_indicators()
available_indicators("treecover_area")

## ----help-indicator, eval = FALSE---------------------------------------------
#  ?treecover_area
#  help(treecover_area)

## ----query-resources----------------------------------------------------------
available_resources()
available_resources("gfw_treecover")

## ----help-resource, eval = FALSE----------------------------------------------
#  ?gfw_treecover
#  help(gfw_treecover)
#  ?gfw_lossyear
#  help(gfw_lossyear)

## ----get-gfw------------------------------------------------------------------
aoi <- get_resources(
  x = aoi,
  get_gfw_treecover(version = "GFC-2023-v1.11"),
  get_gfw_lossyear(version = "GFC-2023-v1.11")
)

## ----calc-indicator-----------------------------------------------------------
aoi <- calc_indicators(
  aoi,
  calc_treecover_area(years = 2000:2023, min_size = 1, min_cover = 30)
)

## ----print-aoi----------------------------------------------------------------
aoi

## ----print-indicator----------------------------------------------------------
aoi$treecover_area

## ----plot-treecover, echo = FALSE, warning=FALSE------------------------------
mapme_options(verbose = FALSE)
data <- portfolio_long(aoi)

plot(value ~ datetime, data,
  main = "Treecover over time",
  xlab = "Year", ylab = "ha",
  pch = 16, col = "steelblue"
)

## ----long-drop-geoms----------------------------------------------------------
geoms <- st_geometry(aoi)
portfolio_long(aoi, drop_geoms = TRUE)

## ----parallel-1, eval = FALSE-------------------------------------------------
#  library(future)
#  plan(list(sequential, tweak(cluster, workers = 6)))

## ----parallel, eval = FALSE---------------------------------------------------
#  library(progressr)
#  
#  plan(list(tweak(cluster, workers = 2), tweak(cluster, workers = 4)))
#  
#  with_progress({
#    aoi <- calc_indicators(
#      aoi,
#      calc_treecover_area(
#        min_size = 1,
#        min_cover = 30
#      )
#    )
#  })
#  
#  plan(sequential) # close child processes

## ----write-portfolio----------------------------------------------------------
dsn <- tempfile(fileext = ".gpkg")
write_portfolio(x = aoi, dsn = dsn, quiet = TRUE)
from_disk <- read_portfolio(dsn, quiet = TRUE)
from_disk

## ----delete-dsn, echo=FALSE---------------------------------------------------
file.remove(dsn)

