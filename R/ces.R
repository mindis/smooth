utils::globalVariables(c("silentText","silentGraph","silentLegend","initialType","yForecastStart"));

#' Complex Exponential Smoothing
#'
#' Function estimates CES in state-space form with information potential equal
#' to errors and returns several variables.
#'
#' The function estimates Complex Exponential Smoothing in the state-space 2
#' described in Svetunkov, Kourentzes (2017) with the information potential
#' equal to the approximation error.  The estimation of initial states of xt is
#' done using backcast.
#'
#' @template ssBasicParam
#' @template ssAdvancedParam
#' @template ssInitialParam
#' @template ssAuthor
#' @template ssKeywords
#'
#' @template ssCESRef
#'
#' @param seasonality The type of seasonality used in CES. Can be: \code{none}
#' - No seasonality; \code{simple} - Simple seasonality, using lagged CES
#' (based on \code{t-m} observation, where \code{m} is the seasonality lag);
#' \code{partial} - Partial seasonality with real seasonal components
#' (equivalent to additive seasonality); \code{full} - Full seasonality with
#' complex seasonal components (can do both multiplicative and additive
#' seasonality, depending on the data). First letter can be used instead of
#' full words.  Any seasonal CES can only be constructed for time series
#' vectors.
#' @param A First complex smoothing parameter. Should be a complex number.
#'
#' NOTE! CES is very sensitive to A and B values so it is advised either to
#' leave them alone, or to use values from previously estimated model.
#' @param B Second complex smoothing parameter. Can be real if
#' \code{seasonality="partial"}. In case of \code{seasonality="full"} must be
#' complex number.
#' @param ...  Other non-documented parameters.  For example parameter
#' \code{model} can accept a previously estimated CES model and use all its
#' parameters.  \code{FI=TRUE} will make the function produce Fisher
#' Information matrix, which then can be used to calculated variances of
#' parameters of the model.
#' @return Object of class "smooth" is returned. It contains the list of the
#' following values: \itemize{
#' \item \code{model} - type of constructed model.
#' \item \code{timeElapsed} - time elapsed for the construction of the model.
#' \item \code{states} - the matrix of the components of CES. The included
#' minimum is "level" and "potential". In the case of seasonal model the
#' seasonal component is also included. In the case of exogenous variables the
#' estimated coefficients for the exogenous variables are also included.
#' \item \code{A} - complex smoothing parameter in the form a0 + ia1
#' \item \code{B} - smoothing parameter for the seasonal component. Can either
#' be real (if \code{seasonality="P"}) or complex (if \code{seasonality="F"})
#' in a form b0 + ib1.
#' \item \code{initialType} - Type of the initial values used.
#' \item \code{initial} - the initial values of the state vector (non-seasonal).
#' \item \code{nParam} - table with the number of estimated / provided parameters.
#' If a previous model was reused, then its initials are reused and the number of
#' provided parameters will take this into account.
#' \item \code{fitted} - the fitted values of CES.
#' \item \code{forecast} - the point forecast of CES.
#' \item \code{lower} - the lower bound of prediction interval. When
#' \code{intervals="none"} then NA is returned.
#' \item \code{upper} - the upper bound of prediction interval. When
#' \code{intervals="none"} then NA is returned.
#' \item \code{residuals} - the residuals of the estimated model.
#' \item \code{errors} - The matrix of 1 to h steps ahead errors.
#' \item \code{s2} - variance of the residuals (taking degrees of
#' freedom into account).
#' \item \code{intervals} - type of intervals asked by user.
#' \item \code{level} - confidence level for intervals.
#' \item \code{cumulative} - whether the produced forecast was cumulative or not.
#' \item \code{actuals} - The data provided in the call of the function.
#' \item \code{holdout} - the holdout part of the original data.
#' \item \code{imodel} - model of the class "iss" if intermittent model was estimated.
#' If the model is non-intermittent, then imodel is \code{NULL}.
#' \item \code{xreg} - provided vector or matrix of exogenous variables. If
#' \code{xregDo="s"}, then this value will contain only selected exogenous
#' variables.
#' \item \code{updateX} - boolean, defining, if the states of
#' exogenous variables were estimated as well.
#' \item \code{initialX} - initial values for parameters of exogenous variables.
#' \item \code{persistenceX} - persistence vector g for exogenous variables.
#' \item \code{transitionX} - transition matrix F for exogenous variables.
#' \item \code{ICs} - values of information criteria of the model. Includes
#' AIC, AICc, BIC and CIC (Complex IC).
#' \item \code{logLik} - log-likelihood of the function.
#' \item \code{cf} - Cost function value.
#' \item \code{cfType} - Type of cost function used in the estimation.
#' \item \code{FI} - Fisher Information. Equal to NULL if \code{FI=FALSE}
#' or when \code{FI} is not provided at all.
#' \item \code{accuracy} - vector of accuracy measures for the holdout sample. In
#' case of non-intermittent data includes: MPE, MAPE, SMAPE, MASE, sMAE,
#' RelMAE, sMSE and Bias coefficient (based on complex numbers). In case of
#' intermittent data the set of errors will be: sMSE, sPIS, sCE (scaled
#' cumulative error) and Bias coefficient. This is available only when
#' \code{holdout=TRUE}.
#' }
#' @seealso \code{\link[forecast]{ets}, \link[forecast]{forecast},
#' \link[stats]{ts}, \link[smooth]{auto.ces}}
#'
#' @examples
#'
#' y <- rnorm(100,10,3)
#' ces(y,h=20,holdout=TRUE)
#' ces(y,h=20,holdout=FALSE)
#'
#' y <- 500 - c(1:100)*0.5 + rnorm(100,10,3)
#' ces(y,h=20,holdout=TRUE,intervals="p",bounds="a")
#'
#' library("Mcomp")
#' y <- ts(c(M3$N0740$x,M3$N0740$xx),start=start(M3$N0740$x),frequency=frequency(M3$N0740$x))
#' ces(y,h=8,holdout=TRUE,seasonality="s",intervals="sp",level=0.8)
#'
#' \dontrun{y <- ts(c(M3$N1683$x,M3$N1683$xx),start=start(M3$N1683$x),frequency=frequency(M3$N1683$x))
#' ces(y,h=18,holdout=TRUE,seasonality="s",intervals="sp")
#' ces(y,h=18,holdout=TRUE,seasonality="p",intervals="np")
#' ces(y,h=18,holdout=TRUE,seasonality="f",intervals="p")}
#'
#' \dontrun{x <- cbind(c(rep(0,25),1,rep(0,43)),c(rep(0,10),1,rep(0,58)))
#' ces(ts(c(M3$N1457$x,M3$N1457$xx),frequency=12),h=18,holdout=TRUE,
#'     intervals="np",xreg=x,cfType="TMSE")}
#'
#' # Exogenous variables in CES
#' \dontrun{x <- cbind(c(rep(0,25),1,rep(0,43)),c(rep(0,10),1,rep(0,58)))
#' ces(ts(c(M3$N1457$x,M3$N1457$xx),frequency=12),h=18,holdout=TRUE,xreg=x)
#' ourModel <- ces(ts(c(M3$N1457$x,M3$N1457$xx),frequency=12),h=18,holdout=TRUE,xreg=x,updateX=TRUE)
#' # This will be the same model as in previous line but estimated on new portion of data
#' ces(ts(c(M3$N1457$x,M3$N1457$xx),frequency=12),model=ourModel,h=18,holdout=FALSE)}
#'
#' # Intermittent data example
#' x <- rpois(100,0.2)
#' # Best type of intermittent model based on iETS(Z,Z,N)
#' ourModel <- ces(x,intermittent="auto")
#'
#' summary(ourModel)
#' forecast(ourModel)
#' plot(forecast(ourModel))
#'
#' @export ces
ces <- function(data, seasonality=c("none","simple","partial","full"),
                initial=c("optimal","backcasting"), A=NULL, B=NULL, ic=c("AICc","AIC","BIC"),
                cfType=c("MSE","MAE","HAM","MSEh","TMSE","GTMSE"),
                h=10, holdout=FALSE, cumulative=FALSE,
                intervals=c("none","parametric","semiparametric","nonparametric"), level=0.95,
                intermittent=c("none","auto","fixed","interval","probability","sba","logistic"),
                imodel="MNN",
                bounds=c("admissible","none"),
                silent=c("all","graph","legend","output","none"),
                xreg=NULL, xregDo=c("use","select"), initialX=NULL,
                updateX=FALSE, persistenceX=NULL, transitionX=NULL, ...){
# Function estimates CES in state-space form with sigma = error
#  and returns complex smoothing parameter value, fitted values,
#  residuals, point and interval forecasts, matrix of CES components and values of
#  information criteria.
#
#    Copyright (C) 2015 - 2016i  Ivan Svetunkov

# Start measuring the time of calculations
    startTime <- Sys.time();

# Add all the variables in ellipsis to current environment
    list2env(list(...),environment());

    # If a previous model provided as a model, write down the variables
    if(exists("model",inherits=FALSE)){
        if(is.null(model$model)){
            stop("The provided model is not CES.",call.=FALSE);
        }
        else if(gregexpr("ES",model$model)==-1){
            stop("The provided model is not CES.",call.=FALSE);
        }
        if(!is.null(model$imodel)){
            imodel <- model$imodel;
        }
        initial <- model$initial;
        A <- model$A;
        B <- model$B;
        if(is.null(xreg)){
            xreg <- model$xreg;
        }
        initialX <- model$initialX;
        persistenceX <- model$persistenceX;
        transitionX <- model$transitionX;
        if(any(c(persistenceX)!=0) | any((transitionX!=0)&(transitionX!=1))){
            updateX <- TRUE;
        }
        model <- model$model;
        seasonality <- substring(model,unlist(gregexpr("\\(",model))+1,unlist(gregexpr("\\)",model))-1);
    }

##### Set environment for ssInput and make all the checks #####
    environment(ssInput) <- environment();
    ssInput("ces",ParentEnvironment=environment());

##### Elements of CES #####
ElementsCES <- function(C){
    vt <- matrix(matvt[1:maxlag,],maxlag);
    nCoefficients <- 0;
    # No seasonality or Simple seasonality, lagged CES
    if(A$estimate){
        matF[1,2] <- C[2]-1;
        matF[2,2] <- 1-C[1];
        vecg[1:2,] <- c(C[1]-C[2],C[1]+C[2]);
        nCoefficients <- nCoefficients + 2;
    }
    else{
        matF[1,2] <- Im(A$value)-1;
        matF[2,2] <- 1-Re(A$value);
        vecg[1:2,] <- c(Re(A$value)-Im(A$value),Re(A$value)+Im(A$value));
    }

    if(seasonality=="p"){
    # Partial seasonality with a real part only
        if(B$estimate){
            vecg[3,] <- C[nCoefficients+1];
            nCoefficients <- nCoefficients + 1;
        }
        else{
            vecg[3,] <- B$value;
        }
    }
    else if(seasonality=="f"){
    # Full seasonality with both real and imaginary parts
        if(B$estimate){
            matF[3,4] <- C[nCoefficients+2]-1;
            matF[4,4] <- 1-C[nCoefficients+1];
            vecg[3:4,] <- c(C[nCoefficients+1]-C[nCoefficients+2],C[nCoefficients+1]+C[nCoefficients+2]);
            nCoefficients <- nCoefficients + 2;
        }
        else{
            matF[3,4] <- Im(B$value)-1;
            matF[4,4] <- 1-Re(B$value);
            vecg[3:4,] <- c(Re(B$value)-Im(B$value),Re(B$value)+Im(B$value));
        }
    }

    if(initialType=="o"){
        if(any(seasonality==c("n","s"))){
            vt[1:maxlag,] <- C[nCoefficients+(1:(2*maxlag))];
            nCoefficients <- nCoefficients + maxlag*2;
        }
        else if(seasonality=="p"){
            vt[,1:2] <- rep(C[nCoefficients+(1:2)],each=maxlag);
            nCoefficients <- nCoefficients + 2;
            vt[1:maxlag,3] <- C[nCoefficients+(1:maxlag)];
            nCoefficients <- nCoefficients + maxlag;
        }
        else if(seasonality=="f"){
            vt[,1:2] <- rep(C[nCoefficients+(1:2)],each=maxlag);
            nCoefficients <- nCoefficients + 2;
            vt[1:maxlag,3:4] <- C[nCoefficients+(1:(maxlag*2))];
            nCoefficients <- nCoefficients + maxlag*2;
        }
    }
    else if(initialType=="b"){
        vt[1:maxlag,] <- matvt[1:maxlag,];
    }
    else{
        vt[1:maxlag,] <- initialValue;
    }

# If exogenous are included
    if(xregEstimate){
        at <- matrix(NA,maxlag,nExovars);
        if(initialXEstimate){
            at[,] <- rep(C[nCoefficients+(1:nExovars)],each=maxlag);
            nCoefficients <- nCoefficients + nExovars;
        }
        else{
            at <- matat[1:maxlag,];
        }
        if(updateX){
            if(FXEstimate){
                matFX <- matrix(C[nCoefficients+(1:(nExovars^2))],nExovars,nExovars);
                nCoefficients <- nCoefficients + nExovars^2;
            }

            if(gXEstimate){
                vecgX <- matrix(C[nCoefficients+(1:nExovars)],nExovars,1);
                nCoefficients <- nCoefficients + nExovars;
            }
        }
    }
    else{
        at <- matrix(matat[1:maxlag,],maxlag,nExovars);
    }

    return(list(matF=matF,vecg=vecg,vt=vt,at=at,matFX=matFX,vecgX=vecgX));
}

##### Cost function for CES #####
CF <- function(C){
# Obtain the elements of CES
    elements <- ElementsCES(C);
    matF <- elements$matF;
    vecg <- elements$vecg;
    matvt[1:maxlag,] <- elements$vt;
    matat[1:maxlag,] <- elements$at;
    matFX <- elements$matFX;
    vecgX <- elements$vecgX;

    cfRes <- costfunc(matvt, matF, matw, y, vecg,
                      h, modellags, Etype, Ttype, Stype,
                      multisteps, cfType, normalizer, initialType,
                      matxt, matat, matFX, vecgX, ot,
                      bounds);

    if(is.nan(cfRes) | is.na(cfRes)){
        cfRes <- 1e100;
    }
    return(cfRes);
}

##### Estimate ces or just use the provided values #####
CreatorCES <- function(silentText=FALSE,...){
    environment(likelihoodFunction) <- environment();
    environment(ICFunction) <- environment();

    nParam <- (1 + sum(modellags)*(initialType=="o") + A$number*A$estimate + B$number*B$estimate +
                   nExovars * initialXEstimate +
                   (updateX)*((nExovars^2)*FXEstimate + nExovars*gXEstimate));

    if(any(initialType=="o",A$estimate,B$estimate,initialXEstimate,FXEstimate,gXEstimate)){
        C <- NULL;
        # If we don't need to estimate A
        if(A$estimate){
            C <- c(1.3,1);
        }

        if(any(seasonality==c("n","s"))){
            if(initialType=="o"){
                C <- c(C,c(matvt[1:maxlag,]));
            }
        }
        else if(seasonality=="p"){
            if(B$estimate){
                C <- c(C,0.1);
            }
            if(initialType=="o"){
                C <- c(C,c(matvt[1,1:2]));
                C <- c(C,c(matvt[1:maxlag,3]));
            }
        }
        else{
            if(B$estimate){
                C <- c(C,1.3,1);
            }
            if(initialType=="o"){
                C <- c(C,c(matvt[1,1:2]));
                C <- c(C,c(matvt[1:maxlag,3:4]));
            }
        }

        if(xregEstimate){
            if(initialXEstimate){
                C <- c(C,matat[maxlag,]);
            }
            if(updateX){
                if(FXEstimate){
                    C <- c(C,c(diag(nExovars)));
                }
                if(gXEstimate){
                    C <- c(C,rep(0,nExovars));
                }
            }
        }

        res <- nloptr(C, CF, opts=list("algorithm"="NLOPT_LN_BOBYQA", "xtol_rel"=1e-8, "maxeval"=1000));
        C <- res$solution;

        #In cases of xreg the optimiser sometimes fails to find reasonable parameters
        if(!is.null(xreg)){
            res2 <- nloptr(C, CF, opts=list("algorithm"="NLOPT_LN_NELDERMEAD", "xtol_rel"=1e-8, "maxeval"=5000));
        }
        else{
            res2 <- nloptr(C, CF, opts=list("algorithm"="NLOPT_LN_NELDERMEAD", "xtol_rel"=1e-8, "maxeval"=1000));
        }
            # This condition is needed in order to make sure that we did not make the solution worse
        if(res2$objective <= res$objective){
            res <- res2;
        }

        C <- res$solution;
        cfObjective <- res$objective;
    }
    else{
        C <- c(A$value,B$value,initialValue,initialX,transitionX,persistenceX);
        cfObjective <- CF(C);
    }
    if(multisteps){
        cfType <- "aTFL";
    }
    else{
        cfType <- "MSE";
    }
    ICValues <- ICFunction(nParam=nParam+nParamIntermittent,C=C,Etype=Etype);
    ICs <- ICValues$ICs;
    logLik <- ICValues$llikelihood;

    bestIC <- ICs["AICc"];

# Revert to the provided cost function
    cfType <- cfTypeOriginal;

    return(list(cfObjective=cfObjective,C=C,ICs=ICs,bestIC=bestIC,nParam=nParam,logLik=logLik));
}

##### Preset y.fit, y.for, errors and basic parameters #####
    matvt <- matrix(NA,nrow=obsStates,ncol=nComponents);
    y.fit <- rep(NA,obsInsample);
    y.for <- rep(NA,h);
    errors <- rep(NA,obsInsample);

##### Define parameters for different seasonality types #####
    # Define "w" matrix, seasonal complex smoothing parameter, seasonality lag (if it is present).
    #   matvt - the matrix with the components, lags is the lags used in pt matrix.
    if(seasonality=="n"){
        # No seasonality
        matF <- matrix(1,2,2);
        vecg <- matrix(0,2);
        matw <- matrix(c(1,0),1,2);
        matvt <- matrix(NA,obsStates,2);
        colnames(matvt) <- c("level","potential");
        matvt[1,] <- c(mean(yot[1:min(max(10,datafreq),obsNonzero)]),mean(yot[1:min(max(10,datafreq),obsNonzero)])/1.1);
    }
    else if(seasonality=="s"){
        # Simple seasonality, lagged CES
        matF <- matrix(1,2,2);
        vecg <- matrix(0,2);
        matw <- matrix(c(1,0),1,2);
        matvt <- matrix(NA,obsStates,2);
        colnames(matvt) <- c("level.s","potential.s");
        matvt[1:maxlag,1] <- y[1:maxlag];
        matvt[1:maxlag,2] <- matvt[1:maxlag,1]/1.1;
    }
    else if(seasonality=="p"){
        # Partial seasonality with a real part only
        matF <- diag(3);
        matF[2,1] <- 1;
        vecg <- matrix(0,3);
        matw <- matrix(c(1,0,1),1,3);
        matvt <- matrix(NA,obsStates,3);
        colnames(matvt) <- c("level","potential","seasonal");
        matvt[1:maxlag,1] <- mean(y[1:maxlag]);
        matvt[1:maxlag,2] <- matvt[1:maxlag,1]/1.1;
        matvt[1:maxlag,3] <- decompose(ts(y,frequency=maxlag),type="additive")$figure;
    }
    else if(seasonality=="f"){
        # Full seasonality with both real and imaginary parts
        matF <- diag(4);
        matF[2,1] <- 1;
        matF[4,3] <- 1;
        vecg <- matrix(0,4);
        matw <- matrix(c(1,0,1,0),1,4);
        matvt <- matrix(NA,obsStates,4);
        colnames(matvt) <- c("level","potential","seasonal 1", "seasonal 2");
        matvt[1:maxlag,1] <- mean(y[1:maxlag]);
        matvt[1:maxlag,2] <- matvt[1:maxlag,1]/1.1;
        matvt[1:maxlag,3] <- decompose(ts(y,frequency=maxlag),type="additive")$figure;
        matvt[1:maxlag,4] <- matvt[1:maxlag,3]/1.1;
    }

##### Prepare exogenous variables #####
    xregdata <- ssXreg(data=data, xreg=xreg, updateX=updateX, ot=ot,
                       persistenceX=persistenceX, transitionX=transitionX, initialX=initialX,
                       obsInsample=obsInsample, obsAll=obsAll, obsStates=obsStates,
                       maxlag=maxlag, h=h, xregDo=xregDo, silent=silentText);

    if(xregDo=="u"){
        nExovars <- xregdata$nExovars;
        matxt <- xregdata$matxt;
        matat <- xregdata$matat;
        xregEstimate <- xregdata$xregEstimate;
        matFX <- xregdata$matFX;
        vecgX <- xregdata$vecgX;
        xregNames <- colnames(matxt);
    }
    else{
        nExovars <- 1;
        nExovarsOriginal <- xregdata$nExovars;
        matxtOriginal <- xregdata$matxt;
        matatOriginal <- xregdata$matat;
        xregEstimateOriginal <- xregdata$xregEstimate;
        matFXOriginal <- xregdata$matFX;
        vecgXOriginal <- xregdata$vecgX;

        matxt <- matrix(1,nrow(matxtOriginal),1);
        matat <- matrix(0,nrow(matatOriginal),1);
        xregEstimate <- FALSE;
        matFX <- matrix(1,1,1);
        vecgX <- matrix(0,1,1);
        xregNames <- NULL;
    }
    xreg <- xregdata$xreg;
    FXEstimate <- xregdata$FXEstimate;
    gXEstimate <- xregdata$gXEstimate;
    initialXEstimate <- xregdata$initialXEstimate;

    # These three are needed in order to use ssgeneralfun.cpp functions
    Etype <- "A";
    Ttype <- "N";
    Stype <- "N";

    # Check number of parameters vs data
    nParamExo <- FXEstimate*length(matFX) + gXEstimate*nrow(vecgX) + initialXEstimate*ncol(matat);
    nParamIntermittent <- all(intermittent!=c("n","provided"))*1;
    nParamMax <- nParamMax + nParamExo + nParamIntermittent;

    if(xregDo=="u"){
        parametersNumber[1,2] <- nParamExo;
        # If transition is provided and not identity, and other things are provided, write them as "provided"
        parametersNumber[2,2] <- (length(matFX)*(!is.null(transitionX) & !all(matFX==diag(ncol(matat)))) +
                                      nrow(vecgX)*(!is.null(persistenceX)) +
                                      ncol(matat)*(!is.null(initialX)) - nParamExo);
    }

##### Check number of observations vs number of max parameters #####
    if(obsNonzero <= nParamMax){
        if(xregDo=="select"){
            if(obsNonzero <= (nParamMax - nParamExo)){
                warning(paste0("Not enough observations for the reasonable fit. Number of parameters is ",
                            nParamMax," while the number of observations is ",obsNonzero - nParamExo,"!"),call.=FALSE);
                tinySample <- TRUE;
            }
            else{
                warning(paste0("The potential number of exogenous variables is higher than the number of observations. ",
                               "This may cause problems in the estimation."),call.=FALSE);
            }
        }
        else{
            warning(paste0("Not enough observations for the reasonable fit. Number of parameters is ",
                           nParamMax," while the number of observations is ",obsNonzero,"!"),call.=FALSE);
            tinySample <- TRUE;
        }
    }
    else{
        tinySample <- FALSE;
    }

# If this is tiny sample, use SES instead
    if(tinySample){
        warning("Not enough observations to fit CES. Switching to ETS(A,N,N).",call.=FALSE);
        return(es(data,"ANN",initial=initial,cfType=cfType,
                  h=h,holdout=holdout,cumulative=cumulative,
                  intervals=intervals,level=level,
                  intermittent=intermittent,
                  imodel=imodel,
                  bounds="u",
                  silent=silent,
                  xreg=xreg,xregDo=xregDo,initialX=initialX,
                  updateX=updateX,persistenceX=persistenceX,transitionX=transitionX));
    }

##### Start doing things #####
    environment(intermittentParametersSetter) <- environment();
    environment(intermittentMaker) <- environment();
    environment(ssForecaster) <- environment();
    environment(ssFitter) <- environment();

    # If auto intermittent, then estimate model with intermittent="n" first.
    if(any(intermittent==c("a","n"))){
        intermittentParametersSetter(intermittent="n",ParentEnvironment=environment());
    }
    else{
        intermittentParametersSetter(intermittent=intermittent,ParentEnvironment=environment());
        intermittentMaker(intermittent=intermittent,ParentEnvironment=environment());
    }

    cesValues <- CreatorCES(silentText=silentText);

##### If intermittent=="a", run a loop and select the best one #####
    if(intermittent=="a"){
        if(cfType!="MSE"){
            warning(paste0("'",cfType,"' is used as cost function instead of 'MSE'. A wrong intermittent model may be selected"),call.=FALSE);
        }
        if(!silentText){
            cat("Selecting appropriate type of intermittency... ");
        }
# Prepare stuff for intermittency selection
        intermittentModelsPool <- c("n","f","i","p","s");
        intermittentCFs <- intermittentICs <- rep(NA,length(intermittentModelsPool));
        intermittentModelsList <- list(NA);
        intermittentICs[1] <- cesValues$bestIC;
        intermittentCFs[1] <- cesValues$cfObjective;

        for(i in 2:length(intermittentModelsPool)){
            intermittentParametersSetter(intermittent=intermittentModelsPool[i],ParentEnvironment=environment());
            intermittentMaker(intermittent=intermittentModelsPool[i],ParentEnvironment=environment());
            intermittentModelsList[[i]] <- CreatorCES(silentText=TRUE);
            intermittentICs[i] <- intermittentModelsList[[i]]$bestIC;
            intermittentCFs[i] <- intermittentModelsList[[i]]$cfObjective;
        }
        intermittentICs[is.nan(intermittentICs) | is.na(intermittentICs)] <- 1e+100;
        intermittentCFs[is.nan(intermittentCFs) | is.na(intermittentCFs)] <- 1e+100;
        # In cases when the data is binary, choose between intermittent models only
        if(any(intermittentCFs==0)){
            if(all(intermittentCFs[2:length(intermittentModelsPool)]==0)){
                intermittentICs[1] <- Inf;
            }
        }
        iBest <- which(intermittentICs==min(intermittentICs))[1];

        if(!silentText){
            cat("Done!\n");
        }
        if(iBest!=1){
            intermittent <- intermittentModelsPool[iBest];
            cesValues <- intermittentModelsList[[iBest]];
        }
        else{
            intermittent <- "n"
        }

        intermittentParametersSetter(intermittent=intermittent,ParentEnvironment=environment());
        intermittentMaker(intermittent=intermittent,ParentEnvironment=environment());
    }

    list2env(cesValues,environment());

    if(xregDo!="u"){
        # Prepare for fitting
        elements <- ElementsCES(C);
        matF <- elements$matF;
        vecg <- elements$vecg;
        matvt[1:maxlag,] <- elements$vt;
        matat[1:maxlag,] <- elements$at;
        matFX <- elements$matFX;
        vecgX <- elements$vecgX;

        # cesValues <- CreatorCES(silentText=TRUE);
        ssFitter(ParentEnvironment=environment());

        xregNames <- colnames(matxtOriginal);
        xregNew <- cbind(errors,xreg[1:nrow(errors),]);
        colnames(xregNew)[1] <- "errors";
        colnames(xregNew)[-1] <- xregNames;
        xregNew <- as.data.frame(xregNew);
        xregResults <- stepwise(xregNew, ic=ic, silent=TRUE, df=nParam+nParamIntermittent-1);
        xregNames <- names(coef(xregResults))[-1];
        nExovars <- length(xregNames);
        if(nExovars>0){
            xregEstimate <- TRUE;
            matxt <- as.data.frame(matxtOriginal)[,xregNames];
            matat <- as.data.frame(matatOriginal)[,xregNames];
            matFX <- diag(nExovars);
            vecgX <- matrix(0,nExovars,1);

            if(nExovars==1){
                matxt <- matrix(matxt,ncol=1);
                matat <- matrix(matat,ncol=1);
                colnames(matxt) <- colnames(matat) <- xregNames;
            }
            else{
                matxt <- as.matrix(matxt);
                matat <- as.matrix(matat);
            }
        }
        else{
            nExovars <- 1;
            xreg <- NULL;
        }

        if(!is.null(xreg)){
            cesValues <- CreatorCES(silentText=TRUE);
            list2env(cesValues,environment());
        }
    }

    if(!is.null(xreg)){
        if(ncol(matat)==1){
            colnames(matxt) <- colnames(matat) <- xregNames;
        }
        xreg <- matxt;
        if(xregDo=="s"){
            nParamExo <- FXEstimate*length(matFX) + gXEstimate*nrow(vecgX) + initialXEstimate*ncol(matat);
            parametersNumber[1,2] <- nParamExo;
        }
    }

# Prepare for fitting
    elements <- ElementsCES(C);
    matF <- elements$matF;
    vecg <- elements$vecg;
    matvt[1:maxlag,] <- elements$vt;
    matat[1:maxlag,] <- elements$at;
    matFX <- elements$matFX;
    vecgX <- elements$vecgX;

# Write down Fisher Information if needed
    if(FI){
        environment(likelihoodFunction) <- environment();
        FI <- numDeriv::hessian(likelihoodFunction,C);
    }

##### Fit simple model and produce forecast #####
    ssFitter(ParentEnvironment=environment());
    ssForecaster(ParentEnvironment=environment());

##### Do final check and make some preparations for output #####

# Write down initials of states vector and exogenous
    if(initialType!="p"){
        initialValue <- matvt[1:maxlag,];
        if(initialType!="b"){
            parametersNumber[1,1] <- (parametersNumber[1,1] + 2*(seasonality!="s") +
                                      maxlag*(seasonality!="n") + maxlag*any(seasonality==c("f","s")));
        }
    }
    if(initialXEstimate){
        initialX <- matat[1,];
    }

    if(gXEstimate){
        persistenceX <- vecgX;
    }

    if(FXEstimate){
        transitionX <- matFX;
    }

    # Add variance estimation
    parametersNumber[1,1] <- parametersNumber[1,1] + 1;

    # Write down the probabilities from intermittent models
    pt <- ts(c(as.vector(pt),as.vector(pt.for)),start=dataStart,frequency=datafreq);
    # Write down the number of parameters of imodel
    if(all(intermittent!=c("n","provided")) & !imodelProvided){
        parametersNumber[1,3] <- imodel$nParam;
    }
    # Make nice names for intermittent
    if(intermittent=="f"){
        intermittent <- "fixed";
    }
    else if(intermittent=="i"){
        intermittent <- "interval";
    }
    else if(intermittent=="p"){
        intermittent <- "probability";
    }
    else if(intermittent=="l"){
        intermittent <- "logistic";
    }
    else if(intermittent=="n"){
        intermittent <- "none";
    }

    if(!is.null(xreg)){
        statenames <- c(colnames(matvt),colnames(matat));
        matvt <- cbind(matvt,matat);
        colnames(matvt) <- statenames;
        if(updateX){
            rownames(vecgX) <- xregNames;
            dimnames(matFX) <- list(xregNames,xregNames);
        }
    }

# Right down the smoothing parameters
    nCoefficients <- 0;
    if(A$estimate){
        A$value <- complex(real=C[1],imaginary=C[2]);
        nCoefficients <- 2;
        parametersNumber[1,1] <- parametersNumber[1,1] + 2;
    }

    names(A$value) <- "a0+ia1";

    if(B$estimate){
        if(seasonality=="p"){
            B$value <- C[nCoefficients+1];
            parametersNumber[1,1] <- parametersNumber[1,1] + 1;
        }
        else if(seasonality=="f"){
            B$value <- complex(real=C[nCoefficients+1],imaginary=C[nCoefficients+2]);
            parametersNumber[1,1] <- parametersNumber[1,1] + 2;
        }
    }
    if(B$number!=0){
        if(is.complex(B$value)){
            names(B$value) <- "b0+ib1";
        }
        else{
            names(B$value) <- "b";
        }
    }

    if(!is.null(xreg)){
        modelname <- "CESX";
    }
    else{
        modelname <- "CES";
    }
    modelname <- paste0(modelname,"(",seasonality,")");

    if(all(intermittent!=c("n","none"))){
        modelname <- paste0("i",modelname);
    }

    parametersNumber[1,4] <- sum(parametersNumber[1,1:3]);
    parametersNumber[2,4] <- sum(parametersNumber[2,1:3]);

    if(holdout){
        y.holdout <- ts(data[(obsInsample+1):obsAll],start=yForecastStart,frequency=datafreq);
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

##### Print output #####
    if(!silentText){
        if(any(abs(eigen(matF - vecg %*% matw)$values)>(1 + 1E-10))){
            if(bounds!="a"){
                warning("Unstable model was estimated! Use bounds='admissible' to address this issue!",call.=FALSE);
            }
            else{
                warning("Something went wrong in optimiser - unstable model was estimated! Please report this error to the maintainer.",
                        call.=FALSE);
            }
        }
    }

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
                  states=matvt,A=A$value,B=B$value,
                  initialType=initialType,initial=initialValue,
                  nParam=parametersNumber,
                  fitted=y.fit,forecast=y.for,lower=y.low,upper=y.high,residuals=errors,
                  errors=errors.mat,s2=s2,intervals=intervalsType,level=level,cumulative=cumulative,
                  actuals=data,holdout=y.holdout,imodel=imodel,
                  xreg=xreg,updateX=updateX,initialX=initialX,persistenceX=persistenceX,transitionX=transitionX,
                  ICs=ICs,logLik=logLik,cf=cfObjective,cfType=cfType,FI=FI,accuracy=errormeasures);
    return(structure(model,class="smooth"));
}
