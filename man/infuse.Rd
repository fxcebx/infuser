% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/core.R
\name{infuse}
\alias{infuse}
\title{Infuse a template with values.}
\usage{
infuse(file_or_string, key_value_list, ..., variable_identifier = c("{{",
  "}}"), default_char = "|", collapse_char = ",",
  transform_function = function(value) return(value), verbose = FALSE)
}
\arguments{
\item{file_or_string}{the template file or a string containing the template}

\item{key_value_list}{a named list with keys corresponding to the parameters requested by the template, if specified, will be used instead of ...}

\item{...}{different keys with related values, used to fill in the template}

\item{variable_identifier}{the opening and closing character that denounce a variable in the template}

\item{default_char}{the character use to specify a default after}

\item{collapse_char}{the character used to collapse a supplied vector}

\item{transform_function}{a function through which all specified values are passed, can be used to make inputs safe(r).  dplyr::build_sql is a good default for SQL templating.}

\item{verbose}{verbosity level}
}
\description{
For more info and usage examples see the README on the \href{https://github.com/Bart6114/infuser}{\code{infuser} github page}.
To help prevent \href{https://xkcd.com/327/}{SQL injection attacks} (or other injection attacks), use a transformation function to escape special characters and provide it through the \code{transform_function} argument. \code{\link[dplyr]{build_sql}} is a great default escaping function for SQL templating.  For templating in other languages you will need to build/specify your own escaping function.
}

