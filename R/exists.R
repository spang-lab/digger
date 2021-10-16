#' checks if a hash exists remotely
#' @description checks if a hash or its abbreviated version
#' already exists on datatomb (and is readable to the user)
#'
#' @param id hash or abbreviated hash to check for
#'
#' @return TRUE, if the hash exists and is readable, FALSE otherwise
#'
#' @export
exists <- function(id) {
  if(! is.na(diggeR::resolve_id(id, no_result_throws = FALSE))) {
    return(TRUE)
  }
  return(FALSE)
}
