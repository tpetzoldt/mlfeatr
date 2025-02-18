% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/feat.R
\name{get_y_train}
\alias{get_y_train}
\alias{get_y_train,preproc_data-method}
\title{Get Training Data (Y)}
\usage{
get_y_train(object, ...)

\S4method{get_y_train}{preproc_data}(object, as_data_frame = FALSE)
}
\arguments{
\item{object}{A `preproc_data` object.}

\item{...}{Additional arguments (currently not used).}

\item{as_data_frame}{logical TRUE if the function should return a data frame.}
}
\value{
A data frame or matrix containing the training data (Y).
}
\description{
Extracts the training data (Y) from the preprocessed data.
}
\section{Methods (by class)}{
\itemize{
\item \code{get_y_train(preproc_data)}: Method for extracting training data (Y).

}}
