#' a function that extracts a hash from a list or data frame row
#' @param input any input (character, list,...) that contains exactly one hash
#'
#' @return character hash
resolve_hash <- function(input) {
  if( is.character(input) ) {
    candidates <- c(input)
  }
  if( is.list(input) || is.data.frame(input) ) {
    if( "hash" %in% names(input) ) {
      candidates <- c(input[["hash"]])
    } else {
      candidates <- names(input)
    }
  }
  hashes <- candidates[sapply(candidates, function(n){ return(regexpr("^[a-f0-9]{3,64}$", n) > 0)})]
  if( length(hashes) == 1 ) {
    return(hashes[1])
  } else if( length(hashes) > 1) {
    stop("more than one hash found")
  }
  stop("no usable hash found")
}
