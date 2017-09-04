%%
% --- user inputs
strike = 1;
futuresPrice = 1;
sigma = 0.23;
rates = 0.04;
settle = today;
maturity = dateadd(today,'3m');
optSpec = {'put'};

%futures underlying assuming paying the fixed dividend as of the rates
%yield curve
divType = {'continuous'};
divAmount = rates;

% --- define the rateSpec and stockSpec
rateSpec = intenvset('ValuationDate',settle,'StartDates',settle,...
    'EndDates',maturity,'Rates',rates,'Compounding',-1,...
    'Basis',basis2num('ACT/365'));
stockSpec = stockspec(sigma,futuresPrice,divType,divAmount);

notional = 3.2e7;
marginRate = 0.1;

%%
% --- price vanilla european option using black model
outSpec = {'Price','Delta'};
[pxEuropeanBlack,deltaEuropeanBlack] = optstocksensbybls(rateSpec,stockSpec,settle,maturity,...
    optSpec,strike,'OutSpec',outSpec);
premiumEuropeanBlack = pxEuropeanBlack*notional;
cashDeltaEuropeanBlack = deltaEuropeanBlack*notional;
cashMargin = marginRate*cashDeltaEuropeanBlack;



%%
% --- price option using CRR tree model
% runCheck = false;
% if runCheck
%     n = 10:5:365;
%     timeSpecs = cell(length(n),1);
%     CRRTrees = cell(length(n),1);
%     pxCheck = zeros(length(n),1);
%     for i = 1:length(n)
%         timeSpecs{i} = crrtimespec(settle,maturity,n(i));
%         CRRTrees{i} = crrtree(stockSpec,rateSpec,timeSpecs{i});
%         pxCheck(i) = optstockbycrr(CRRTrees{i},optSpec,strike,settle,maturity,0);
%     end
%     plot(n,pxEuropeanBlack*ones(length(n),1),'b');
%     hold on;
%     plot(n,pxCheck,'color',[0.7 0.7 0.7]);
%     hold off;
% end
% 
timeSpec = crrtimespec(settle,maturity,60);
CRRTree = crrtree(stockSpec,rateSpec,timeSpec);

pxEuropeanCRR = optstockbycrr(CRRTree,optSpec,strike,settle,maturity,0);
% --- American option
pxAmericanCRR = optstockbycrr(CRRTree,optSpec,strike,settle,maturity,1);

% --- Bermuda option
% exerciseDatesBerm = {'05-May-2017','05-Jun-2017','05-Jul-2017'};
% pxBermudaCRR = optstockbycrr(CRRTree,optSpec,strike,settle,exerciseDatesBerm);

% --- price option using Longstaff-Schwartz model
numPeriods = datenum(maturity)-datenum(settle)+1;
numTrials = 50000;
rng(100);
Z = randn(numPeriods,1,numTrials);
pxEuropeanLS = optstockbyls(rateSpec,stockSpec,optSpec,strike,settle,...
    maturity,'Antithetic',true,'NumTrials',numTrials,'Z',Z,...
    'NumPeriods',numPeriods);

[pxAmericanLS,path] = optstockbyls(rateSpec,stockSpec,optSpec,strike,settle,...
    maturity,'AmericanOpt',1,...
    'Antithetic',true,'NumTrials',numTrials,'Z',Z);

% 
% 
