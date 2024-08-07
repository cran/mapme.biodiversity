% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calc_gsw_transitions.R
\name{gsw_transitions}
\alias{gsw_transitions}
\alias{calc_gsw_transitions}
\title{Calculate Global Surface Water (GSW) Transitions}
\usage{
calc_gsw_transitions()
}
\value{
A function that returns an indicator tibble with transition classes
as variable and corresponding areas (in ha) as value.
}
\description{
GSW transition data contains information about the type of surface water
change for each pixel. The raster files have integer cell values between
\code{[0, 10]} that code for different transition classes:
}
\details{
\tabular{ll}{
   Value \tab Transition Class \cr
   1 \tab Permanent \cr
   2 \tab New Permanent \cr
   3 \tab Lost Permanent \cr
   4 \tab Seasonal \cr
   5 \tab New Seasonal \cr
   6 \tab Lost Seasonal \cr
   7 \tab Seasonal to Permanent \cr
   8 \tab Permanent to Seasonal \cr
   9 \tab Ephemeral Permanent \cr
   10 \tab Ephemeral Seasonal \cr
}


To aggregate, we sum up the area of each transition class for a given region.

The required resources for this indicator are:
\itemize{
\item \link{global_surface_water_transitions}
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
  get_resources(get_global_surface_water_transitions()) \%>\%
  calc_indicators(calc_gsw_transitions()) \%>\%
  portfolio_long()

aoi
}
}
\keyword{indicator}
