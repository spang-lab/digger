% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/onload.R
\name{.onLoad}
\alias{.onLoad}
\title{loads config from file or environment variables}
\usage{
.onLoad(libname, pkgname)
}
\description{
executed automatically upon package load.
Config file is searched in $XDG_CONFIG_HOME/diggeR/config.yml
default configuration is used, if R_CONFIG_ACTIVE is set to a different value, a different configuration will be used.
see https://cran.r-project.org/web/packages/config/vignettes/introduction.html for details.
}
