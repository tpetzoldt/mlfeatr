# Define S4 generics

#' @title Transform Data
#'
#' @description Transforms the data using the provided functions.
#'
#' @param object A `preproc_data` object.
#' @param funs A named list of functions to apply to the data.
#'
#' @return A `preproc_data` object with the transformed data.
#'
#' @include aaa_classes.R
#'
#' @export
setGeneric("transform_data", function(object, funs) standardGeneric("transform_data"))

#' @title Inverse Transform Data
#'
#' @description Applies the inverse transformation to the data.
#'
#' @param object A `preproc_data` object.
#'
#' @return A `preproc_data` object with the inverse transformed data.
#' @export
setGeneric("inverse_transform", function(object) standardGeneric("inverse_transform"))

#' @title Scale Data
#'
#' @description Scales the data using the stored parameters.
#'
#' @param object A `preproc_data` object.
#'
#' @return A `preproc_data` object with the scaled data.
#' @export
setGeneric("scale_x", function(object) standardGeneric("scale_x"))


#' @title Get Training Data (X)
#'
#' @description Extracts the training data (X) from the preprocessed data.
#'
#' @param object A `preproc_data` object.
#' @param as_data_frame logical TRUE if the function should return a data frame.
#' @param ... Additional arguments (currently not used).
#'
#' @return A data frame or matrix containing the training data (X).
#' @export
setGeneric("get_x_train", function(object, ...) standardGeneric("get_x_train"))

#' @title Get Test Data (X)
#'
#' @description Extracts the test data (X) from the preprocessed data.
#'
#' @param object A `preproc_data` object.
#' @param as_data_frame logical TRUE if the function should return a data frame.
#' @param ... Additional arguments (currently not used).
#'
#' @return A data frame or matrix containing the test data (X).
#' @export
setGeneric("get_x_test", function(object, ...) standardGeneric("get_x_test"))

#' @title Get All Data (X)
#'
#' @description Extracts all the data (X) from the preprocessed data.
#'
#' @param object A `preproc_data` object.
#' @param as_data_frame logical TRUE if the function should return a data frame.
#' @param ... Additional arguments (currently not used).
#'
#' @return A data frame or matrix containing all the data (X).
#' @export
setGeneric("get_x_all", function(object, ...) standardGeneric("get_x_all"))

#' @title Get Training Data (Y)
#'
#' @description Extracts the training data (Y) from the preprocessed data.
#'
#' @param object A `preproc_data` object.
#' @param as_data_frame logical TRUE if the function should return a data frame.
#' @param ... Additional arguments (currently not used).
#'
#' @return A data frame or matrix containing the training data (Y).
#' @export
setGeneric("get_y_train", function(object, ...) standardGeneric("get_y_train"))

#' @title Get Test Data (Y)
#'
#' @description Extracts the test data (Y) from the preprocessed data.
#'
#' @param object A `preproc_data` object.
#' @param as_data_frame logical TRUE if the function should return a data frame.
#' @param ... Additional arguments (currently not used).
#'
#' @return A data frame or matrix containing the test data (Y).
#' @export
setGeneric("get_y_test", function(object, ...) standardGeneric("get_y_test"))

#' @title Get All Data (Y)
#'
#' @description Extracts all the data (Y) from the preprocessed data.
#'
#' @param object A `preproc_data` object.
#' @param as_data_frame logical TRUE if the function should return a data frame.
#' @param ... Additional arguments (currently not used).
#'
#' @return A data frame or matrix containing all the data (Y).
#' @export
setGeneric("get_y_all", function(object, ...) standardGeneric("get_y_all"))


# Implement methods for the generics

#' @describeIn transform_data Method for transforming data in a `preproc_data` object.
setMethod("transform_data", signature = c(object = "preproc_data", funs = "list"),
          function(object, funs) {
            df <- object@data
            for (col in intersect(names(df), names(funs))) {
              df <- df |>
                mutate(across(all_of(col), .fns = funs[[col]]))
            }
            object@params@transformed <- TRUE
            object@data <- df
            return(object)
          })
#' @describeIn transform_data Method for transforming data in a `preproc_data` object.
setMethod("transform_data", signature = c(object = "preproc_data"),
          function(object) {
            df <- object@data
            funs <- object@params@fun_transform
            for (col in intersect(names(df), names(funs))) {
              df <- df |>
                mutate(across(all_of(col), .fns = funs[[col]]))
            }
            object@params@transformed <- TRUE
            object@data <- df
            return(object)
          })




