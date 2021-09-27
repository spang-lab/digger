#' download metadata from datatomb
#'
#' @param hash the datatomb identifier of a dataset. may also be a unique substring.
#'
#' @return list with all available metadata
#'
#' @export
#'
metadata <- function(hash) {
  meta <- GET(
          url = paste0(pkg.env$dt_config[["server"]], "/meta/", hash),
          httr::add_headers(Authorization = digger:::get_token())
      )
  if( meta$status_code != 200 ) {
    stop(paste0("metadata download failed: ", httr::content(meta)$error))
  }
  return( rjson::fromJSON(httr::content(meta)) )
}
