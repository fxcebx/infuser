#' Infuse a template with values.
#'
#' For more info and usage examples see the README on the \href{https://github.com/Bart6114/infuser}{\code{infuser} github page}.
#' To help prevent \href{https://xkcd.com/327/}{SQL injection attacks} (or other injection attacks), use a transformation function to escape special characters and provide it through the \code{transform_function} argument. \code{\link[dplyr]{build_sql}} is a great default escaping function for SQL templating.  For templating in other languages you will need to build/specify your own escaping function.
#'
#' @param  file_or_string the template file or a string containing the template
#' @param key_value_list a named list with keys corresponding to the parameters requested by the template, if specified, will be used instead of ...
#' @param ... different keys with related values, used to fill in the template
#' @param  variable_identifier the opening and closing character that denounce a variable in the template
#' @param default_char the character use to specify a default after
#' @param collapse_char the character used to collapse a supplied vector
#' @param transform_function a function through which all specified values are passed, can be used to make inputs safe(r).  dplyr::build_sql is a good default for SQL templating.
#' @param verbose verbosity level
#' @export
infuse <- function(file_or_string, key_value_list, ..., variable_identifier = c("{{", "}}"), default_char = "|", collapse_char = ",", transform_function = function(value) return(value), verbose=FALSE){

  template <-
    read_template(file_or_string)

  params_requested <-
    variables_requested(template, default_char = default_char, verbose=verbose)


  params_supplied <- if(!missing(key_value_list) && is.list(key_value_list)) list(...)

  if(!missing(key_value_list)){
    if(!is.list(key_value_list)) stop("Specified key_value_list is not a list-like object.")
    params_supplied <- key_value_list
  } else {
    params_supplied <- list(...)
  }


  for(param in names(params_requested)){

    pattern <- paste0(variable_identifier[1],
                      "\\s*?",
                      param,
                      "\\s*?" ,
                      variable_identifier[2],
                      "|",  # or match with default in place
                      variable_identifier[1],
                      "\\s*?",
                      param,
                      "\\s*?\\",
                      default_char,
                      ".*?",
                      variable_identifier[2])

    if(param %in% names(params_supplied)){
      ## param is supplied
      template<-
        gsub(pattern,
             ## do this as a paste function e.g. if user supplied c(1,2,3)
             ## pass it through the transform function
             transform_function(
                paste(params_supplied[[param]], collapse=collapse_char)
             ),
             template,
             perl = TRUE)

    } else if(!is.na(params_requested[[param]])){
      ## param is not supplied but a default is declared in the template
      template<-
        gsub(pattern,
             params_requested[[param]],
             template,
             perl = TRUE)
      if(verbose) warning(paste0("Requested parameter '", param, "' not supplied -- using default variable instead"))
    } else {
      ## don't do anything but give a warning
      warning(paste0("Requested parameter '", param, "' not supplied -- leaving template as-is"))
    }

  }

  ## add 'infuse' class to the character string, done to control show method
  class(template) <- append(class(template), "infuse")
  template

}

#' Shows which variables are requested by the template
#'
#' @param  file_or_string the template file or a string containing the template
#' @param  variable_identifier the opening and closing character that denounce a variable in the template
#' @param default_char the character use to specify a default after
#' @param verbose verbosity level
#' @export
variables_requested <- function(file_or_string, variable_identifier = c("{{", "}}"), default_char = "|", verbose=FALSE){
  template <-
    read_template(file_or_string)

  regex_expr <- paste0(variable_identifier[1],
                       "(.*?)",
                       variable_identifier[2])

  params <-
    regmatches(template, gregexpr(regex_expr, template, perl=T))[[1]]

  params <-
    gsub(regex_expr, "\\1", params, perl=T)

  params_splitted <-
    strsplit(params, default_char, fixed=T)

  param_list <- list()

  for(param in params_splitted){
    key <- trim(param[[1]])
    if(length(param) > 1){
      value <- trim(param[[2]])
    } else{
      value <- NA
    }
    param_list[key] <- value
  }

  # print out params requested by the template (and available default variables)
  if(verbose){
    print_requested_params(param_list)
  }



  param_list

}
