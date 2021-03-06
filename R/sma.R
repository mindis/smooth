utils::globalVariables(c("yForecastStart"));

#' Simple Moving Average
#'
#' Function constructs State-Space simple moving average of predefined order
#'
#' The function constructs AR model in the Single Source of Error State-space form
#' based on the idea that:
#'
#' \eqn{y_{t} = \frac{1}{n} \sum_{j=1}^n y_{t-j}}
#'
#' which is AR(n) process, that can be modelled using:
#'
#' \eqn{y_{t} = w' v_{t-1} + \epsilon_{t}}
#'
#' \eqn{v_{t} = F v_{t-1} + g \epsilon_{t}}
#'
#' Where \eqn{v_{t}} is a state vector.
#'
#' @template ssBasicParam
#' @template ssAuthor
#' @template ssKeywords
#'
#' @template smoothRef
#'
#' @param order Order of simple moving average. If \code{NULL}, then it is
#' selected automatically using information criteria.
#' @param ...  Other non-documented parameters.  For example parameter
#' \code{model} can accept a previously estimated SMA model and use its
#' parameters.
#' @return Object of class "smooth" is returned. It contains the list of the
#' following values:
#'
#' \itemize{
#' \item \code{model} - the name of the estimated model.
#' \item \code{timeElapsed} - time elapsed for the construction of the model.
#' \item \code{states} - the matrix of the fuzzy components of ssarima, where
#' \code{rows} correspond to time and \code{cols} to states.
#' \item \code{transition} - matrix F.
#' \item \code{persistence} - the persistence vector. This is the place, where
#' smoothing parameters live.
#' \item \code{order} - order of moving average.
#' \item \code{initial} - Initial state vector values.
#' \item \code{initialType} - Type of initial values used.
#' \item \code{nParam} - table with the number of estimated / provided parameters.
#' If a previous model was reused, then its initials are reused and the number of
#' provided parameters will take this into account.
#' \item \code{fitted} - the fitted values of ETS.
#' \item \code{forecast} - the point forecast of ETS.
#' \item \code{lower} - the lower bound of prediction interval. When
#' \code{intervals=FALSE} then NA is returned.
#' \item \code{upper} - the higher bound of prediction interval. When
#' \code{intervals=FALSE} then NA is returned.
#' \item \code{residuals} - the residuals of the estimated model.
#' \item \code{errors} - The matrix of 1 to h steps ahead errors.
#' \item \code{s2} - variance of the residuals (taking degrees of freedom into
#' account).
#' \item \code{intervals} - type of intervals asked by user.
#' \item \code{level} - confidence level for intervals.
#' \item \code{cumulative} - whether the produced forecast was cumulative or not.
#' \item \code{actuals} - the original data.
#' \item \code{holdout} - the holdout part of the original data.
#' \item \code{ICs} - values of information criteria of the model. Includes AIC,
#' AICc and BIC.
#' \item \code{logLik} - log-likelihood of the function.
#' \item \code{cf} - Cost function value.
#' \item \code{cfType} - Type of cost function used in the estimation.
#' \item \code{accuracy} - vector of accuracy measures for the
#' holdout sample. Includes: MPE, MAPE, SMAPE, MASE, sMAE, RelMAE, sMSE and
#' Bias coefficient (based on complex numbers). This is available only when
#' \code{holdout=TRUE}.
#' }
#'
#' @seealso \code{\link[forecast]{ma}, \link[smooth]{es},
#' \link[smooth]{ssarima}}
#'
#' @keywords SARIMA ARIMA
#' @examples
#'
#' # SMA of specific order
#' ourModel <- sma(rnorm(118,100,3),order=12,h=18,holdout=TRUE,intervals="p")
#'
#' # SMA of arbitrary order
#' ourModel <- sma(rnorm(118,100,3),h=18,holdout=TRUE,intervals="sp")
#'
#' summary(ourModel)
#' forecast(ourModel)
#' plot(forecast(ourModel))
#'
#' @export sma
sma <- function(data, order=NULL, ic=c("AICc","AIC","BIC"),
                h=10, holdout=FALSE, cumulative=FALSE,
                intervals=c("none","parametric","semiparametric","nonparametric"), level=0.95,
                silent=c("all","graph","legend","output","none"),
                ...){
# Function constructs simple moving average in state-space model

#    Copyright (C) 2016  Ivan Svetunkov

# Start measuring the time of calculations
    startTime <- Sys.time();

# Add all the variables in ellipsis to current environment
    list2env(list(...),environment());

# If a previous model provided as a model, write down the variables
    if(exists("model")){
        if(is.null(model$model)){
            stop("The provided model is not Simple Moving Average!",call.=FALSE);
        }
        else if(gregexpr("SMA",model$model)==-1){
            stop("The provided model is not Simple Moving Average!",call.=FALSE);
        }
        else{
            order <- model$order;
        }
    }

    initial <- "backcasting";
    intermittent <- "none";
    imodel <- NULL;
    bounds <- "admissible";
    cfType <- "MSE";
    xreg <- NULL;
    nExovars <- 1;
    ivar <- 0;

##### Set environment for ssInput and make all the checks #####
    environment(ssInput) <- environment();
    ssInput("sma",ParentEnvironment=environment());

##### Preset y.fit, y.for, errors and basic parameters #####
    y.fit <- rep(NA,obsInsample);
    y.for <- rep(NA,h);
    errors <- rep(NA,obsInsample);
    maxlag <- 1;

# These three are needed in order to use ssgeneralfun.cpp functions
    Etype <- "A";
    Ttype <- "N";
    Stype <- "N";

    if(!is.null(order)){
        if(obsInsample < order){
            stop("Sorry, but we don't have enough observations for that order.",call.=FALSE);
        }

        if(!is.numeric(order)){
            stop("The provided order is not numeric.",call.=FALSE);
        }
        else{
            if(length(order)!=1){
                warning("The order should be a scalar. Using the first provided value.",call.=FALSE);
                order <- order[1];
            }

            if(order<1){
                stop("The order of the model must be a positive number.",call.=FALSE);
            }
        }
        orderSelect <- FALSE;
    }
    else{
        orderSelect <- TRUE;
    }

# sd of residuals + a parameter... nComponents not included.
    nParam <- 1 + 1;

# Cost function for GES
CF <- function(C){
    fitting <- fitterwrap(matvt, matF, matw, y, vecg,
                          modellags, Etype, Ttype, Stype, initialType,
                          matxt, matat, matFX, vecgX, ot);

    cfRes <- mean(fitting$errors^2);

    return(cfRes);
}

CreatorSMA <- function(silentText=FALSE,...){
    environment(likelihoodFunction) <- environment();
    environment(ICFunction) <- environment();
    environment(CF) <- environment();

    nComponents <- order;
    #nParam <- nComponents + 1;
    if(order>1){
        matF <- rbind(cbind(rep(1/nComponents,nComponents-1),diag(nComponents-1)),c(1/nComponents,rep(0,nComponents-1)));
        matw <- matrix(c(1,rep(0,nComponents-1)),1,nComponents);
    }
    else{
        matF <- matrix(1,1,1);
        matw <- matrix(1,1,1);
    }
    vecg <- matrix(1/nComponents,nComponents);
    matvt <- matrix(NA,obsStates,nComponents);
    matvt[1:nComponents,1] <- rep(mean(y[1:nComponents]),nComponents);
    if(nComponents>1){
        for(i in 2:nComponents){
            matvt[1:(nComponents-i+1),i] <- matvt[1:(nComponents-i+1)+1,i-1] - matvt[1:(nComponents-i+1),1] * matF[i-1,1];
        }
    }

    modellags <- rep(1,nComponents);

##### Prepare exogenous variables #####
    xregdata <- ssXreg(data=data, xreg=NULL, updateX=FALSE,
                       persistenceX=NULL, transitionX=NULL, initialX=NULL,
                       obsInsample=obsInsample, obsAll=obsAll, obsStates=obsStates, maxlag=maxlag, h=h, silent=silentText);
    matxt <- xregdata$matxt;
    matat <- xregdata$matat;
    matFX <- xregdata$matFX;
    vecgX <- xregdata$vecgX;

    C <- NULL;
    cfObjective <- CF(C);

    ICValues <- ICFunction(nParam=nParam,C=C,Etype=Etype);
    ICs <- ICValues$ICs;
    logLik <- ICValues$llikelihood;
    bestIC <- ICs["AICc"];

    return(list(cfObjective=cfObjective,ICs=ICs,bestIC=bestIC,nParam=nParam,nComponents=nComponents,
                matF=matF,vecg=vecg,matvt=matvt,matw=matw,modellags=modellags,
                matxt=matxt,matat=matat,matFX=matFX,vecgX=vecgX,logLik=logLik));
}

#####Start the calculations#####
    environment(ssForecaster) <- environment();
    environment(ssFitter) <- environment();

    if(orderSelect){
        maxOrder <- min(200,obsInsample);
        ICs <- rep(NA,maxOrder);
        smaValuesAll <- list(NA);
        for(i in 1:maxOrder){
            order <- i;
            smaValuesAll[[i]] <- CreatorSMA(silentText);
            ICs[i] <- smaValuesAll[[i]]$bestIC;
        }
        order <- which(ICs==min(ICs,na.rm=TRUE))[1];
        smaValues <- smaValuesAll[[order]];
    }
    else{
        smaValues <- CreatorSMA(silentText);
    }

    list2env(smaValues,environment());

##### Fit simple model and produce forecast #####
    ssFitter(ParentEnvironment=environment());
    ssForecaster(ParentEnvironment=environment());

    parametersNumber[1,1] <- 2;
    parametersNumber[1,4] <- 2;

##### Do final check and make some preparations for output #####

    if(holdout==T){
        y.holdout <- ts(data[(obsInsample+1):obsAll],start=yForecastStart,frequency=frequency(data));
        if(cumulative){
            errormeasures <- Accuracy(sum(y.holdout),y.for,h*y);
        }
        else{
            errormeasures <- Accuracy(y.holdout,y.for,y);
        }

        if(cumulative){
            y.holdout <- ts(sum(y.holdout),start=yForecastStart,frequency=datafreq);
        }
    }
    else{
        y.holdout <- NA;
        errormeasures <- NA;
    }

    modelname <- paste0("SMA(",order,")");

##### Make a plot #####
    if(!silentGraph){
        y.for.new <- y.for;
        y.high.new <- y.high;
        y.low.new <- y.low;
        if(cumulative){
            y.for.new <- ts(rep(y.for/h,h),start=yForecastStart,frequency=datafreq)
            if(intervals){
                y.high.new <- ts(rep(y.high/h,h),start=yForecastStart,frequency=datafreq)
                y.low.new <- ts(rep(y.low/h,h),start=yForecastStart,frequency=datafreq)
            }
        }

        if(intervals){
            graphmaker(actuals=data,forecast=y.for.new,fitted=y.fit, lower=y.low.new,upper=y.high.new,
                       level=level,legend=!silentLegend,main=modelname,cumulative=cumulative);
        }
        else{
            graphmaker(actuals=data,forecast=y.for.new,fitted=y.fit,
                       legend=!silentLegend,main=modelname,cumulative=cumulative);
        }
    }

##### Return values #####
    model <- list(model=modelname,timeElapsed=Sys.time()-startTime,
                  states=matvt,transition=matF,persistence=vecg,
                  order=order, initial=matvt[1,], initialType=initialType, nParam=parametersNumber,
                  fitted=y.fit,forecast=y.for,lower=y.low,upper=y.high,residuals=errors,
                  errors=errors.mat,s2=s2,intervals=intervalsType,level=level,cumulative=cumulative,
                  actuals=data,holdout=y.holdout,imodel=NULL,
                  ICs=ICs,logLik=logLik,cf=cfObjective,cfType=cfType,accuracy=errormeasures);
    return(structure(model,class="smooth"));
}
