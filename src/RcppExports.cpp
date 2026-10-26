// Generated interface equivalent to Rcpp::compileAttributes() output.
// Regenerate with Rcpp::compileAttributes() when changing exported C++ signatures.
#include <RcppArmadillo.h>
#include <Rcpp.h>
using namespace Rcpp;

// hv_ols_cpp
Rcpp::List hv_ols_cpp(const arma::mat& X, const arma::vec& y);
RcppExport SEXP _hedonicValue_hv_ols_cpp(SEXP XSEXP, SEXP ySEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const arma::mat& >::type X(XSEXP);
    Rcpp::traits::input_parameter< const arma::vec& >::type y(ySEXP);
    rcpp_result_gen = Rcpp::wrap(hv_ols_cpp(X, y));
    return rcpp_result_gen;
END_RCPP
}
static const R_CallMethodDef CallEntries[] = {
    {"_hedonicValue_hv_ols_cpp", (DL_FUNC) &_hedonicValue_hv_ols_cpp, 2},
    {NULL, NULL, 0}
};
RcppExport void R_init_hedonicValue(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
