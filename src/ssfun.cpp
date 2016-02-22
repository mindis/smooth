#include <RcppArmadillo.h>
#include <iostream>
// [[Rcpp::depends(RcppArmadillo)]]

using namespace Rcpp;

List ssfitter(arma::mat matrixxt, arma::mat matrixF, arma::mat matrixw, arma::mat matrixv, arma::vec matyt,
            arma::vec matg, arma::uvec lags, arma::mat wex, arma::mat xtreg) {
/* # matrixxt should have a length of obs + maxlag.
 * # matrixw should have obs rows (can be all similar).
 * # matgt should be a vector
 * # lags is a vector of lags
 * # wex is the matrix with the exogenous variables
 * # xtreg is the matrix with the parameters for the exogenous (repeated)
 */

    int obs = matyt.n_rows;
    int obsall = matrixxt.n_rows;
    int lagslength = lags.n_rows;
    unsigned int maxlag = max(lags);

    lags = maxlag - lags;

    for(int i=1; i<lagslength; i=i+1){
        lags(i) = lags(i) + obsall * i;
    }

    arma::uvec lagrows(lagslength, arma::fill::zeros);

    arma::vec matyfit(obs, arma::fill::zeros);
    arma::vec materrors(obs, arma::fill::zeros);

    for (int i=maxlag; i<obsall; i=i+1) {

        lagrows = lags - maxlag + i;

        matyfit.row(i-maxlag) = matrixw.row(i-maxlag) * matrixxt(lagrows) + wex.row(i-maxlag) * arma::trans(xtreg.row(i-maxlag));
        materrors(i-maxlag) = matyt(i-maxlag) - matyfit(i-maxlag);
        matrixxt.row(i) = arma::trans(matrixF * matrixxt(lagrows) + matg / arma::trans(matrixv.row(i-maxlag)) * materrors(i-maxlag));
        matrixxt.elem(find_nonfinite(matrixxt)) = matrixxt.elem(find_nonfinite(matrixxt) - 1);
      }

    return List::create(Named("matxt") = matrixxt, Named("yfit") = matyfit, Named("errors") = materrors, Named("xtreg") = xtreg);
}

/* # Wrapper for ssfitter */
// [[Rcpp::export]]
RcppExport SEXP ssfitterwrap(SEXP matxt, SEXP matF, SEXP matw, SEXP matv, SEXP yt, SEXP vecg,
                             SEXP modellags, SEXP matwex, SEXP matxtreg) {
    NumericMatrix mxt(matxt);
    arma::mat matrixxt(mxt.begin(), mxt.nrow(), mxt.ncol());
    NumericMatrix mF(matF);
    arma::mat matrixF(mF.begin(), mF.nrow(), mF.ncol(), false);
    NumericMatrix vw(matw);
    arma::mat matrixw(vw.begin(), vw.nrow(), vw.ncol(), false);
    NumericMatrix vv(matv);
    arma::mat matrixv(vv.begin(), vv.nrow(), vv.ncol(), false);
    NumericMatrix vyt(yt);
    arma::vec matyt(vyt.begin(), vyt.nrow(), vyt.ncol(), false);
    NumericMatrix vg(vecg);
    arma::vec matg(vg.begin(), vg.nrow(), false);
    IntegerVector mlags(modellags);
    arma::uvec lags = as<arma::uvec>(mlags);
    NumericMatrix mwex(matwex);
    arma::mat wex(mwex.begin(), mwex.nrow(), mwex.ncol(), false);
    NumericMatrix mxtreg(matxtreg);
    arma::mat xtreg(mxtreg.begin(), mxtreg.nrow(), mxtreg.ncol());

    return wrap(ssfitter(matrixxt, matrixF, matrixw, matrixv, matyt, matg, lags, wex, xtreg));
}

