function [mdlEst,paramName,paramValue,paramStdev,paramTstats] = genericarimaestimate(y)
%
%1.use parcorr function (sample partial correlation) to determine the AR
[pacf,~,bounds] = parcorr(y);
checkAR = find(abs(pacf(2:end))>=abs(bounds(1)));
if isempty(checkAR)
    hasAR = false;
else
    hasAR = true;
    ARLags = min(checkAR);
end
%2.use autocorr function (sample autocorrelation) to determine the MA
[acf,~,bounds] = autocorr(y);
checkMA = find(abs(acf(2:end))>=abs(bounds(1)));
if isempty(checkMA)
    hasMA = false;
else
    hasMA = true;
    MALags = min(checkMA);
end
%3.use parcorr and autocorr to check whether conditional variance exists
[pacf,~,bounds] = parcorr(y.^2);
checkVarianceAR = find(abs(pacf(2:end))>=abs(bounds(1)), 1);
[acf,~,bounds] = autocorr(y.^2);
checkVarianceMA = find(abs(acf(2:end))>=abs(bounds(1)), 1);
if ~isempty(checkVarianceAR) || ~isempty(checkVarianceMA)
    hasConditionalVariance = true;
else
    hasConditionalVariance = false;
end
%
%
%specify AMRMA model to estimate the time series
if hasAR && hasMA && hasConditionalVariance
    mdl = arima('ARLags',ARLags,'MALags',MALags,'Variance',garch(1,1));
elseif hasAR && ~hasMA && hasConditionalVariance
    mdl = arima('ARLags',ARLags,'Variance',garch(1,1));
%     paramName = {'Constant';'AR';'GConstant';'GARCH';'ARCH'};
elseif hasAR && hasMA && ~hasConditionalVariance
    mdl = arima('ARLags',ARLags,'MALags',MALags);
%     paramName = {'Constant';'AR';'MA';'Varianece'};
elseif hasAR && ~hasMA && ~hasConditionalVariance
    mdl = arima('ARLags',ARLags);
%     paramName = {'Constant';'AR';'Variance'};
elseif ~hasAR && hasMA && hasConditionalVariance
    mdl = arima('MALags',MALags,'Variance',garch(1,1));
%     paramName = {'Constant';'MA';'GConstant';'GARCH';'ARCH'};
elseif ~hasAR && hasMA && ~hasConditionalVariance
    mdl = arima('MALags',MALags);
%     paramName = {'Constant';'MA';'Variance'};
elseif ~hasAR && ~hasMA && hasConditionalVariance
    mdl = arima('Variance',garch(1,1));
%     paramName = {'Constant';'GConstant';'GARCH';'ARCH'};
elseif ~hasAR && ~hasMA && ~hasConditionalVariance
    mdl = arima;
%     paramName = {'Constant';'Variance'};
end
[~,paramCovEst,~,infoEst] = estimate(mdl,y,'display','off');
paramValue = infoEst.X;
paramStdev = sqrt(diag(paramCovEst));
paramTstats = paramValue./paramStdev;
%0.05p value
paramTest = abs(paramTstats)>=1.96;

if hasConditionalVariance
    if paramTest(end-2) && paramTest(end-1) && paramTest(end)
        validGarch = true;
    else
        validGarch = false;
    end
else
    validGarch = false;
end

if hasAR && hasMA
    validAR = paramTest(2);
    validMA = paramTest(3); 
elseif ~hasAR && hasMA
    validAR = false;
    validMA = paramTest(2);
elseif hasAR && ~hasMA
    validAR = paramTest(2);
    validMA = false;
else
    validAR = false;
    validMA = false;
end
%
%recalibrate using the "right" statistical model
if validAR && validMA && validGarch
    mdl = arima('ARLags',ARLags,'MALags',MALags,'Variance',garch(1,1));
    paramName = {'Constant';'AR';'MA';'GConstant';'GARCH','ARCH'};
elseif validAR && ~validMA && validGarch
    mdl = arima('ARLags',ARLags,'Variance',garch(1,1));
    paramName = {'Constant';'AR';'GConstant';'GARCH';'ARCH'};
elseif validAR && validMA && ~validGarch
    mdl = arima('ARLags',ARLags,'MALags',MALags);
    paramName = {'Constant';'AR';'MA';'Varianece'};
elseif validAR && ~validMA && ~validGarch
    mdl = arima('ARLags',ARLags);
    paramName = {'Constant';'AR';'Variance'};
elseif ~validAR && validMA && validGarch
    mdl = arima('MALags',MALags,'Variance',garch(1,1));
    paramName = {'Constant';'MA';'GConstant';'GARCH';'ARCH'};
elseif ~validAR && validMA && ~validGarch
    mdl = arima('MALags',MALags);
    paramName = {'Constant';'MA';'Variance'};
elseif ~validAR && ~validMA && validGarch
    mdl = arima('Variance',garch(1,1));
    paramName = {'Constant';'GConstant';'GARCH';'ARCH'};
elseif ~validAR && ~validMA && ~validGarch
    mdl = arima;
    paramName = {'Constant';'Variance'};
end
[mdlEst,paramCovEst,~,infoEst] = estimate(mdl,y,'display','off');
nParam = size(paramCovEst,1);
paramValue = infoEst.X;
paramStdev = sqrt(diag(paramCovEst));
paramTstats = paramValue./paramStdev;

fprintf('model parameter info:\n')
for i = 1:nParam
    fprintf('\t%s:',paramName{i});
    fprintf('\t%4.4f;',paramValue(i));
    fprintf('\t%4.4f;',paramStdev(i));
    fprintf('\t%4.4f;',paramTstats(i));
    fprintf('\n');
end
