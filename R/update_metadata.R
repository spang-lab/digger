#' update metadata of a dataset
#'
#' @param hash hash of the file that should be updated
#' @param meta metadata object, e.g. built with build_metadata, or from downloading existing
#'
#' @export
#'
#' @examples
#' meta <- metadata(hash)
#' meta$share <- "public"
#' update_metadata(hash, meta)
update_metadata <- function(hash, meta) {
  response <- POST(
      url = paste0(pkg.env$dt_config[["server"]], "/meta/update/", hash),
      body = list(
        data = rjson::toJSON(meta)),
      httr::add_headers(Authorization = diggeR:::get_token())
  )
  if( response$status_code != 200 ) {
    stop(paste0("metadata update failed: ", httr::content(response)$error))
  }
}