#' @describeIn inverse_transform Method for inverse transforming data in a `preproc_data` object.
setMethod("inverse_transform", signature = c(object = "preproc_data"),
          function(object) {
            if (object@params@transformed) {
              df <- object@data
              funs <- object@params@fun_inverse
              for (col in intersect(names(df), names(funs))) {
                df <- df |>
                  mutate(across(all_of(col), .fns = funs[[col]]))
              }
              object@data <- df
              object@params@transformed <- FALSE
            } else {
              warning("No inverse transformation. Object was not transformed.")
            }
            # mark inverse transformed object with NA to avoid further transformations
            object@params@transformed <- NA
            return(object)
          })

#' @describeIn scale_x Method for scaling data in a `preproc_data` object.
setMethod("scale_x", signature = "preproc_data",
          function(object) {
            params <- object@params
            df <- object@data

            cols_to_remove <- c(params@id_col, params@target_col, params@split_col)

            scaled_df <- df |>
              select(-all_of(cols_to_remove)) |>
              mutate(across(everything(),
                \(.x) {
                  if (params@scale_method == "scale") {
                    (.x - params@mean_vals[cur_column()] ) / params@sd_vals[cur_column()]
                  } else if (params@scale_method == "norm") {
                    (.x - params@min_vals[cur_column()] ) / (params@max_vals[cur_column()] - params@min_vals[cur_column()])
                  } else {
                  .x
                }
              }))

            non_scaled_df <- df |> select(all_of(cols_to_remove))
            object@data <- bind_cols(non_scaled_df, scaled_df)

            return(object)
          })

#' @describeIn get_x_train Method for extracting training data (X).
setMethod("get_x_train", signature = "preproc_data",
          function(object, as_data_frame = FALSE) {
            params <- object@params
            df <- object@data
            cols_to_remove <- c(params@id_col, params@target_col, params@split_col)
            x_train <- df |> dplyr::filter(!.data[[params@split_col]]) |> select(-all_of(cols_to_remove))
            if (!as_data_frame) {
              return(as.matrix(x_train))
            } else {
              return(x_train)
            }
          })

#' @describeIn get_x_test Method for extracting test data (X).
setMethod("get_x_test", signature = "preproc_data",
          function(object, as_data_frame = FALSE) {
            params <- object@params
            df <- object@data
            cols_to_remove <- c(params@id_col, params@target_col, params@split_col)
            x_test <- df |> dplyr::filter(.data[[params@split_col]]) |> select(-all_of(cols_to_remove))
            if (!as_data_frame) {
              return(as.matrix(x_test))
            } else {
              return(x_test)
            }
          })

#' @describeIn get_x_all Method for extracting all data (X).
setMethod("get_x_all", signature = "preproc_data",
          function(object, as_data_frame = FALSE) {
            params <- object@params
            df <- object@data
            cols_to_remove <- c(params@id_col, params@target_col, params@split_col)
            x_all <- df |> select(-all_of(cols_to_remove))
            if (!as_data_frame) {
              return(as.matrix(x_all))
            } else {
              return(x_all)
            }
          })

#' @describeIn get_y_train Method for extracting training data (Y).
setMethod("get_y_train", signature = "preproc_data",
          function(object, as_data_frame = FALSE) {
            params <- object@params
            df <- object@data
            y_train <- df |> dplyr::filter(!.data[[params@split_col]]) |>
              select(all_of(params@target_col))
            if (!as_data_frame) {
              return(as.matrix(y_train))
            } else {
              return(y_train)
            }
          })

#' @describeIn get_y_test Method for extracting test data (Y).
setMethod("get_y_test", signature = "preproc_data",
          function(object, as_data_frame = FALSE) {
            params <- object@params
            df <- object@data
            y_test <- df |> dplyr::filter(.data[[params@split_col]]) |>
              select(all_of(params@target_col))
            if (!as_data_frame) {
              return(as.matrix(y_test))
            } else {
              return(y_test)
            }
          })

