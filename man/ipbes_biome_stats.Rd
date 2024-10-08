% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calc_ipbes_biomes.R
\name{ipbes_biome_stats}
\alias{ipbes_biome_stats}
\alias{calc_ipbes_biomes}
\title{Calculate areal statistics for IBPES Biomes}
\usage{
calc_ipbes_biomes()
}
\value{
A function that returns an indicator tibble with the biome class
as variable and the respective area (in ha) as value.
}
\description{
This indicator calculates the areal distribution of different biome classes
within an asset based on the IBPES biomes dataset.
}
\details{
The required resources for this indicator are:
\itemize{
\item \link{ipbes_biomes}
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

aoi <- system.file("extdata", "shell_beach_protected_area_41057_B.gpkg",
  package = "mapme.biodiversity"
) \%>\%
  read_sf() \%>\%
  get_resources(get_ipbes_biomes()) \%>\%
  calc_indicators(calc_ipbes_biomes()) \%>\%
  portfolio_long()

aoi
}
}
\keyword{indicator}
