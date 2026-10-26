#include <RcppArmadillo.h>
// [[Rcpp::depends(RcppArmadillo)]]
// [[Rcpp::export]]
Rcpp::List hv_ols_cpp(const arma::mat& X, const arma::vec& y) {
  if (X.n_rows != y.n_elem || X.n_rows <= X.n_cols)
    Rcpp::stop("Expected n > p, matching design matrix and response");
  arma::vec beta;
  bool ok = arma::solve(beta, X, y);
  if (!ok || !beta.is_finite()) Rcpp::stop("Design matrix is rank-deficient or ill-conditioned");
  arma::vec residual = y - X * beta;
  double sigma2 = arma::dot(residual,residual) / (X.n_rows-X.n_cols);
  return Rcpp::List::create(Rcpp::_["coefficients"]=beta,
    Rcpp::_["residuals"]=residual, Rcpp::_["sigma2"]=sigma2,
    Rcpp::_["df"]=X.n_rows-X.n_cols);
}
