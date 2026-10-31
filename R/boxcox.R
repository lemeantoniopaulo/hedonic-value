#' Apply a Box-Cox transformation with explicit domain handling
#' @export
hv_boxcox <- function(x, lambda, shift = 0) {
  if (!is.numeric(x) || length(lambda) != 1L || !is.finite(lambda) ||
      length(shift) != 1L || !is.finite(shift)) stop("Invalid Box-Cox arguments.")
  z <- x + shift
  bad <- !is.na(z) & (!is.finite(z) | z <= 0)
  if (any(bad)) stop("Box-Cox domain requires x + shift > 0; no silent shift was applied.")
  out <- x
  if (lambda == 0) out <- log(z) else out <- (z ^ lambda - 1) / lambda
  out[is.na(x)] <- NA_real_
  out
}

#' Invert a Box-Cox transformation
#' @export
hv_boxcox_inverse <- function(z, lambda, shift = 0) {
  if (!is.numeric(z) || length(lambda) != 1L || !is.finite(lambda) ||
      length(shift) != 1L || !is.finite(shift)) stop("Invalid Box-Cox arguments.")
  out <- if (lambda == 0) exp(z) else (lambda * z + 1) ^ (1 / lambda)
  if (any(!is.finite(out), na.rm = TRUE)) stop("Inverse Box-Cox produced non-finite values.")
  out - shift
}

#' Return distinct admissible transformations
#' @export
hv_boxcox_lambdas <- function(lambdas = c(-1, -0.5, 0, 0.5, 1)) {
  lambdas <- as.numeric(lambdas)
  if (!length(lambdas) || any(!is.finite(lambdas))) stop("lambdas must be finite and non-empty.")
  unique(lambdas)
}

#' Transform selected columns and return an auditable specification
#' @export
hv_transform_variables <- function(data, transformations, shifts = list()) {
  stopifnot(is.data.frame(data), is.list(transformations))
  out <- data
  records <- list()
  for (nm in names(transformations)) {
    if (!nm %in% names(data)) stop("Unknown transformation variable: ", nm)
    choice <- transformations[[nm]]
    if (identical(choice, "exclude") || is.null(choice)) next
    if (is.character(choice) && identical(choice, "linear")) next
    lambda <- as.numeric(choice)[1L]
    shift <- if (is.null(shifts[[nm]])) 0 else as.numeric(shifts[[nm]])[1L]
    if (!is.finite(lambda) || !is.finite(shift)) stop("Invalid transformation for ", nm)
    out[[nm]] <- hv_boxcox(as.numeric(data[[nm]]), lambda, shift)
    records[[nm]] <- list(variable = nm, lambda = lambda, shift = shift,
                          domain = "x + shift > 0")
  }
  attr(out, "hv_transformations") <- records
  out
}
