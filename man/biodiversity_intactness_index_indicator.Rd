% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calc_biodiversity_intactness_index.R
\docType{data}
\name{biodiversity_intactness_index_indicator}
\alias{biodiversity_intactness_index_indicator}
\alias{calc_biodiversity_intactness_index}
\title{Calculate Biodiversity Intactness Index}
\format{
A function that returns an indicator tibble with variable
biodiversity_intactness_index and corresponding values (unitless) as value.
}
\usage{
calc_biodiversity_intactness_index()
}
\description{
This function calculates the mean biodiversity intactness index for a region.
}
\details{
The required resources for this indicator are:
\itemize{
\item \link{biodiversity_intactness_index_resource}
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

lbii <- system.file("res", "biodiversity_intactness_index", "lbii.asc",
                    package = "mapme.biodiversity")

aoi <- read_sf(
  system.file("extdata", "shell_beach_protected_area_41057_B.gpkg",
              package = "mapme.biodiversity"
))
aoi <- get_resources(aoi, get_biodiversity_intactness_index(lbii))
aoi <- calc_indicators(aoi, calc_biodiversity_intactness_index())
aoi <- portfolio_long(aoi)

aoi
}
}
\keyword{indicator}
