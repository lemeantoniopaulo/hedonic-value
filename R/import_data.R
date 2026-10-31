#' Import and classify data for a hedonic analysis
#'
#' Excel import is deliberately optional: the package remains installable in a
#' base R environment, while users get a precise error when readxl is absent.
#' @param path CSV, XLS or XLSX path.
#' @param sheet Sheet name or number for Excel files.
#' @param na Values interpreted as missing.
#' @export
hv_import_data <- function(path, sheet = 1, na = c("", "NA", "N/A", "NULL")) {
  if (!is.character(path) || length(path) != 1L || !file.exists(path))
    stop("'path' must identify an existing CSV, XLS or XLSX file.")
  ext <- tolower(tools::file_ext(path))
  data <- switch(ext,
    csv = utils::read.csv(path, na.strings = na, stringsAsFactors = FALSE,
                          check.names = FALSE),
    xls = {
      if (!requireNamespace("readxl", quietly = TRUE))
        stop("Install 'readxl' to import Excel workbooks.")
      as.data.frame(readxl::read_excel(path, sheet = sheet, na = na,
                                       .name_repair = "minimal"),
                    stringsAsFactors = FALSE, check.names = FALSE)
    },
    xlsx = {
      if (!requireNamespace("readxl", quietly = TRUE))
        stop("Install 'readxl' to import Excel workbooks.")
      as.data.frame(readxl::read_excel(path, sheet = sheet, na = na,
                                       .name_repair = "minimal"),
                    stringsAsFactors = FALSE, check.names = FALSE)
    },
    stop("Unsupported file extension. Use CSV, XLS or XLSX.")
  )
  if (!nrow(data) || !ncol(data)) stop("The imported table is empty.")
  if (anyDuplicated(names(data))) stop("Column names must be unique.")
  structure(data, class = c("hv_data", class(data)),
            hv_import = list(path = normalizePath(path, mustWork = TRUE),
                             extension = ext, sheet = sheet,
                             imported_at = Sys.time()))
}

#' Classify columns and flag likely identifiers or leakage variables
#' @export
hv_classify_variables <- function(data, y = NULL, overrides = list(),
                                  identifier_patterns = c("id", "identifier",
                                    "cadastral", "inscricao", "registro",
                                    "codigo", "code")) {
  stopifnot(is.data.frame(data))
  if (!is.null(y) && (!is.character(y) || length(y) != 1L || !y %in% names(data)))
    stop("'y' must be one column name in data.")
  result <- lapply(names(data), function(nm) {
    x <- data[[nm]]
    missing_n <- sum(is.na(x))
    unique_n <- length(unique(x[!is.na(x)]))
    inferred <- if (is.ordered(x)) "ordinal"
      else if (is.factor(x) || is.character(x) || is.logical(x)) "categorical"
      else if (inherits(x, c("Date", "POSIXct", "POSIXlt"))) "date"
      else if (is.numeric(x) || is.integer(x)) "numeric" else "other"
    override <- overrides[[nm]]
    type <- if (is.null(override)) inferred else as.character(override)[1L]
    lower <- tolower(nm)
    identifier <- any(grepl(paste(identifier_patterns, collapse = "|"), lower)) ||
      (unique_n > 0L && unique_n == sum(!is.na(x)) && unique_n >= 10L)
    role <- if (!is.null(y) && identical(nm, y)) "response" else
      if (identifier) "identifier" else "candidate"
    data.frame(name = nm, type = type, role = role, unique_n = unique_n,
               missing_n = missing_n, missing_rate = missing_n / nrow(data),
               eligible = role == "candidate" && !identical(type, "other"),
               stringsAsFactors = FALSE)
  })
  do.call(rbind, result)
}

#' Validate a data table before modeling
#' @export
hv_validate_data <- function(data, y, predictors = NULL,
                             missing = c("fail", "complete_cases"),
                             allow_duplicates = FALSE) {
  stopifnot(is.data.frame(data), is.character(y), length(y) == 1L)
  missing <- match.arg(missing)
  if (!y %in% names(data)) stop("Response column is not present.")
  if (!is.numeric(data[[y]]) || any(!is.finite(data[[y]][!is.na(data[[y]])])))
    stop("The response must be numeric and finite where observed.")
  if (is.null(predictors)) predictors <- setdiff(names(data), y)
  if (!length(predictors) || any(!predictors %in% names(data)))
    stop("Predictors must be non-empty column names in data.")
  complete <- stats::complete.cases(data[, c(y, predictors), drop = FALSE])
  duplicates <- duplicated(data[, c(y, predictors), drop = FALSE])
  issues <- character()
  if (missing == "fail" && any(!complete))
    issues <- c(issues, "missing_values_in_modeled_columns")
  if (!allow_duplicates && any(duplicates))
    issues <- c(issues, "duplicated_rows_in_modeled_columns")
  constant <- predictors[vapply(data[predictors], function(x)
    length(unique(x[!is.na(x)])) <= 1L, logical(1))]
  if (length(constant)) issues <- c(issues, "constant_predictor")
  list(ok = !length(issues), issues = unique(issues), n = nrow(data),
       complete_n = sum(complete), duplicate_rows = which(duplicates),
       constant_predictors = constant, y = y, predictors = predictors,
       missing_policy = missing,
       classification = hv_classify_variables(data, y = y))
}

#' Explicitly prepare a training table without silently imputing values
#' @export
hv_complete_cases <- function(data, columns, context = "modeling") {
  stopifnot(is.data.frame(data), is.character(columns))
  if (any(!columns %in% names(data))) stop("Unknown columns in complete-case selection.")
  keep <- stats::complete.cases(data[, columns, drop = FALSE])
  if (!any(keep)) stop("No complete observations remain for ", context, ".")
  list(data = data[keep, , drop = FALSE], rows = which(keep), dropped = which(!keep))
}
