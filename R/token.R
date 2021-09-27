#' validates the token against datatomb
#' throws if token is invalid and sets user and admin fields in pkg.env
#'
#' @param token access token as obtained by, e.g., auth.spang-lab.de
#'
#' @return nothing
#'
validate_token <- function(token) {
  response <- httr::GET(
      url = paste0(pkg.env$dt_config[['server']], "/auth"),
      httr::add_headers(Authorization = token)
  )
  if(response$status_code == 200) {
    response <- httr::content(response)
    pkg.env$user <- response$user
    pkg.env$admin <- response$isAdmin
  } else {
    stop("invalid token")
  }
}
#' returns datatomb user name
#'
#' @return user name
#' @export
datatomb_whoami <- function() {
  if( is.null(pkg.env$user) ) {
    return("anonymous")
  }
  return(pkg.env$user)
}
#' set token. validates the token and then sets pkg.env$token
#'
#' @param token access token as obtained by, e.g., auth.spang-lab.de
#'
#' @return datatomb user name
#' @export
set_token <- function(token) {
  # throws if invalid
  validate_token(token)
  pkg.env$token = token
  return(datatomb_whoami())
}
#' get token. returns the token stored in pkg.env$token
get_token <- function() {
  return(pkg.env$token)
}
#' invalidate authentication for the current session
deauth <- function() {
  pkg.env$token <- NULL
  pkg.env$user <- NULL
  pkg.env$admin <- NULL
}
