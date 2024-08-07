% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calc_ecoregion.R
\name{ecoregion}
\alias{ecoregion}
\alias{calc_ecoregion}
\title{Calculate terrestrial ecoregions statistics (TEOW) based on WWF}
\usage{
calc_ecoregion()
}
\value{
A function that returns an indicator tibble with ecoregion type as
variable and corresponding area (in ha) as value.
}
\description{
This function allows to efficiently retrieve the name of the ecoregions
and compute the corresponding area from Terrestrial Ecoregions of the
World (TEOW) - World Wildlife Fund (WWF) for polygons. For each polygon,
the name and area of the ecoregions (in hectare) is returned.
The required resources for this indicator are:
\itemize{
\item \link{teow}
}
}
\examples{
\dontshow{
mapme.biodiversity:::.copy_resource_dir(file.path(tempdir(), "mapme-data"))
}
\dontrun{
library(sf)
library(mapme.biodiversity)

outdir <- file.path(tempdir(), "mapme-data")
dir.create(outdir, showWarnings = FALSE)

mapme_options(
  outdir = outdir,
  verbose = FALSE
)

aoi <- system.file("extdata", "sierra_de_neiba_478140_2.gpkg",
  package = "mapme.biodiversity"
) \%>\%
  read_sf() \%>\%
  get_resources(get_teow()) \%>\%
  calc_indicators(calc_ecoregion()) \%>\%
  portfolio_long()

aoi
}
}
\keyword{indicator}
