## Demonstration of a simple regression problem with Keras/Tensorflow
## ThPe, based on code snippets from different documentations

library(keras3)
library(dplyr)
library(mlfeaturer)
## generate some  data
set.seed(123)

df <- tibble(
  id = 1:500,
  x = runif(500, 0, 50),
  y = 0.5 + (sin(x/5) + rnorm(500, 0, 0.05))/3,
  split = c(rep(TRUE, 400), rep(FALSE, 100))
)

# ToDo: correct handling of parameters after transformation

transformations <- list(
  x = \(x) sqrt(x),
  y = \(y) log(y)
)

inverse_transformations <- list(
  x = \(x) x^2,
  y = \(y) exp(y)
)


head(df)

plot(y ~ x, data=df, type="p")

## split data into training and test sets
td <- df |> create_preprocessed_data(id_col = "id", target_col = "y",
                               scale_method = "zscore",
                               fun_transform = transformations,
                               fun_inverse = inverse_transformations,
                               split_col = "split")


## transform + scale or both is broken
plot(get_x_all(td, "both"), get_y_all(td, "both"))

## build a Keras model
model <- keras_model_sequential(input_shape = c(1), input_dtype = "float32") |>
  layer_dense(units = 16, activation = "relu") |>  # Hidden layer
  layer_dense(units = 16, activation = "tanh") |>  # Hidden layer
  layer_dense(units = 1)                           # Output layer

## compile the model
model |> compile(
  ## general-purpose optimizer
  optimizer = optimizer_adam(learning_rate = 0.005),
  loss = "mse",       # mean squared error for the regression
  metrics = c("mae")  # additional evaluation metric
)

## train the model
history <- model |> fit(
  get_x_train(td), get_y_train(td),
  epochs = 100,          # adjust as needed
  ## 4 is very small but worked for this example well,
  ## usually bigger values are common, start e.g. with 32
  batch_size = 4,
  validation_split = 0.2
)

## Evaluate the model
loss <- evaluate(model, get_x_test(td), get_y_test(td))
cat("Loss of test data set =", loss$loss, "\n")
cat("MAE of test data set  =", loss$mae, "\n")

## classical way
predictions <- predict(model, get_x_test(td))
residuals  <-  get_y_test(td) - predictions

## use of mlfeatr package

predictions_all <- predict(td, model, "all")
predictions_test <- predict(td, model, "test")
predictions_train <- predict(td, model, "train")

residuals_all <- residuals(td, model)

plot(predictions_all, residuals_all)

plot(get_y_all(td), predictions_all)
abline(a=0, b=1, col="red", lwd=2)
cat("R2=", 1 - var(residuals)/var(get_y_test(td)), "\n")

## Compare data and predictions
plot(get_x_test(td), get_y_test(td), main = "Regression Results", xlab = "X", ylab = "Y")
points(get_x_test(td), predict(td, model, subset="test"), col = "red", pch=16)
points(get_x_train(td), predict(td, model, subset="train"), col = "blue", pch=16)

library(qualV)

## multiple metrics, cf. Jachner et al.
compareME(get_y_all(td), predict(td, model, "all"))

## Nash-Sutcliffe efficiency
EF(get_y_all(td), predict(td, model, "all"))

## coefficient of determination
rsquared(td, model, "train")
rsquared(td, model, "all")
rsquared(td, model, "test")

## compare retransformed predictions in original space
yy <- as.matrix(inverse_transform(data.frame(y = predictions_all), td@params))

plot(yy, get_y_all(td, type="none"))
abline(a=0, b=1, col="red", lwd=3)


ml_evaluate(td, model)



# ## Save fitted model
# save_model(model, "test-regression-model.keras")
#
# ## Load model
# loaded_model <- load_model("test-regression-model.keras")



