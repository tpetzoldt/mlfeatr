% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/set_transformations.R
\name{set_transformations}
\alias{set_transformations}
\alias{set_transformations,preproc_data-method}
\title{Set Transformations}
\usage{
set_transformations(object, fun_transform = NULL, fun_inverse = NULL)

\S4method{set_transformations}{preproc_data}(object, fun_transform = NULL, fun_inverse = NULL)
}
\arguments{
\item{object}{A `preproc_data` object.}

\item{fun_transform}{A named list of functions to apply to the data.  T
he names should correspond to the columns, and the values should be the functions.}

\item{fun_inverse}{A named list of functions representing the inverse
transformations.  The structure should be the same as `fun_transform`.}
}
\value{
A `preproc_data` object with the updated transformation functions.
}
\description{
Sets the transformation functions for a `preproc_data` object.
}
\section{Methods (by class)}{
\itemize{
\item \code{set_transformations(preproc_data)}: Method for setting transformations in a `preproc_data` object.

}}