List ssfitterbackcast(arma::mat matrixxt, arma::mat matrixF, arma::mat matrixw, arma::mat matrixv, arma::vec matyt,
            arma::vec matg, arma::uvec lags, arma::mat wex, arma::mat xtreg) {
/* # matrixxt should have a length of obs + maxlag.
 * # matrixw should have obs rows (can be all similar).
 * # matgt should be a vector
 * # lags is a vector of lags
 * # wex is the matrix with the exogenous variables
 * # xtreg is the matrix with the parameters for the exogenous (repeated)
 */

    unsigned int obs = matyt.n_rows;
    unsigned int obsall = matrixxt.n_rows;
    unsigned int lagslength = lags.n_rows;
    unsigned int maxlag = max(lags);
    unsigned int obsallnew = obsall + maxlag;

    matrixxt.resize(obsallnew,matrixxt.n_cols);

    arma::uvec backlags = lags;
    lags = maxlag - lags;

    for(int i=0; i<lagslength; i=i+1){
        backlags(i) = obsallnew * (i+1) - lags(i);
    }

    for(int i=1; i<lagslength; i=i+1){
        lags(i) = lags(i) + obsallnew * i;
    }

    arma::uvec lagrows(lagslength, arma::fill::zeros);

    arma::vec matyfit(obs, arma::fill::zeros);
    arma::vec materrors(obs, arma::fill::zeros);

/* # Cycle for backcasting */
    for(int j=0; j<4; j=j+1){

/* # Cycle till the end of data */
        for (int i=maxlag; i<obsall; i=i+1) {
            lagrows = lags - maxlag + i;

            matyfit.row(i-maxlag) = matrixw.row(i-maxlag) * matrixxt(lagrows) + wex.row(i-maxlag) * arma::trans(xtreg.row(i-maxlag));
            materrors(i-maxlag) = matyt(i-maxlag) - matyfit(i-maxlag);
            matrixxt.row(i) = arma::trans(matrixF * matrixxt(lagrows) + matg / arma::trans(matrixv.row(i-maxlag)) * materrors(i-maxlag));
            matrixxt.elem(find_nonfinite(matrixxt)) = matrixxt.elem(find_nonfinite(matrixxt) - 1);
        }
/* # Cycle for the final bit of xt */
        for(int i=obsall; i<obsallnew; i=i+1){
            lagrows = lags - maxlag + i;

            matrixxt.row(i) = arma::trans(matrixF * matrixxt(lagrows));
            matrixxt.elem(find_nonfinite(matrixxt)) = matrixxt.elem(find_nonfinite(matrixxt) - 1);
        }

/* # if controls the cycle and stops the final one from producing the backcast */
        if(j<3){
/* # Backcast till the first maxlag values of xt */
            for (int i=obsall-1; i>=maxlag; i=i-1) {
                lagrows = backlags + i - obsall;

                matyfit.row(i-maxlag) = matrixw.row(i-maxlag) * matrixxt(lagrows) + wex.row(i-maxlag) * arma::trans(xtreg.row(i-maxlag));
                materrors(i-maxlag) = matyt(i-maxlag) - matyfit(i-maxlag);
                matrixxt.row(i) = arma::trans(matrixF * matrixxt(lagrows) + matg / arma::trans(matrixv.row(i-maxlag)) * materrors(i-maxlag));
                matrixxt.elem(find_nonfinite(matrixxt)) = matrixxt.elem(find_nonfinite(matrixxt) + 1);
            }
/* # Backcast small bit of xt */
            for (int i=maxlag-1; i>=0; i=i-1) {
                lagrows = backlags + i - obsall;

                matrixxt.row(i) = arma::trans(matrixF * matrixxt(lagrows));
                matrixxt.elem(find_nonfinite(matrixxt)) = matrixxt.elem(find_nonfinite(matrixxt) + 1);
            }
        }
    }

    matrixxt.set_size(obsall,matrixxt.n_cols);

    return List::create(Named("matxt") = matrixxt, Named("yfit") = matyfit, Named("errors") = materrors, Named("xtreg") = xtreg);
}

