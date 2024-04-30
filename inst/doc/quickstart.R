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

## ----simplify-aoi, echo = FALSE-----------------------------------------------
aoi <- st_simplify(aoi, preserveTopology = TRUE, dTolerance = 500)

## ----cast---------------------------------------------------------------------
(aoi <- st_cast(aoi, to = "POLYGON")[1, ])

## ----chunking-----------------------------------------------------------------
aoi_gridded <- st_make_grid(
  x = st_bbox(aoi),
  n = c(10, 10),
  square = FALSE
) %>%
  st_intersection(aoi) %>%
  st_as_sf() %>%
  mutate(geom_type = st_geometry_type(x)) %>%
  filter(geom_type == "POLYGON") %>%
  select(-geom_type, geom = x) %>%
  st_as_sf()

metanames <- names(st_drop_geometry(aoi))
aoi_gridded[metanames] <- st_drop_geometry(aoi)
plot(aoi_gridded)

## ----init_portfolio-----------------------------------------------------------
# copying package internal resource to a temporary location
outdir <- file.path(tempdir(), "mapme.biodiversity")
dir.create(outdir)
resource_dir <- system.file("res", package = "mapme.biodiversity")
file.copy(resource_dir, outdir, recursive = TRUE)

mapme_options(
  outdir = file.path(outdir, "res"),
  verbose = TRUE
)

## ----query_indicator----------------------------------------------------------
available_indicators()
available_indicators("population_count")

## ----helppage_indicator, eval = FALSE-----------------------------------------
#  ?population_count
#  help(population_count)

## ----query_resources----------------------------------------------------------
available_resources()
available_resources("worldpop")

## ----helppage_resource, eval = FALSE------------------------------------------
#  ?worldpop
#  help(worldpop)

## ----get_worldpop-------------------------------------------------------------
aoi_gridded <- get_resources(x = aoi_gridded, get_worldpop(years = 2010:2015))

## ----get_multi_resources, eval = FALSE----------------------------------------
#  aoi_gridded <- get_resources(
#    x = aoi_gridded,
#    get_worldpop(years = 2010:2015),
#    get_gfw_treecover(version = "GFC-2021-v1.8")
#  )

## ----calc_indicator-----------------------------------------------------------
aoi_gridded <- calc_indicators(
  aoi_gridded,
  calc_population_count(engine = "zonal", stats = "sum")
)

## ----select_cols--------------------------------------------------------------
(aoi_gridded <- aoi_gridded %>% select(assetid, population_count))

## ----investigate_indicator----------------------------------------------------
aoi_gridded$population_count[10]

## ----plot_popcount, echo = FALSE----------------------------------------------
data <- aoi_gridded %>%
  filter(assetid == 5) %>%
  st_drop_geometry() %>%
  unnest(population_count)

pop <- data$population_count_sum
names(pop) <- data$year
barplot(pop,
  main = "Population totals over time",
  xlab = "Year", ylab = "Persons",
  pch = 16, col = "steelblue"
)

## ----unnest-------------------------------------------------------------------
geometries <- select(aoi_gridded, assetid)
aoi_gridded %>%
  st_drop_geometry() %>%
  tidyr::unnest(population_count)

## ----parallel, eval = FALSE---------------------------------------------------
#  library(future)
#  library(progressr)
#  
#  plan(multisession, workers = 6) # set up parallel plan with 6 concurrent threads
#  
#  with_progress({
#    aoi_gridded <- calc_indicators(
#      aoi_gridded,
#      calc_population_count(
#        engine = "zonal",
#        stats = "sum"
#      )
#    )
#  })
#  
#  plan(sequential) # close child processes

## ----portfolio_io, eval=FALSE-------------------------------------------------
#  tmp_output <- tempfile(fileext = ".gpkg")
#  write_portfolio(
#    x = aoi_gridded,
#    dsn = tmp_output
#  )
#  (portfolio_from_disk <- read_portfolio(tmp_output))

## ----delete_tmp, echo=FALSE, include=FALSE, eval=FALSE------------------------
#  file.remove(tmp_output)

