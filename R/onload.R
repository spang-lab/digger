pkg.env <- new.env()

#' loads config from file or environment variables
#' executed automatically upon package load.
#' Config file is searched in $XDG_CONFIG_HOME/digger/config.yml
#' default configuration is used, if R_CONFIG_ACTIVE is set to a different value, a different configuration will be used.
#' see https://cran.r-project.org/web/packages/config/vignettes/introduction.html for details.
#'
.onLoad <- function(libname, pkgname) {
  xdg_home <- Sys.getenv("XDG_CONFIG_HOME")
  if( xdg_home == '' ) {
    homedir <- Sys.getenv("HOME")
    if( homedir == '' ) {
      # fall-back to current directory
      homedir <- getwd()
    }
    xdg_home <- paste0(Sys.getenv("HOME"), "/", ".config")
  }
  configdir <- paste0(xdg_home, "/", pkgname)
  if( ! dir.exists(configdir) ) {
    dir.create(configdir, recursive = TRUE)
  }
  configfile <- paste0(configdir, "/config.yml")
  if( ! file.exists(configfile) ) {
    warning(paste0(pkgname), " hasn't been configured. Edit ", configfile, " for persistent configuration")
  } else {
    pkg.env$dt_config <- config::get(file = configfile)
  }
  if( is.null(pkg.env$dt_config[['server']]) ) {
    warning("Server hasn't been configured. Falling back to https://data.spang-lab.de/api/v1.")
    pkg.env$dt_config[['server']] <- "https://data.spang-lab.de/api/v1"
  }
  # override token if given as env variable
  dt_access_token = Sys.getenv("ACCESS_TOKEN")
  if( dt_access_token != '' ) {
    pkg.env$dt_config$token = tryCatch(
      set_token(dt_access_token),
      error=function(errormsg) {
        warning(paste0(errormsg, ". Ignoring environment variable ACCESS_TOKEN."))
        set_token(pkg.env$dt_config$token)
      })
  } else {
    set_token(pkg.env$dt_config$token)
  }
  if( is.null(pkg.env$token) ) {
    warning("No access token set. Queries may fail or only public data sets are visible.")
  }
}