/* # Wrapper for ssfitter with backcasting */
// [[Rcpp::export]]
RcppExport SEXP ssfitterbackcastwrap(SEXP matxt, SEXP matF, SEXP matw, SEXP matv, SEXP yt, SEXP vecg,
                             SEXP modellags, SEXP matwex, SEXP matxtreg) {
    NumericMatrix mxt(matxt);
    arma::mat matrixxt(mxt.begin(), mxt.nrow(), mxt.ncol());
    NumericMatrix mF(matF);
    arma::mat matrixF(mF.begin(), mF.nrow(), mF.ncol(), false);
    NumericMatrix vw(matw);
    arma::mat matrixw(vw.begin(), vw.nrow(), vw.ncol(), false);
    NumericMatrix vv(matv);
    arma::mat matrixv(vv.begin(), vv.nrow(), vv.ncol(), false);
    NumericMatrix vyt(yt);
    arma::vec matyt(vyt.begin(), vyt.nrow(), vyt.ncol(), false);
    NumericMatrix vg(vecg);
    arma::vec matg(vg.begin(), vg.nrow(), false);
    IntegerVector mlags(modellags);
    arma::uvec lags = as<arma::uvec>(mlags);
    NumericMatrix mwex(matwex);
    arma::mat wex(mwex.begin(), mwex.nrow(), mwex.ncol(), false);
    NumericMatrix mxtreg(matxtreg);
    arma::mat xtreg(mxtreg.begin(), mxtreg.nrow(), mxtreg.ncol());

    return wrap(ssfitterbackcast(matrixxt, matrixF, matrixw, matrixv, matyt, matg, lags, wex, xtreg));
}

/* # Function produces the point forecasts for the specified model */
arma::mat ssforecaster(arma::mat matrixxt, arma::mat matrixF, arma::mat matrixw,
                       unsigned int hor, arma::uvec lags, arma::mat wex, arma::mat xtreg) {
/* # Provide only the sufficient matrixxt (with the length = maxlag).
 * # nrows of matrixw, wex and xtreg should be >= hor
 */

    int lagslength = lags.n_rows;
    unsigned int maxlag = max(lags);
    unsigned int hh = hor + maxlag;

    arma::uvec lagrows(lagslength, arma::fill::zeros);
    arma::vec matyfor(hor, arma::fill::zeros);
    arma::mat matrixxtnew(hh, matrixxt.n_cols, arma::fill::zeros);

    lags = maxlag - lags;
    for(int i=1; i<lagslength; i=i+1){
        lags(i) = lags(i) + hh * i;
    }

    matrixxtnew.submat(0,0,maxlag-1,matrixxtnew.n_cols-1) = matrixxt.submat(0,0,maxlag-1,matrixxtnew.n_cols-1);

/* # Fill in the new xt matrix using F. Do the forecasts. */
    for (int i=maxlag; i<(hor+maxlag); i=i+1) {
        lagrows = lags - maxlag + i;
        matrixxtnew.row(i) = arma::trans(matrixF * matrixxtnew(lagrows));
        matyfor.row(i-maxlag) = matrixw.row(i-maxlag) * matrixxtnew(lagrows) + wex.row(i-maxlag) * arma::trans(xtreg.row(i-maxlag));
    }

    return matyfor;
}

/* # Wrapper for forecaster */
// [[Rcpp::export]]
RcppExport SEXP ssforecasterwrap(SEXP matxt, SEXP matF, SEXP matw, SEXP h,
                                 SEXP modellags, SEXP matwex, SEXP matxtreg){
    NumericMatrix mxt(matxt);
    arma::mat matrixxt(mxt.begin(), mxt.nrow(), mxt.ncol());
    NumericMatrix mF(matF);
    arma::mat matrixF(mF.begin(), mF.nrow(), mF.ncol(), false);
    NumericMatrix vw(matw);
    arma::mat matrixw(vw.begin(), vw.nrow(), vw.ncol(), false);
    unsigned int hor = as<int>(h);
    IntegerVector mlags(modellags);
    arma::uvec lags = as<arma::uvec>(mlags);
    NumericMatrix mwex(matwex);
    arma::mat wex(mwex.begin(), mwex.nrow(), mwex.ncol(), false);
    NumericMatrix mxtreg(matxtreg);
    arma::mat xtreg(mxtreg.begin(), mxtreg.nrow(), mxtreg.ncol());

    return wrap(ssforecaster(matrixxt, matrixF, matrixw, hor, lags, wex, xtreg));
}

