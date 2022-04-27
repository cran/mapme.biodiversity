## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, message=FALSE-----------------------------------------------------
library(mapme.biodiversity)
library(sf)
library(dplyr)
library(ggplot2)

aoi_path <- system.file("extdata", "sierra_de_neiba_478140.gpkg", package = "mapme.biodiversity")
(aoi <- read_sf(aoi_path))

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

## ----init_portfolio, dpi = 50, out.width="120%", out.height="120%"------------
sample_portfolio <- init_portfolio(
  x = aoi_gridded,
  years = 2010,
  outdir = system.file("res", package = "mapme.biodiversity"),
  tmpdir = system.file("tmp", package = "mapme.biodiversity"),
  add_resources = FALSE,
  cores = 1,
  verbose = TRUE
)
plot(sample_portfolio["assetid"])

## ----query_indicator----------------------------------------------------------
names(available_indicators())

## ----helppage_indicator, eval = FALSE-----------------------------------------
#  ?chirpsprec
#  help(chirpsprec)

## ----query_resources----------------------------------------------------------
names(available_resources())

## ----helppage_resource, eval = FALSE------------------------------------------
#  ?chirps
#  help(chirps)

## ----get_chirps---------------------------------------------------------------
sample_portfolio <- get_resources(x = sample_portfolio, resources = "chirps")

## ----get_multi_resources, eval = FALSE----------------------------------------
#  sample_portfolio <- get_resources(x = sample_portfolio,
#                                    resources = c("chirps", "treecover2000"),
#                                    vers_treecover = "GFC-2020-v1.8")
#  

## ----calc_indicator-----------------------------------------------------------
sample_portfolio <- calc_indicators(sample_portfolio,
  indicators = "chirpsprec",
  scales_spi = 3,
  spi_prev_years = 8,
  engine = "extract"
)

## ----select_cols--------------------------------------------------------------
(sample_portfolio <- sample_portfolio %>% select(assetid, WDPAID, chirpsprec))

## ----investigate_indicator----------------------------------------------------
sample_portfolio$chirpsprec[10]

## ----plot_precipitation, echo = FALSE, warning=FALSE, dpi = 50----------------
sample_portfolio %>%
  filter(assetid == 10) %>%
  st_drop_geometry() %>%
  tidyr::unnest(chirpsprec) %>%
  mutate(sign = ifelse(anomaly < 0, "lower than average", "higher than average")) %>%
  ggplot() +
  geom_bar(aes(x = dates, y = anomaly, fill = sign), stat = "identity") +
  scale_fill_manual(values = c("darkblue", "brown2")) +
  labs(
    title = "Monthly precipitation anomaly for 2010 in regard to the 1981-2010 climate normal", x = "", y = "Precipitation anomaly [mm]",
    fill = "Anomaly"
  ) +
  theme_classic() +
  theme(legend.position = "bottom")

sample_portfolio %>%
  filter(assetid == 10) %>%
  st_drop_geometry() %>%
  tidyr::unnest(chirpsprec) %>%
  mutate(
    spi_3 = ifelse(is.na(spi_3), 0, spi_3),
    sign = ifelse(spi_3 < 0, "lower than average", "higher than average")
  ) %>%
  ggplot() +
  geom_bar(aes(x = dates, y = spi_3, fill = sign), stat = "identity") +
  scale_fill_manual(values = c("darkblue", "brown2")) +
  labs(
    title = "Monthly SPI value for 2010 (timescale = 3)", x = "Month", y = "SPI",
    fill = "SPI"
  ) +
  theme_classic() +
  theme(legend.position = "bottom")

sample_portfolio %>%
  filter(assetid == 10) %>%
  st_drop_geometry() %>%
  tidyr::unnest(chirpsprec) %>%
  ggplot() +
  geom_bar(aes(x = dates, y = absolute), stat = "identity", fill = "darkblue") +
  labs(title = "Sum of monthly precipitation 2010", x = "", y = "Precipitation sum [mm]") +
  theme_classic()

## ----unnest-------------------------------------------------------------------
geometries <- select(sample_portfolio, assetid)
sample_portfolio %>%
  st_drop_geometry() %>%
  tidyr::unnest(chirpsprec) %>%
  filter(assetid == 3)

## ----portfolio_io-------------------------------------------------------------
tmp_output <- tempfile(fileext = ".gpkg")
write_portfolio(
  x = sample_portfolio,
  dsn = tmp_output
)
(portfolio_from_disk <- read_portfolio(tmp_output))

## ----delete_tmp, echo=FALSE, include=FALSE------------------------------------
file.remove(tmp_output)

