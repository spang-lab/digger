#' download a dataset from datatomb
#'
#' @param hash the datatomb identifier of a dataset. may also be a unique substring.
#' @param file local file target where the dataset will be saved. If NA, the file name of the data set is used.
#' @param check_file if set to FALSE, do not check for correctness after download
#'
#' @return path to the stored dataset
#'
#' @export
#'
# TODO streamed access? large files potentially fill memory
download <- function(hash, file=NA, check_file = TRUE) {
  hash <- resolve_hash(hash)
  response <- GET(
      url = paste0(pkg.env$dt_config[["server"]], "/", hash),
      httr::add_headers(Authorization = diggeR:::get_token())
  )
  if( response$status_code != 200 ) {
    stop(paste0("download failed: ", httr::content(response)$error))
  }
  binary_data <- httr::content(response, "raw")
  if( is.na(file) ){
      meta <- diggeR::metadata(hash)
      file = meta[["name"]]
  }
  if( ! dir.exists(dirname(file))) {
    warning(paste0("creating directory ", dirname(file)))
    dir.create(dirname(file), recursive=TRUE)
  }
  writeBin(
      object = binary_data,
      con = file
  )
  if( check_file ) {
    # the hash may be abbreviated (must be unique, otherwise the download would have failed):
    full_hash <- resolve_id(hash)
    check(file, full_hash)
  }
  return(file)
}
