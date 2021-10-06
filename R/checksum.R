#' reads a file and computes its sha256sum.
#'
#' @param filename file to read
#'
#' @return sha256sum
#'
#' @export
sha256sum <- function(filename) {
  if( ! file.exists(filename) ) {
    stop(paste0("file ", filename, " does not exist."))
  }
  f <- file(filename, "rb")
  crc <- digest(readBin(f, raw(), file.info(filename)$size), algo="sha256", serialize=FALSE)
  close(f)
  return(crc)
}

#' checks if a file matches the given checksum
#'
#' @param filename file to check
#' @param checksum sha256sum to check against
#' @param error if set to false, don't throw but return FALSE.
#'
#' @return TRUE, if the file is correct. FALSE, if the file is incorrect and error=FALSE
#'
#' @export
check <- function(filename, checksum, error=TRUE) {
  if( is.null(checksum) || length(checksum) != 1 || nchar(checksum) != 64 ) {
    stop("invalid hash, must provide a valid sha256sum.")
  }
  crc <- sha256sum(filename)
  if( crc == checksum ) {
    return(TRUE)
  }
  if( error ) {
    stop(paste0("file \"", filename, " has checksum ", crc, " but is expected to have ", checksum))
  }
  return(FALSE)
}
