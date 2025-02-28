% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_preprocessed_data.R
\name{create_preprocessed_data}
\alias{create_preprocessed_data}
\title{Create Preprocessed Data Object}
\usage{
create_preprocessed_data(
  data,
  target_col,
  id_col = NULL,
  split_col = NULL,
  scale_option = c("train", "test", "all"),
  scale_method = c("zscore", "minmax", "none"),
  fun_transform = NULL,
  fun_inverse = NULL
)
}
\arguments{
\item{data}{A data frame containing the raw data.}

\item{target_col}{Character vector specifying the name of the target variable column.}

\item{id_col}{Character vector specifying the name of the ID column (optional).}

\item{split_col}{Character vector specifying the name of the column used for
train/test split.}

\item{scale_option}{Character string specifying the scaling option.
Must be one of "train", "test", or "all". Defaults to "train".}

\item{scale_method}{Character string specifying the scaling method.
Must be one of "zscore" (standardization) or "minmax" (normalization).
Defaults to "zscore".}

\item{fun_transform}{A named list of functions to apply to the data *before* scaling.
The names of the list elements should correspond to the columns to transform.}

\item{fun_inverse}{A named list of functions representing the inverse
transformations of `fun_transform`.  These are applied during the
`inverse_transform` method.}
}
\value{
A `feature_data` object.
}
\description{
Constructs a `feature_data` object, calculates scaling parameters,
  and optionally applies initial data transformations.
}
\details{
This function calculates scaling parameters (mean, standard deviation, min, max)
based on the specified `scale_option` and `scale_method`. It then creates a
`feature_data` object, storing the original data and the calculated parameters.
If `fun_transform` is provided, it applies the specified transformations to
the data before creating the object.

If no `id_col` is given, an additional column `id` with row numers is created.

If a `split_col` is missing, an random `split` column is created.
}
\examples{
# Example usage (replace with your actual data and column names)
df <- data.frame(
  id = 1:10,
  x = runif(10),
  y = rnorm(10),
  z = 1:10,
  split = sample(c(TRUE, FALSE), 10, replace = TRUE)
)

transformations <- list(
  x = log,
  y = \(y) sqrt(5 + y),
  z = \(z) z^2
)

inverse_transformations <- list(
  x = exp,
  y = \(y) y^2 - 5,
  z = sqrt
)

prep_data <- create_preprocessed_data(
  df, id_col = "id", target_col = "y", split_col = "split",
  fun_transform = transformations, fun_inverse = inverse_transformations)
print(prep_data)

}