arma::mat sserrorer(arma::mat matrixxt, arma::mat matrixF, arma::mat matrixw,
                    arma::vec matyt, unsigned int hor, arma::uvec lags, arma::mat wex, arma::mat xtreg){
    unsigned int obs = matyt.n_rows;
    unsigned int maxlag = max(lags);
    unsigned int hh;
    arma::mat materrors(obs, hor);

    materrors.fill(NA_REAL);

    for(int i=maxlag; i<obs+maxlag; i=i+1){
        hh = std::min(hor, obs+maxlag-i);
        materrors.submat(i-maxlag, 0, i-maxlag, hh-1) = arma::trans(matyt.rows(i-maxlag, i-maxlag+hh-1) -
            ssforecaster(matrixxt.rows(i-maxlag,i-1), matrixF, matrixw.rows(i-maxlag,i-maxlag+hh-1), hh, lags,
                         wex.rows(i-maxlag,i-maxlag+hh-1), xtreg.rows(i-maxlag,i-maxlag+hh-1)));
    }

    return materrors;
}

/* # Wrapper for errorer */
// [[Rcpp::export]]
RcppExport SEXP sserrorerwrap(SEXP matxt, SEXP matF, SEXP matw, SEXP yt, SEXP h,
                                    SEXP modellags, SEXP matwex, SEXP matxtreg) {
    NumericMatrix mxt(matxt);
    arma::mat matrixxt(mxt.begin(), mxt.nrow(), mxt.ncol(), false);
    NumericMatrix mF(matF);
    arma::mat matrixF(mF.begin(), mF.nrow(), mF.ncol(), false);
    NumericMatrix vw(matw);
    arma::mat matrixw(vw.begin(), vw.nrow(), vw.ncol(), false);
    NumericMatrix vyt(yt);
    arma::vec matyt(vyt.begin(), vyt.nrow(), false);
    unsigned int hor = as<int>(h);
    IntegerVector mlags(modellags);
    arma::uvec lags = as<arma::uvec>(mlags);
    NumericMatrix mwex(matwex);
    arma::mat wex(mwex.begin(), mwex.nrow(), mwex.ncol(), false);
    NumericMatrix mxtreg(matxtreg);
    arma::mat xtreg(mxtreg.begin(), mxtreg.nrow(), mxtreg.ncol(), false);

  return wrap(sserrorer(matrixxt, matrixF, matrixw, matyt, hor, lags, wex, xtreg));
}

