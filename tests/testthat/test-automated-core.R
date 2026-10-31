test_that("Box-Cox is explicit and reversible", {
  x <- c(1, 2, 5, 10)
  for (lambda in c(-1, -0.5, 0, 0.5))
    expect_equal(hv_boxcox_inverse(hv_boxcox(x, lambda), lambda), x, tolerance = 1e-10)
  expect_error(hv_boxcox(c(-1, 1), 0), "domain")
  expect_equal(hv_boxcox_lambdas(c(1, 1, 0)), c(1, 0))
})

test_that("classification and validation are conservative", {
  d <- data.frame(price = 100 + 1:12, area = 50 + 1:12,
                  ordered_quality = ordered(rep(c("low", "high"), 6)),
                  observation_id = paste0("x", 1:12))
  ctab <- hv_classify_variables(d, "price")
  expect_equal(ctab$type[ctab$name == "ordered_quality"], "ordinal")
  expect_equal(ctab$role[ctab$name == "observation_id"], "identifier")
  expect_true(hv_validate_data(d, "price", c("area"))$ok)
})

test_that("genetic search has real operators and exhaustive reference", {
  d <- data.frame(x = 1:12, z = 12:1)
  space <- hv_gene_space(d, c("x", "z"))
  expect_true(all(c("exclude", "linear") %in% space$x))
  score <- function(chromosome) sum(chromosome != "exclude") +
    if (identical(chromosome[["x"]], "linear")) 0 else 1
  exhaustive <- hv_exhaustive_search(space, score, limit = 100)
  expect_true(exhaustive$performed)
  result <- hv_genetic_optimize(space, score, population_size = 6, generations = 4,
    elitism = 1, patience = 3, seed = 42, exhaustive_limit = 100)
  expect_true(length(result$runs[[1]]$history$best_loss) >= 1)
  expect_true(is.finite(result$genetic_vs_exhaustive_gap))
})

test_that("cross-validation and log retransformation use original scale", {
  set.seed(4)
  d <- data.frame(price = exp(2 + 0.03 * (1:24) + rnorm(24, sd = 0.05)),
                  area = 1:24, rooms = rep(2:4, 8))
  folds <- hv_make_folds(nrow(d), k = 4, seed = 9)
  cv <- hv_cross_validate(d, "price", c("area", "rooms"), response = "log",
    transformations = list(area = "linear", rooms = "linear"), folds = folds,
    retransformation = "smearing")
  expect_true(all(c("rmse", "mae", "bias") %in% names(cv$metrics)))
  expect_true(all(cv$fold_results$rmse >= 0))
})

test_that("normative output preserves evidence states and extrapolation", {
  d <- data.frame(price = 100 + 2 * (1:20), area = 10:29)
  m <- hv_fit(price ~ area, d)
  result <- hv_normative_checks(m, d, "price",
    newdata = data.frame(area = 100), normative_source = NULL)
  expect_true(all(result$status %in% c("PENDENTE_DE_ANALISE_TECNICA",
    "NAO_VERIFICAVEL", "NAO_CONFORME", "CONFORME", "NAO_APLICAVEL")))
  expect_equal(hv_check_extrapolation(d, data.frame(area = 100), "area")$status,
    "EXTRAPOLATION")
})
