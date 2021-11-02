#' finds a remote hash to a short id string
#'
#' @description completes a partial hash or otherwise identifying string to a full hash.
#' If no such hash exists the method throws an error, except no_result_throws=FALSE.
#' Also throws if more than one hash matches.
#'
#' @param query search query
#' @param no_result_throws if set to FALSE, return NA if no such hash exists instead of throwing an error
#'
#' @return hash or NA
#'
#' @export
resolve_id <- function(partial_hash, no_result_throws = TRUE) {
  if( is.null(partial_hash) || is.na(partial_hash) ) {
    if( no_result_throws ) {
      stop("resolve_id: argument is null or na.")
    }
    return(NA);
  }
  response <- GET(
          url = paste0(pkg.env$dt_config[["server"]], "/resolve/", partial_hash),
          httr::add_headers(Authorization = diggeR:::get_token())
      )
  respcontent <- httr::content(response)
  if( response$status_code != 200 ) {
    if( ! no_result_throws
       & ( grepl("no hash matches", respcontent$error)
         | grepl("does not exist", respcontent$error))
       ) {
      return(NA)
    }
    stop(paste0("resolving id failed: ", httr::content(response)$error))
  }
  return( gsub("\"", "", rjson::fromJSON(httr::content(response))) )
}
