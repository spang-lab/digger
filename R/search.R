#' checks if the value is not NA and a character and returns the corresponding element of the search string
#' @param name key-part of the search query
#' @param value value-part of the search query
#'
#' @return key-value pair of the form key=value
check_and_build_character <- function(name, value) {
  if( length(value) == 1 && ! is.na(value) ){
    if( is.character(value) && length(value) == 1) {
      return(paste0(name, "=", value))
    } else {
      stop(paste0(value, ": invalid input"))
    }
  }
  return(NULL)
}
#' checks if the value is not NA and a vector of character strings and returns the corresponding element of the search string
#' @param name key-part of the search query
#' @param value value-part of the search query
#'
#' @return key-value pair of the form key=value
check_and_build_character_vector <- function(name, values) {
  if( length(values) == 0 ) {
    return(NULL)
  }
  if( ! any(sapply(values, is.na)) ) {
    return(paste(
      sapply(values, function(x) {return(check_and_build_character(name, x))}),
      collapse="&"
    ))
  }
  return(NULL)
}
#' checks if the value is not NA and a date and returns the corresponding element of the search string
#' @param name key-part of the search query
#' @param value value-part of the search query
#'
#' @return key-value pair of the form key=value
check_and_build_date <- function(name, value) {
  if( length(value) == 1 && ! is.na(value)) {
    return(paste0(name, "=", paste(as.Date(value))))
  }
  return(NULL)
}
#' checks if the value is not NA and a hash and returns the corresponding element of the search string
#' @param name key-part of the search query
#' @param value value-part of the search query
#'
#' @return key-value pair of the form key=value
check_and_build_hash <- function(name, value) {
  if( length(value) == 1 && ! is.na(value)) {
    if( regexp("[a-z0-9]{3,64}", value) > 0 ){
      return(paste0(name, "=", value))
    } else {
      stop(paste0("not a valid hash: ", value))
    }
  }
  return(NULL)
}
#' builds the URL search string needed to query datatomb
#'
#' @param global_search searches all metadata fields for partial match
#' @param tags one tag or a vector of tags that must be attached to the dataset
#' @param name name of the dataset
#' @param author author of the dataset
#' @param description searches all descriptions for partial matches
#' @param after dataset must have been uploaded after the given date
#' @param before dataset must have been uploaded before the given date
#' @param parentOf dataset must be a parent of the given hash
#' @param hash the dataset's hash must (partially) match this hash
#' @param commit searches the generator tags (relevant, e.g., for glacier data sets)
#' @param projectname name of the project within the dataset was generated
#'
#' @return searchstring (URL encoded)
build_searchstring <- function(
                               globalsearch=NA, tags=NA, name=NA, author=NA,
                               description=NA, after=NA, before=NA,
                               parentOf=NA, hash=NA, commit=NA, projectname=NA) {
  return(URLencode(paste0(c(
    check_and_build_character("any", globalsearch),
    check_and_build_character_vector("tag", tags),
    check_and_build_character("name", name),
    check_and_build_character("author", author),
    check_and_build_character("description", description),
    check_and_build_date("after", after),
    check_and_build_date("before", before),
    check_and_build_hash("child", parentOf),
    check_and_build_hash("hash", hash),
    check_and_build_character("commit", commit),
    check_and_build_character("projectname", projectname)),
    sep="", collapse="&")))
}
#' search datatomb for datasets
#'
#' @description Searches datatomb for datasets using keywords or free text. Refer to the datatomb documentation for more details and to metadata() if more information on a specific dataset is needed.
#'
#' @param global_search searches all metadata fields for partial match
#' @param tags one tag or a vector of tags that must be attached to the dataset
#' @param name name of the dataset
#' @param author author of the dataset
#' @param description searches all descriptions for partial matches
#' @param after dataset must have been uploaded after the given date
#' @param before dataset must have been uploaded before the given date
#' @param parentOf dataset must be a parent of the given hash
#' @param hash the dataset's hash must (partially) match this hash
#' @param commit searches the generator tags (relevant, e.g., for glacier data sets)
#' @param projectname name of the project within the dataset was generated
#'
#' @return a tibble / dataframe of search results which includes the name, hash, projectname and the description of the dataset
#'
#' @examples
#' search("dtd.model")
#' search(tags=c("dtd.model", "macro"), author="mschoen")
#'
#' @export
search <- function(global_search, tags=NA, name=NA, author=NA,
                   description=NA, after=NA, before=NA,
                   parentOf=NA, hash=NA, commit=NA, projectname=NA) {
  if( missing(global_search) ) {
    global_search <- NA
  }
  searchstring <- build_searchstring(global_search, tags, name, author,
                                     description, after, before,
                                     parentOf, hash, commit, projectname)
  response <- httr::GET(
      url = paste0(
        pkg.env$dt_config[["server"]],
        "/meta/search?", searchstring,
        "&properties=hash,projectname,name,description"),
      httr::add_headers(Authorization = diggeR:::get_token())
  )
  if( response$status_code != 200 ) {
    stop(paste0("search failed: ", httr::content(response)$error))
  }

  reslist <- rjson::fromJSON(httr::content(response))

  result <- tibble::tibble()
  for( f in reslist ) {
    result <- rbind(result, tibble::tibble(
                                name = f$name,
                                hash = f$hash,
                                projectname = ifelse(is.null(f$projectname), NA, f$projectname),
                                description = ifelse(is.null(f$description), NA, f$description)
                              ))
  }
  return(result)
}
