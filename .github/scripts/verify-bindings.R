files <- c("R/RcppExports.R", "src/RcppExports.cpp")
stopifnot(all(file.exists(files)))
before <- tools::md5sum(files)
Rcpp::compileAttributes()
stopifnot(all(file.exists(files)))
# Canonical LF bytes make regeneration comparable on Windows and Linux.
for (file in files) {
  text <- paste0(paste(readLines(file, warn = FALSE), collapse = "\n"), "\n")
  writeBin(charToRaw(text), file)
}
after <- tools::md5sum(files)
print(after)
if (!identical(before, after)) {
  stop("Rcpp bindings differ from committed files; regenerate and commit them")
}
