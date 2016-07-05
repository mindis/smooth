// This file was generated by Rcpp::compileAttributes
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace Rcpp;

// initparams
RcppExport SEXP initparams(SEXP Ttype, SEXP Stype, SEXP datafreq, SEXP obsR, SEXP obsallR, SEXP yt, SEXP damped, SEXP phi, SEXP smoothingparameters, SEXP initialstates, SEXP seasonalcoefs);
RcppExport SEXP smooth_initparams(SEXP TtypeSEXP, SEXP StypeSEXP, SEXP datafreqSEXP, SEXP obsRSEXP, SEXP obsallRSEXP, SEXP ytSEXP, SEXP dampedSEXP, SEXP phiSEXP, SEXP smoothingparametersSEXP, SEXP initialstatesSEXP, SEXP seasonalcoefsSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< SEXP >::type Ttype(TtypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Stype(StypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type datafreq(datafreqSEXP);
    Rcpp::traits::input_parameter< SEXP >::type obsR(obsRSEXP);
    Rcpp::traits::input_parameter< SEXP >::type obsallR(obsallRSEXP);
    Rcpp::traits::input_parameter< SEXP >::type yt(ytSEXP);
    Rcpp::traits::input_parameter< SEXP >::type damped(dampedSEXP);
    Rcpp::traits::input_parameter< SEXP >::type phi(phiSEXP);
    Rcpp::traits::input_parameter< SEXP >::type smoothingparameters(smoothingparametersSEXP);
    Rcpp::traits::input_parameter< SEXP >::type initialstates(initialstatesSEXP);
    Rcpp::traits::input_parameter< SEXP >::type seasonalcoefs(seasonalcoefsSEXP);
    __result = Rcpp::wrap(initparams(Ttype, Stype, datafreq, obsR, obsallR, yt, damped, phi, smoothingparameters, initialstates, seasonalcoefs));
    return __result;
END_RCPP
}
// etsmatrices
RcppExport SEXP etsmatrices(SEXP matvt, SEXP vecg, SEXP phi, SEXP Cvalues, SEXP ncomponentsR, SEXP modellags, SEXP Ttype, SEXP Stype, SEXP nexovars, SEXP matat, SEXP estimpersistence, SEXP estimphi, SEXP estiminit, SEXP estiminitseason, SEXP estimxreg, SEXP matFX, SEXP vecgX, SEXP gowild, SEXP estimFX, SEXP estimgX, SEXP estiminitX);
RcppExport SEXP smooth_etsmatrices(SEXP matvtSEXP, SEXP vecgSEXP, SEXP phiSEXP, SEXP CvaluesSEXP, SEXP ncomponentsRSEXP, SEXP modellagsSEXP, SEXP TtypeSEXP, SEXP StypeSEXP, SEXP nexovarsSEXP, SEXP matatSEXP, SEXP estimpersistenceSEXP, SEXP estimphiSEXP, SEXP estiminitSEXP, SEXP estiminitseasonSEXP, SEXP estimxregSEXP, SEXP matFXSEXP, SEXP vecgXSEXP, SEXP gowildSEXP, SEXP estimFXSEXP, SEXP estimgXSEXP, SEXP estiminitXSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< SEXP >::type matvt(matvtSEXP);
    Rcpp::traits::input_parameter< SEXP >::type vecg(vecgSEXP);
    Rcpp::traits::input_parameter< SEXP >::type phi(phiSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Cvalues(CvaluesSEXP);
    Rcpp::traits::input_parameter< SEXP >::type ncomponentsR(ncomponentsRSEXP);
    Rcpp::traits::input_parameter< SEXP >::type modellags(modellagsSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Ttype(TtypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Stype(StypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type nexovars(nexovarsSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matat(matatSEXP);
    Rcpp::traits::input_parameter< SEXP >::type estimpersistence(estimpersistenceSEXP);
    Rcpp::traits::input_parameter< SEXP >::type estimphi(estimphiSEXP);
    Rcpp::traits::input_parameter< SEXP >::type estiminit(estiminitSEXP);
    Rcpp::traits::input_parameter< SEXP >::type estiminitseason(estiminitseasonSEXP);
    Rcpp::traits::input_parameter< SEXP >::type estimxreg(estimxregSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matFX(matFXSEXP);
    Rcpp::traits::input_parameter< SEXP >::type vecgX(vecgXSEXP);
    Rcpp::traits::input_parameter< SEXP >::type gowild(gowildSEXP);
    Rcpp::traits::input_parameter< SEXP >::type estimFX(estimFXSEXP);
    Rcpp::traits::input_parameter< SEXP >::type estimgX(estimgXSEXP);
    Rcpp::traits::input_parameter< SEXP >::type estiminitX(estiminitXSEXP);
    __result = Rcpp::wrap(etsmatrices(matvt, vecg, phi, Cvalues, ncomponentsR, modellags, Ttype, Stype, nexovars, matat, estimpersistence, estimphi, estiminit, estiminitseason, estimxreg, matFX, vecgX, gowild, estimFX, estimgX, estiminitX));
    return __result;
END_RCPP
}
// fitterwrap
RcppExport SEXP fitterwrap(SEXP matvt, SEXP matF, SEXP matw, SEXP yt, SEXP vecg, SEXP modellags, SEXP Etype, SEXP Ttype, SEXP Stype, SEXP fittertype, SEXP matxt, SEXP matat, SEXP matFX, SEXP vecgX, SEXP ot);
RcppExport SEXP smooth_fitterwrap(SEXP matvtSEXP, SEXP matFSEXP, SEXP matwSEXP, SEXP ytSEXP, SEXP vecgSEXP, SEXP modellagsSEXP, SEXP EtypeSEXP, SEXP TtypeSEXP, SEXP StypeSEXP, SEXP fittertypeSEXP, SEXP matxtSEXP, SEXP matatSEXP, SEXP matFXSEXP, SEXP vecgXSEXP, SEXP otSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< SEXP >::type matvt(matvtSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matF(matFSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matw(matwSEXP);
    Rcpp::traits::input_parameter< SEXP >::type yt(ytSEXP);
    Rcpp::traits::input_parameter< SEXP >::type vecg(vecgSEXP);
    Rcpp::traits::input_parameter< SEXP >::type modellags(modellagsSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Etype(EtypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Ttype(TtypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Stype(StypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type fittertype(fittertypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matxt(matxtSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matat(matatSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matFX(matFXSEXP);
    Rcpp::traits::input_parameter< SEXP >::type vecgX(vecgXSEXP);
    Rcpp::traits::input_parameter< SEXP >::type ot(otSEXP);
    __result = Rcpp::wrap(fitterwrap(matvt, matF, matw, yt, vecg, modellags, Etype, Ttype, Stype, fittertype, matxt, matat, matFX, vecgX, ot));
    return __result;
END_RCPP
}
// forecasterwrap
RcppExport SEXP forecasterwrap(SEXP matvt, SEXP matF, SEXP matw, SEXP h, SEXP Ttype, SEXP Stype, SEXP modellags, SEXP matxt, SEXP matat, SEXP matFX);
RcppExport SEXP smooth_forecasterwrap(SEXP matvtSEXP, SEXP matFSEXP, SEXP matwSEXP, SEXP hSEXP, SEXP TtypeSEXP, SEXP StypeSEXP, SEXP modellagsSEXP, SEXP matxtSEXP, SEXP matatSEXP, SEXP matFXSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< SEXP >::type matvt(matvtSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matF(matFSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matw(matwSEXP);
    Rcpp::traits::input_parameter< SEXP >::type h(hSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Ttype(TtypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Stype(StypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type modellags(modellagsSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matxt(matxtSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matat(matatSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matFX(matFXSEXP);
    __result = Rcpp::wrap(forecasterwrap(matvt, matF, matw, h, Ttype, Stype, modellags, matxt, matat, matFX));
    return __result;
END_RCPP
}
// errorerwrap
RcppExport SEXP errorerwrap(SEXP matvt, SEXP matF, SEXP matw, SEXP yt, SEXP h, SEXP Etype, SEXP Ttype, SEXP Stype, SEXP modellags, SEXP matxt, SEXP matat, SEXP matFX, SEXP ot);
RcppExport SEXP smooth_errorerwrap(SEXP matvtSEXP, SEXP matFSEXP, SEXP matwSEXP, SEXP ytSEXP, SEXP hSEXP, SEXP EtypeSEXP, SEXP TtypeSEXP, SEXP StypeSEXP, SEXP modellagsSEXP, SEXP matxtSEXP, SEXP matatSEXP, SEXP matFXSEXP, SEXP otSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< SEXP >::type matvt(matvtSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matF(matFSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matw(matwSEXP);
    Rcpp::traits::input_parameter< SEXP >::type yt(ytSEXP);
    Rcpp::traits::input_parameter< SEXP >::type h(hSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Etype(EtypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Ttype(TtypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Stype(StypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type modellags(modellagsSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matxt(matxtSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matat(matatSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matFX(matFXSEXP);
    Rcpp::traits::input_parameter< SEXP >::type ot(otSEXP);
    __result = Rcpp::wrap(errorerwrap(matvt, matF, matw, yt, h, Etype, Ttype, Stype, modellags, matxt, matat, matFX, ot));
    return __result;
END_RCPP
}
// optimizerwrap
RcppExport SEXP optimizerwrap(SEXP matvt, SEXP matF, SEXP matw, SEXP yt, SEXP vecg, SEXP h, SEXP modellags, SEXP Etype, SEXP Ttype, SEXP Stype, SEXP multisteps, SEXP CFt, SEXP normalizer, SEXP fittertype, SEXP matxt, SEXP matat, SEXP matFX, SEXP vecgX, SEXP ot);
RcppExport SEXP smooth_optimizerwrap(SEXP matvtSEXP, SEXP matFSEXP, SEXP matwSEXP, SEXP ytSEXP, SEXP vecgSEXP, SEXP hSEXP, SEXP modellagsSEXP, SEXP EtypeSEXP, SEXP TtypeSEXP, SEXP StypeSEXP, SEXP multistepsSEXP, SEXP CFtSEXP, SEXP normalizerSEXP, SEXP fittertypeSEXP, SEXP matxtSEXP, SEXP matatSEXP, SEXP matFXSEXP, SEXP vecgXSEXP, SEXP otSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< SEXP >::type matvt(matvtSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matF(matFSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matw(matwSEXP);
    Rcpp::traits::input_parameter< SEXP >::type yt(ytSEXP);
    Rcpp::traits::input_parameter< SEXP >::type vecg(vecgSEXP);
    Rcpp::traits::input_parameter< SEXP >::type h(hSEXP);
    Rcpp::traits::input_parameter< SEXP >::type modellags(modellagsSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Etype(EtypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Ttype(TtypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Stype(StypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type multisteps(multistepsSEXP);
    Rcpp::traits::input_parameter< SEXP >::type CFt(CFtSEXP);
    Rcpp::traits::input_parameter< SEXP >::type normalizer(normalizerSEXP);
    Rcpp::traits::input_parameter< SEXP >::type fittertype(fittertypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matxt(matxtSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matat(matatSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matFX(matFXSEXP);
    Rcpp::traits::input_parameter< SEXP >::type vecgX(vecgXSEXP);
    Rcpp::traits::input_parameter< SEXP >::type ot(otSEXP);
    __result = Rcpp::wrap(optimizerwrap(matvt, matF, matw, yt, vecg, h, modellags, Etype, Ttype, Stype, multisteps, CFt, normalizer, fittertype, matxt, matat, matFX, vecgX, ot));
    return __result;
END_RCPP
}
// costfunc
RcppExport SEXP costfunc(SEXP matvt, SEXP matF, SEXP matw, SEXP yt, SEXP vecg, SEXP h, SEXP modellags, SEXP Etype, SEXP Ttype, SEXP Stype, SEXP multisteps, SEXP CFt, SEXP normalizer, SEXP fittertype, SEXP matxt, SEXP matat, SEXP matFX, SEXP vecgX, SEXP ot, SEXP bounds);
RcppExport SEXP smooth_costfunc(SEXP matvtSEXP, SEXP matFSEXP, SEXP matwSEXP, SEXP ytSEXP, SEXP vecgSEXP, SEXP hSEXP, SEXP modellagsSEXP, SEXP EtypeSEXP, SEXP TtypeSEXP, SEXP StypeSEXP, SEXP multistepsSEXP, SEXP CFtSEXP, SEXP normalizerSEXP, SEXP fittertypeSEXP, SEXP matxtSEXP, SEXP matatSEXP, SEXP matFXSEXP, SEXP vecgXSEXP, SEXP otSEXP, SEXP boundsSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< SEXP >::type matvt(matvtSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matF(matFSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matw(matwSEXP);
    Rcpp::traits::input_parameter< SEXP >::type yt(ytSEXP);
    Rcpp::traits::input_parameter< SEXP >::type vecg(vecgSEXP);
    Rcpp::traits::input_parameter< SEXP >::type h(hSEXP);
    Rcpp::traits::input_parameter< SEXP >::type modellags(modellagsSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Etype(EtypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Ttype(TtypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Stype(StypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type multisteps(multistepsSEXP);
    Rcpp::traits::input_parameter< SEXP >::type CFt(CFtSEXP);
    Rcpp::traits::input_parameter< SEXP >::type normalizer(normalizerSEXP);
    Rcpp::traits::input_parameter< SEXP >::type fittertype(fittertypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matxt(matxtSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matat(matatSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matFX(matFXSEXP);
    Rcpp::traits::input_parameter< SEXP >::type vecgX(vecgXSEXP);
    Rcpp::traits::input_parameter< SEXP >::type ot(otSEXP);
    Rcpp::traits::input_parameter< SEXP >::type bounds(boundsSEXP);
    __result = Rcpp::wrap(costfunc(matvt, matF, matw, yt, vecg, h, modellags, Etype, Ttype, Stype, multisteps, CFt, normalizer, fittertype, matxt, matat, matFX, vecgX, ot, bounds));
    return __result;
END_RCPP
}
// simulateETSwrap
RcppExport SEXP simulateETSwrap(SEXP arrvt, SEXP materrors, SEXP matot, SEXP matF, SEXP matw, SEXP matg, SEXP Etype, SEXP Ttype, SEXP Stype, SEXP modellags);
RcppExport SEXP smooth_simulateETSwrap(SEXP arrvtSEXP, SEXP materrorsSEXP, SEXP matotSEXP, SEXP matFSEXP, SEXP matwSEXP, SEXP matgSEXP, SEXP EtypeSEXP, SEXP TtypeSEXP, SEXP StypeSEXP, SEXP modellagsSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< SEXP >::type arrvt(arrvtSEXP);
    Rcpp::traits::input_parameter< SEXP >::type materrors(materrorsSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matot(matotSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matF(matFSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matw(matwSEXP);
    Rcpp::traits::input_parameter< SEXP >::type matg(matgSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Etype(EtypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Ttype(TtypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type Stype(StypeSEXP);
    Rcpp::traits::input_parameter< SEXP >::type modellags(modellagsSEXP);
    __result = Rcpp::wrap(simulateETSwrap(arrvt, materrors, matot, matF, matw, matg, Etype, Ttype, Stype, modellags));
    return __result;
END_RCPP
}
