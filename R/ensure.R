#' Ensures that a file is present and correct
#'
#' @description If the file is not present, it will be downloaded from datatomb.
#' If the file is present, it will be checked for correctness.
#' If it is corrupt, this function will fail, except replace=TRUE
#' is set, then the file will be overwritten with the correct version.
#'
#' @param filename file that is expected to be here
#' @param hash file hash (sha256sum) of the file.
#' @param replace if set to TRUE, replace the file instead of failing in the case of file corruption
#'
#' @export
ensure <- function(filename, hash, replace=FALSE) {
  if( ! file.exists(filename) ) {
    message("downloading file.")
    download(hash, file=filename)
  } else {
    message("file already present, checking correctness")
    correct <- check(filename, hash, error=FALSE)
    if( ! correct && replace ) {
      download(hash, file=filename)
    } else if( ! correct ) {
      stop("file is corrupt and won't be replaced.")
    }
  }
}
