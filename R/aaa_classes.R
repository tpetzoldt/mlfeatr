#' Union Class of List or NULL
#'
#' Class to slots that can be empty
#'
#' @name list_or_NULL-class
#'
#' @include mlfeatr-package.R
#'
#' @exportClass list_or_NULL
#'
setClassUnion("list_or_NULL", c("list", "NULL"))

#' @title Preprocessing Parameters
#'
#' @description An S4 class to store the parameters used in the preprocessing pipeline.
#'
#' @slot id_col Character vector specifying the name of the ID column.
#' @slot target_col Character vector specifying the name of the target variable column.
#' @slot split_col Character vector specifying the name of the column used for train/test split.
#' @slot scale_option Character string specifying the scaling option ("train", "test", "both").
#' @slot scale_method Character string specifying the scaling method ("scale", "norm").
#' @slot mean_vals Numeric vector storing the mean values for scaling.
#' @slot sd_vals Numeric vector storing the standard deviation values for scaling.
#' @slot min_vals Numeric vector storing the minimum values for normalization.
#' @slot max_vals Numeric vector storing the maximum values for normalization.
#' @slot fun_transform List of functions for data transformation.
#' @slot fun_inverse List of functions for inverse data transformation.
#' @slot transformed Boolean value, `TRUE` if object contains transformed values,
#'   `NA` if it is the result of an inverse transformation.
#' @exportClass preproc_params
setClass("preproc_params",
         slots = list(
           id_col = "character",
           target_col = "character",
           split_col = "character",
           scale_option = "character",
           scale_method = "character",
           mean_vals = "numeric",
           sd_vals = "numeric",
           min_vals = "numeric",
           max_vals = "numeric",
           fun_transform = "list_or_NULL",
           fun_inverse = "list_or_NULL",
           transformed = "logical"
         ))

#' @title Preprocessed Data
#'
#' @description An S4 class to store the preprocessed data and its associated parameters.
#'
#' @slot data Data frame containing the preprocessed data.
#' @slot params `preproc_params` object storing the parameters used in preprocessing.
#' @exportClass preproc_data
setClass("preproc_data",
         slots = list(
           data = "data.frame",
           params = "preproc_params"
         ))


#' @title List Representation of Preprocessed Data
#'
#' @description An S4 class to represent the preprocessed data as a list.
#'
#' @slot x_train Training data (X).
#' @slot x_test Test data (X).
#' @slot x_all All data (X).
#' @slot y_train Training data (Y).
#' @slot y_test Test data (Y).
#' @slot y_all All data (Y).
#' @slot x_train_scaled Scaled training data (X).
#' @slot x_test_scaled Scaled test data (X).
#' @slot x_all_scaled Scaled all data (X).
#' @exportClass preproc_data_list
setClass("preproc_data_list",
         #contains = "list",
         slots = list(
           x_train = "ANY",
           x_test = "ANY",
           x_all = "ANY",
           y_train = "ANY",
           y_test = "ANY",
           y_all = "ANY",
           x_train_scaled = "ANY",
           x_test_scaled = "ANY",
           x_all_scaled = "ANY"
         ))