#' @describeIn get_y_all Method for extracting all data (Y).
setMethod("get_y_all", signature = "preproc_data",
          function(object, as_data_frame = FALSE) {
            params <- object@params
            df <- object@data
            y_all <- df |> select(all_of(params@target_col))
            if (!as_data_frame) {
              return(as.matrix(y_all))
            } else {
              return(y_all)
            }
          })


#' @title Create Preprocessed Data Object
#'
#' @description Constructs a `preproc_data` object, calculates scaling parameters,
#'   and optionally applies initial data transformations.
#'
#' @param data A data frame containing the raw data.
#' @param id_col Character vector specifying the name of the ID column (optional).
#' @param target_col Character vector specifying the name of the target variable column.
#' @param split_col Character vector specifying the name of the column used for
#'   train/test split.
#' @param scale_option Character string specifying the scaling option.
#'   Must be one of "train", "test", or "both". Defaults to "train".
#' @param scale_method Character string specifying the scaling method.
#'   Must be one of "scale" (standardization) or "norm" (normalization).
#'   Defaults to "scale".
#' @param fun_transform A named list of functions to apply to the data *before* scaling.
#'   The names of the list elements should correspond to the columns to transform.
#' @param fun_inverse A named list of functions representing the inverse
#'   transformations of `fun_transform`.  These are applied during the
#'   `inverse_transform` method.
#' @param autotransform If `TRUE` variables are transformed during object creation.
#'
#' @return A `preproc_data` object.
#'
#' @details
#' This function calculates scaling parameters (mean, standard deviation, min, max)
#' based on the specified `scale_option` and `scale_method`. It then creates a
#' `preproc_data` object, storing the original data and the calculated parameters.
#' If `fun_transform` is provided, it applies the specified transformations to
#' the data before creating the object.
#'
#' @examples
#' # Example usage (replace with your actual data and column names)
#' df <- data.frame(
#'   id = 1:10,
#'   x = runif(10),
#'   y = rnorm(10),
#'   z = 1:10,
#'   split = sample(c(TRUE, FALSE), 10, replace = TRUE)
#' )
#'
#' transformations <- list(
#'   x = log,
#'   y = \(y) sqrt(5 + y),
#'   z = \(z) z^2
#' )
#'
#' inverse_transformations <- list(
#'   x = exp,
#'   y = \(y) y^2 - 5,
#'   z = sqrt
#' )
#'
#' prep_data <- create_preprocessed_data(
#'   df, id_col = "id", target_col = "y", split_col = "split",
#'   fun_transform = transformations, fun_inverse = inverse_transformations)
#' print(prep_data)
#'
#' @export
create_preprocessed_data <- function(data, id_col = NULL, target_col, split_col,
                                     scale_option = "train", scale_method = "scale",
                                     fun_transform = NULL, fun_inverse = NULL,
                                     autotransform = FALSE) {


  ## define which columns to use
  cols_to_remove <- if (!is.null(id_col)) {
    c(id_col, target_col, split_col)
  } else {
    c(target_col, split_col)
  }

  ## split data
  train_data <- data |> dplyr::filter(.data[[split_col]])
  test_data <- data |> dplyr::filter(!.data[[split_col]])
  all_data <- data

  ## calculate scaling parameters
  data_for_scaling <-
    switch(scale_option,
           train = train_data |> select(-all_of(cols_to_remove)),
           test =  test_data  |> select(-all_of(cols_to_remove)),
           both =  all_data   |> select(-all_of(cols_to_remove))
    )

  mean_vals <- apply(data_for_scaling, 2, mean)
  sd_vals   <- apply(data_for_scaling, 2, sd)
  min_vals  <- apply(data_for_scaling, 2, min)
  max_vals  <- apply(data_for_scaling, 2, max)


  params <- new("preproc_params",
                id_col = id_col, target_col = target_col, split_col = split_col,
                scale_option = scale_option, scale_method = scale_method,
                mean_vals = mean_vals, sd_vals = sd_vals,
                min_vals = min_vals, max_vals = max_vals,
                fun_transform = fun_transform, fun_inverse = fun_inverse,
                transformed = autotransform)

  # Apply initial transformation if provided and autotransform = TRUE
  if (!is.null(fun_transform) & autotransform) {
    data <- transform_data(new("preproc_data", data = data, params = params), fun_transform)@data
  }

  return(new("preproc_data", data = data, params = params))
}

