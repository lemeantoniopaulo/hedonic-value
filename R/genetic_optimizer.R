#' Build a discrete chromosome space for variable inclusion and transformations
#' @export
hv_gene_space <- function(data, predictors, categorical = character(),
                          lambdas = c(-1, -0.5, 0, 0.5, 1), fixed = character(),
                          excluded = character()) {
  stopifnot(is.data.frame(data), is.character(predictors))
  if (any(!predictors %in% names(data))) stop("Unknown predictor in gene space.")
  if (any(!c(fixed, excluded) %in% predictors)) stop("Unknown fixed/excluded predictor.")
  if (any(!categorical %in% predictors)) stop("Unknown categorical predictor.")
  lambdas <- hv_boxcox_lambdas(lambdas)
  if (any(categorical %in% predictors & !vapply(data[categorical],
      function(x) is.factor(x) || is.character(x) || is.logical(x), logical(1))))
    stop("categorical must identify character, factor or logical columns.")
  spaces <- lapply(predictors, function(nm) {
    if (nm %in% excluded) return("exclude")
    if (nm %in% fixed) return(if (nm %in% categorical) "include" else "linear")
    if (nm %in% categorical) c("exclude", "include") else {
      # lambda = 1 is x - 1, equivalent to linear x when an intercept exists.
      c("exclude", "linear", paste0("lambda:", format(lambdas[lambdas != 1], trim = TRUE)))
    }
  })
  names(spaces) <- predictors
  structure(spaces, class = c("hv_gene_space", "list"),
            hv_categorical = intersect(categorical, predictors),
            hv_fixed = intersect(fixed, predictors),
            hv_excluded = intersect(excluded, predictors))
}

#' Validate and serialize a chromosome
#' @export
hv_validate_chromosome <- function(chromosome, space) {
  if (!is.list(space) || is.null(names(space))) stop("Invalid gene space.")
  if (length(chromosome) != length(space) || is.null(names(chromosome)))
    stop("Chromosome must contain one named gene per predictor.")
  chromosome <- chromosome[names(space)]
  valid <- mapply(function(g, admissible) is.character(g) && length(g) == 1L && g %in% admissible,
                  chromosome, space, SIMPLIFY = TRUE)
  if (any(!valid)) stop("Chromosome contains an inadmissible gene.")
  chromosome
}

hv_chromosome_key <- function(chromosome, space) {
  chromosome <- hv_validate_chromosome(chromosome, space)
  paste(paste(names(chromosome), chromosome, sep = "="), collapse = "|")
}

#' Decode genes into a model transformation specification
#' @export
hv_decode_chromosome <- function(chromosome, space) {
  chromosome <- hv_validate_chromosome(chromosome, space)
  categorical <- attr(space, "hv_categorical") %||% character()
  transformations <- lapply(names(chromosome), function(nm) {
    gene <- chromosome[[nm]]
    if (gene == "exclude") return("exclude")
    if (gene %in% c("linear", "include")) return(if (nm %in% categorical) "linear" else "linear")
    as.numeric(sub("^lambda:", "", gene))
  })
  names(transformations) <- names(chromosome)
  transformations
}

`%||%` <- function(x, y) if (is.null(x)) y else x

hv_random_chromosome <- function(space) {
  out <- vapply(space, function(x) sample(x, 1L), character(1))
  names(out) <- names(space); out
}

hv_tournament <- function(population, fitness, size = 3L) {
  ids <- sample(seq_along(population), min(size, length(population)))
  ids[[which.min(fitness[ids])]]
}

hv_crossover <- function(a, b, probability = 0.8) {
  if (length(a) < 2L || runif(1) > probability) return(list(a, b))
  point <- sample(seq_len(length(a) - 1L), 1L)
  list(c(a[seq_len(point)], b[-seq_len(point)]),
       c(b[seq_len(point)], a[-seq_len(point)]))
}

hv_mutate <- function(chromosome, space, probability = 0.1) {
  out <- chromosome
  for (i in seq_along(out)) if (runif(1) < probability && length(space[[i]]) > 1L)
    out[[i]] <- sample(setdiff(space[[i]], out[[i]]), 1L)
  out
}

