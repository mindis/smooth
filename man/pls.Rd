% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/error-measures.R
\name{pls}
\alias{pls}
\title{Prediction Likelihood Score}
\usage{
pls(actuals, forecasts, Etype = c("A", "M"), sigma, trace = TRUE,
  iprob = 1, digits = 5, varVec = NULL, rounded = FALSE, ...)
}
\arguments{
\item{actuals}{Actual values from the holdout.}

\item{forecasts}{Point forecasts for the holdout (conditional mean).}

\item{Etype}{Type of the error. If \code{Etype="A"}, then normal distribution
is used, if \code{Etype="M"}, then log-normal distribution is used.}

\item{sigma}{Value of variance of the errors. In case of \code{trace=TRUE}, this
needs to be a covariance matrix of trace errors.}

\item{trace}{If \code{TRUE}, then it is assumed that we are provided with trace
forecasts (multiple steps ahead), Trace Forecast Likelihood is used in this case.}

\item{iprob}{Vector of probabilities of occurrences for the holdout (only needed
for intermittent models).}

\item{digits}{Number of digits for rounding.}

\item{varVec}{Vector of 1 to h steps ahead analytical variance. Needed mainly for Etype=="M".}

\item{rounded}{Defines if the rounded up value is used for demand sizes.}

\item{...}{Other parameters passed to mean function.}
}
\value{
A value of the log-likelihood.
}
\description{
Function estimates Prediction Likelihood Score of the holdout actuals based on the model.
}
\details{
Prediction likelihood score (PLS) is based on either normal or log-normal
distribution of errors with the provided parameters. It returns the log of probability
that the data was "produced" by the estimated model. %In case of trace forecasts PLS is
%based on trace forecast likelihood but returns value devided by squared horizon (in order
%to keep scale consistent with non-trace cases).
}
\examples{

# pls() function now works correctly only when varVec is provided
# And varVec is not provided by any function, but is generated inside them.

# Generate data, apply es() with the holdout parameter and calculate PLS
x <- rnorm(100,0,1)
ourModel <- es(x, h=10, holdout=TRUE, intervals=TRUE)
sigma <- t(ourModel$errors) \%*\% (ourModel$errors) / length(ourModel$residuals)
Etype <- substr(modelType(ourModel),1,1)
pls(actuals=ourModel$holdout, forecasts=ourModel$forecast, Etype=Etype,
    sigma=sigma, trace=TRUE)

# Do the same with intermittent data. Trace is not available yet for
# intermittent state-space models
x <- rpois(100,0.4)
ourModel <- es(x, h=10, holdout=TRUE, intermittent='a', intervals=TRUE)
Etype <- substr(modelType(ourModel),1,1)
iprob <- ourModel$imodel$fitted
pls(actuals=ourModel$holdout, forecasts=ourModel$forecast, Etype=Etype,
    sigma=ourModel$s2, trace=FALSE, iprob=iprob)

}
\references{
\itemize{
\item Snyder, R. D., Ord, J. K., Beaumont, A., 2012. Forecasting the intermittent
demand for slow-moving inventories: A modelling approach. International
Journal of Forecasting 28 (2), 485-496.
\item Kolassa, S., 2016. Evaluating predictive count data distributions in retail
sales forecasting. International Journal of Forecasting 32 (3), 788-803.
}
}
\author{
Ivan Svetunkov, \email{ivan@svetunkov.ru}
}
\keyword{models}
\keyword{nonlinear}
\keyword{regression}
\keyword{smooth}
\keyword{ts}
\keyword{univar}
