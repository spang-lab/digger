#' ensures that a file is present and correct
#'
#' @param filename file that is expected to be here
#' @param hash file hash (sha256sum) of the file.
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
