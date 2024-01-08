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

aoi_path <- system.file("extdata", "sierra_de_neiba_478140.gpkg", package = "mapme.biodiversity")
(aoi <- read_sf(aoi_path))

## ----cast---------------------------------------------------------------------
(aoi <- st_cast(aoi, to = "POLYGON")[1, ])

## ----chunking-----------------------------------------------------------------
aoi_gridded <- st_make_grid(
  x = st_bbox(aoi),
  n = c(10, 10),
  square = FALSE) %>%
  st_intersection(aoi) %>%
  st_as_sf() %>%
  mutate(geom_type = st_geometry_type(x)) %>%
  filter(geom_type == "POLYGON") %>%
  select(-geom_type, geom = x) %>%
  st_as_sf()

metanames <- names(st_drop_geometry(aoi))
aoi_gridded[metanames] <- st_drop_geometry(aoi)

## ----init_portfolio-----------------------------------------------------------
# copying package internal resource to a temporary location
outdir <- file.path(tempdir(), "mapme.biodiversity")
dir.create(outdir)
resource_dir <- system.file("res", package = "mapme.biodiversity")
file.copy(resource_dir, outdir, recursive = TRUE)

sample_portfolio <- init_portfolio(
  x = aoi_gridded,
  years = 2010:2015,
  outdir = file.path(outdir, "res"),
  tmpdir = outdir,
  verbose = TRUE
)
plot(sample_portfolio["assetid"])

## ----query_indicator----------------------------------------------------------
names(available_indicators())

## ----helppage_indicator, eval = FALSE-----------------------------------------
#  ?population_count
#  help(population_count)

## ----query_resources----------------------------------------------------------
names(available_resources())

## ----helppage_resource, eval = FALSE------------------------------------------
#  ?worldpop
#  help(worldpop)

## ----get_esalandcover---------------------------------------------------------
sample_portfolio <- get_resources(x = sample_portfolio, resources = "worldpop")

## ----get_multi_resources, eval = FALSE----------------------------------------
#  sample_portfolio <- get_resources(
#    x = sample_portfolio,
#    resources = c("worldpop", "gfw_treecover"),
#    vers_treecover = "GFC-2021-v1.9"
#  )

## ----calc_indicator-----------------------------------------------------------
sample_portfolio <- calc_indicators(sample_portfolio, indicators = "population_count",
                                    stats_popcount = "sum", engine = "zonal")

## ----select_cols--------------------------------------------------------------
(sample_portfolio <- sample_portfolio %>% select(assetid, WDPAID, population_count))

## ----investigate_indicator----------------------------------------------------
sample_portfolio$population_count[10]

## ----plot_landcover, echo = FALSE---------------------------------------------
data <- sample_portfolio %>%
  filter(assetid == 10) %>%
  st_drop_geometry() %>%
  unnest(population_count)

pop <- data$popcount_sum
names(pop) <- data$year
barplot(pop, main = "Population totals over time", 
        xlab = "Year", ylab = "Persons", 
        col = "steelblue")

## ----unnest-------------------------------------------------------------------
geometries <- select(sample_portfolio, assetid)
sample_portfolio %>%
  st_drop_geometry() %>%
  tidyr::unnest(population_count) %>%
  filter(assetid == 3)

## ----parallel, eval = FALSE---------------------------------------------------
#  library(future)
#  library(progressr)
#  
#  plan(multisession, workers = 6) # set up parallel plan with 6 concurrent threads
#  
#  with_progress({
#    portfolio <- calc_indicators(
#      sample_portfolio,
#      indicators = "population_count",
#      stats_popcount = "sum",
#      engine = "zonal"
#    )
#  })
#  
#  plan(sequential) # close child processes

## ----portfolio_io-------------------------------------------------------------
tmp_output <- tempfile(fileext = ".gpkg")
write_portfolio(
  x = sample_portfolio,
  dsn = tmp_output
)
(portfolio_from_disk <- read_portfolio(tmp_output))

## ----delete_tmp, echo=FALSE, include=FALSE------------------------------------
file.remove(tmp_output)