#' Exhaustively evaluate a discrete search space under a common fitness function
#' @export
hv_exhaustive_search <- function(space, fitness, limit = 10000L) {
  stopifnot(is.list(space), is.function(fitness), length(limit) == 1L, limit >= 1L)
  total <- prod(vapply(space, length, integer(1)))
  if (!is.finite(total) || total > limit)
    return(list(performed = FALSE, reason = "space_exceeds_limit", space_size = total,
                best = NULL, evaluations = 0L))
  grid <- expand.grid(space, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  values <- numeric(nrow(grid)); details <- vector("list", nrow(grid))
  for (i in seq_len(nrow(grid))) {
    chromosome <- as.character(grid[i, ]); names(chromosome) <- names(space)
    result <- fitness(chromosome); values[i] <- if (is.list(result)) result$loss else result
    details[[i]] <- result
  }
  best <- which.min(values)
  best_chromosome <- as.character(grid[best, ]); names(best_chromosome) <- names(space)
  list(performed = TRUE, reason = "completed", space_size = total,
       evaluations = nrow(grid), best = list(chromosome = best_chromosome,
         loss = values[best], result = details[[best]]), losses = values)
}

#' Optimize a discrete chromosome with selection, crossover, mutation and elitism
#' @export
hv_genetic_optimize <- function(space, fitness, population_size = 30L, generations = 50L,
                                crossover_probability = 0.8, mutation_probability = 0.1,
                                elitism = 2L, patience = 10L, runs = 1L, seed = NULL,
                                max_evaluations = Inf, exhaustive_limit = 10000L) {
  stopifnot(is.list(space), is.function(fitness))
  args <- c(population_size, generations, elitism, patience, runs)
  if (any(!is.finite(args)) || any(args < 1L) || elitism >= population_size)
    stop("Invalid genetic algorithm parameters.")
  if (!is.null(seed)) set.seed(seed)
  cache <- new.env(parent = emptyenv()); evaluations <- 0L
  evaluate <- function(chromosome) {
    key <- hv_chromosome_key(chromosome, space)
    if (exists(key, cache, inherits = FALSE)) return(get(key, cache, inherits = FALSE))
    if (evaluations >= max_evaluations) stop("Maximum fitness evaluations reached.")
    result <- fitness(chromosome)
    loss <- if (is.list(result)) result$loss else result
    if (length(loss) != 1L || !is.finite(loss)) stop("Fitness must return a finite scalar loss.")
    value <- list(loss = as.numeric(loss), result = result, chromosome = chromosome)
    assign(key, value, cache); evaluations <<- evaluations + 1L; value
  }
  run_results <- vector("list", runs)
  for (run in seq_len(runs)) {
    population <- replicate(population_size, hv_random_chromosome(space), simplify = FALSE)
    best <- NULL; no_improvement <- 0L; history <- list(); reason <- "max_generations"
    for (generation in seq_len(generations)) {
      assessed <- lapply(population, evaluate)
      losses <- vapply(assessed, `[[`, numeric(1), "loss")
      order_ids <- order(losses)
      if (is.null(best) || losses[order_ids[1L]] < best$loss) {
        best <- assessed[[order_ids[1L]]]; no_improvement <- 0L
      } else no_improvement <- no_improvement + 1L
      keys <- vapply(population, hv_chromosome_key, character(1), space = space)
      history[[generation]] <- data.frame(generation = generation,
        best_loss = min(losses), mean_loss = mean(losses),
        diversity = length(unique(keys)), distinct_evaluated = length(ls(cache)),
        complexity = mean(vapply(assessed, function(x)
          sum(!x$chromosome %in% c("exclude")), integer(1))))
      if (no_improvement >= patience) { reason <- "no_improvement"; break }
      parents <- vector("list", population_size - elitism)
      for (i in seq(1L, length(parents), by = 2L)) {
        pa <- population[[hv_tournament(population, losses)]]
        pb <- population[[hv_tournament(population, losses)]]
        children <- hv_crossover(pa, pb, crossover_probability)
        parents[[i]] <- hv_mutate(children[[1L]], space, mutation_probability)
        if (i + 1L <= length(parents)) parents[[i + 1L]] <-
          hv_mutate(children[[2L]], space, mutation_probability)
      }
      population <- c(population[order_ids[seq_len(elitism)]], parents)
    }
    run_results[[run]] <- list(best = best, history = do.call(rbind, history),
                               generations = length(history), reason = reason)
  }
  best_run <- which.min(vapply(run_results, function(x) x$best$loss, numeric(1)))
  exhaustive <- hv_exhaustive_search(space, fitness, exhaustive_limit)
  list(best = run_results[[best_run]]$best, runs = run_results, seed = seed,
       evaluations = evaluations, cache_size = length(ls(cache)),
       exhaustive_reference = exhaustive,
       genetic_vs_exhaustive_gap = if (isTRUE(exhaustive$performed))
         run_results[[best_run]]$best$loss - exhaustive$best$loss else NA_real_)
}