/* # Cost function calculation */
double ssoptimizer(arma::mat matrixxt, arma::mat matrixF, arma::mat matrixw, arma::mat matrixv, arma::vec matyt, arma::vec matg,
                   unsigned int hor, arma::uvec lags, std::string CFtype, double normalize, bool backcasting, arma::mat wex, arma::mat xtreg) {
/* # Silent the output of try catch */
    std::ostream nullstream(0);
    arma::set_stream_err2(nullstream);

    double CFres = 0;
    int obs = matyt.n_rows;
    int matobs = obs - hor + 1;

    List fitting;

    if(backcasting==TRUE){
        fitting = ssfitterbackcast(matrixxt, matrixF, matrixw, matrixv, matyt, matg, lags, wex, xtreg);
    }
    else{
        fitting = ssfitter(matrixxt, matrixF, matrixw, matrixv, matyt, matg, lags, wex, xtreg);
    }

    NumericMatrix mxtfromfit = as<NumericMatrix>(fitting["matxt"]);
    matrixxt = as<arma::mat>(mxtfromfit);
    NumericMatrix errorsfromfit = as<NumericMatrix>(fitting["errors"]);
    NumericMatrix mxtregfromfit = as<NumericMatrix>(fitting["xtreg"]);
    xtreg = as<arma::mat>(mxtregfromfit);

    arma::mat materrors;
/* # The matrix is cut of to be square. If the backcast is done to the additional points, this can be fixed. */
    if(CFtype=="GV"){
        materrors = sserrorer(matrixxt, matrixF, matrixw, matyt, hor, lags, wex, xtreg);
        materrors.resize(matobs,hor);
        try{
            CFres = double(log(arma::prod(eig_sym(trans(materrors / normalize) * (materrors / normalize) / matobs))) + hor * log(pow(normalize,2)));
        }
        catch(const std::runtime_error){
            CFres = double(log(arma::det(arma::trans(materrors / normalize) * (materrors / normalize) / matobs)) + hor * log(pow(normalize,2)));
        }
    }
    else if(CFtype=="TLV"){
        materrors = sserrorer(matrixxt, matrixF, matrixw, matyt, hor, lags, wex, xtreg);
        for(int i=0; i<hor; i=i+1){
            CFres = CFres + arma::as_scalar(log(mean(pow(materrors.submat(0,i,obs-i-1,i),2))));
        }
    }
    else if(CFtype=="TV"){
        materrors = sserrorer(matrixxt, matrixF, matrixw, matyt, hor, lags, wex, xtreg);
        for(int i=0; i<hor; i=i+1){
            CFres = CFres + arma::as_scalar(mean(pow(materrors.submat(0,i,obs-i-1,i),2)));
        }
    }
    else if(CFtype=="hsteps"){
        materrors = sserrorer(matrixxt, matrixF, matrixw, matyt, hor, lags, wex, xtreg);
        CFres = arma::as_scalar(mean(pow(materrors.submat(0,hor-1,obs-hor,hor-1),2)));
    }
    else if(CFtype=="MSE"){
        arma::mat materrors(errorsfromfit.begin(), errorsfromfit.nrow(), errorsfromfit.ncol(), false);
        CFres = arma::as_scalar(mean(pow(materrors,2)));
    }
    else if(CFtype=="MAE"){
        arma::mat materrors(errorsfromfit.begin(), errorsfromfit.nrow(), errorsfromfit.ncol(), false);
        CFres = arma::as_scalar(mean(abs(materrors)));
    }
    else{
        arma::mat materrors(errorsfromfit.begin(), errorsfromfit.nrow(), errorsfromfit.ncol(), false);
        CFres = arma::as_scalar(mean(pow(abs(materrors),0.5)));
    }

    return CFres;
}


/* # Wrapper for optimiser */
// [[Rcpp::export]]
RcppExport SEXP ssoptimizerwrap(SEXP matxt, SEXP matF, SEXP matw, SEXP matv, SEXP yt, SEXP vecg, SEXP h,
                                SEXP modellags, SEXP CFt, SEXP normalizer, SEXP backcast, SEXP matwex, SEXP matxtreg) {

    NumericMatrix mxt(matxt);
    arma::mat matrixxt(mxt.begin(), mxt.nrow(), mxt.ncol());
    NumericMatrix mF(matF);
    arma::mat matrixF(mF.begin(), mF.nrow(), mF.ncol(), false);
    NumericMatrix vw(matw);
    arma::mat matrixw(vw.begin(), vw.nrow(), vw.ncol(), false);
    NumericMatrix vv(matv);
    arma::mat matrixv(vv.begin(), vv.nrow(), vv.ncol(), false);
    NumericMatrix vyt(yt);
    arma::vec matyt(vyt.begin(), vyt.nrow(), false);
    NumericMatrix vg(vecg);
    arma::vec matg(vg.begin(), vg.nrow(), false);
    unsigned int hor = as<int>(h);
    IntegerVector mlags(modellags);
    arma::uvec lags = as<arma::uvec>(mlags);
    std::string CFtype = as<std::string>(CFt);
    double normalize = as<double>(normalizer);
    bool backcasting = as<bool>(backcast);
    NumericMatrix mwex(matwex);
    arma::mat wex(mwex.begin(), mwex.nrow(), mwex.ncol(), false);
    NumericMatrix mxtreg(matxtreg);
    arma::mat xtreg(mxtreg.begin(), mxtreg.nrow(), mxtreg.ncol());

    return wrap(ssoptimizer(matrixxt,matrixF,matrixw,matrixv,matyt,matg,hor,lags,CFtype,normalize,backcasting,wex,xtreg));
}