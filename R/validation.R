#' Compare fitted models on held-out data
#' @export
hv_benchmark <- function(models, test_data, truth, id=NULL) {
  stopifnot(is.list(models),is.data.frame(test_data),
            is.character(truth),length(truth)==1L,truth %in% names(test_data))
  if (!is.numeric(test_data[[truth]]) || anyNA(test_data[[truth]]))
    stop("truth must be complete numeric data.")
  if (is.null(names(models)) || anyDuplicated(names(models)) ||
      any(!nzchar(names(models)))) stop("Provide unique model names.")
  if (!is.null(id) && (!id %in% names(test_data) || anyDuplicated(test_data[[id]])))
    stop("Test observation IDs must exist and be unique.")
  dplyr::bind_rows(lapply(names(models),function(nm) {
    p <- hv_predict_model(models[[nm]],test_data,interval="none")$.pred
    if (length(p)!=nrow(test_data) || any(!is.finite(p))) stop("Invalid predictions.")
    e <- p-test_data[[truth]]
    tibble::tibble(model=nm,n=length(e),rmse=sqrt(mean(e^2)),
                   mae=mean(abs(e)),bias=mean(e),partition="user_supplied_test")
  }))
}
#' Explicit temporal holdout
#' @export
hv_temporal_split <- function(data,date,cutoff) {
  stopifnot(is.data.frame(data),length(date)==1L,date %in% names(data))
  dt <- as.Date(data[[date]]); cut <- as.Date(cutoff)
  if (anyNA(dt) || is.na(cut)) stop("Dates must be valid and complete.")
  tr <- which(dt<=cut); te <- which(dt>cut)
  if (!length(tr) || !length(te)) stop("Both train and test partitions are required.")
  list(train=tibble::as_tibble(data[tr,,drop=FALSE]),
       test=tibble::as_tibble(data[te,,drop=FALSE]),
       cutoff=cut,train_rows=tr,test_rows=te)
}
