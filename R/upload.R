#' upload a dataset to datatomb
#'
#' @param file file to upload (on the file system)
#' @param meta metadata, if missing, the metadata is built with build_metadata from the additional args
#' @param ... metadata as key-value pairs, only considered if meta is missing. see build_metadata
#'
#' @return hash of the uploaded file
#'
#' @export
#'
#' @examples
#' upload(file="datafile.h5", tags=c("testtag", "anothertesttag"), share="private")
#'
#' upload(file="datafile.h5", description="a test file", projectname="myproject",
#'        tags=c("testtag", "anothertesttag"), share="private", data=list(additional="metadata"))
#'
upload <- function(file, meta, ...) {
  if( missing(meta) ) {
    meta <- build_metadata(file, ...)
  }
  if( ! file.exists(file) ) {
    stop(paste0("file \"", file, " does not exist."))
  }
  httpversion <- ifelse(
    as.integer(paste0(unlist(strsplit(curl::curl_version()$version, "[.]")), sep="", collapse="")) < 7791,
    1L,
    2L)
  httr::set_config(httr::config(http_version = httpversion))
  response <- httr::POST(
        url = paste0(pkg.env$dt_config[["server"]], "/upload"),
        body = list(
          file = upload_file(file),
          data = rjson::toJSON(meta)),
        config = httr::add_headers(Authorization = diggeR:::get_token())
    )
  httr::reset_config() # stop using HTTP1

  if( response$status_code != 200 ) {
    stop(paste0("upload failed: ", httr::content(response)$error))
  }
  remote_hash <- rjson::fromJSON(httr::content(response))$hash
  check(file, remote_hash)
  return(remote_hash)
}
