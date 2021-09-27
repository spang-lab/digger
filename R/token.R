#' validates the token against datatomb
#' throws if token is invalid and sets user and admin fields in pkg.env
#'
#' @param token access token as obtained by, e.g., auth.spang-lab.de
#'
#' @return nothing
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
#' set token. validates the token and then sets pkg.env$token
set_token <- function(token) {
  # throws if invalid
  validate_token(token)
  pkg.env$token = token
}
#' get token. returns the token stored in pkg.env$token
get_token <- function() {
  return(pkg.env$token)
}
