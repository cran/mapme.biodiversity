% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_worldpop.R
\docType{data}
\name{worldpop}
\alias{worldpop}
\alias{get_worldpop}
\title{Population Count layer for year 2000-2020}
\source{
\url{https://www.worldpop.org/}
}
\usage{
get_worldpop(years = 2000)
}
\arguments{
\item{years}{A numeric vector indicating the years for which to make the
resource available.}
}
\value{
A function that returns an \code{sf} footprint object.
}
\description{
This resource is published by open spatial demographic data and research
organization called WorldPop. This resource represents the population
count, 1 km spatial resolution layers available to download from the year
2000 to 2020. The dataset is called as WorldPop Unconstrained Global Mosaics.
The encoded cell value represents the total number of people in that particular
grid cell.
}
\details{
It may be required to increase the timeout option to successfully download
theses WorldPop layers from their source location via e.g.
\code{options(timeout = 600)}.
}
\keyword{resource}
