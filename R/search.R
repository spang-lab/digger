#' search datatomb
#TODO docstring when signature is final
#TODO keyword based search query
search <- function(search_string, silent = FALSE) {
    response <- httr::GET(
        url = paste0(
          pkg.env$dt_config[["server"]],
          "/meta/search?any=",
          search_string,
          "&properties=hash,projectname,name,description"),
        httr::add_headers(Authorization = digger:::get_token())
    )
    if( response$status_code != 200 ) {
      stop(paste0("search failed: ", httr::content(response)$error))
    }

    reslist <- rjson::fromJSON(httr::content(response))

    result <- tibble()
    for( f in reslist ) {
      result <- rbind(result, tibble(
                                  name = f$name,
                                  hash = f$hash,
                                  projectname = f$projectname,
                                  description = f$description
                                ))
    }
    return(result)
}
