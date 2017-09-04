%%
% Create Interest Rate Spec
risklessRate = 0.03;
valDate = '2016-12-08';
endDate = dateadd(valDate,'1m');
rateSpec = intenvset('ValuationDate',valDate,'StartDates',valDate,...
    'EndDates',endDate,'Rates',risklessRate,'Compounding',-1,...
    'Basis',3);

%%
% Create Underlying Spec
% the futures is a synthetic forward that pays the dividend as the
% riskless interest rate
vol = 0.16;
assetPrice = 270;
divType = 'continuous';
divAmt = risklessRate;
underlyingSpec = stockspec(vol,assetPrice,divType,divAmt);

%%
% Create Time Spec
timeSpec = crrtimespec(valDate,endDate,6);

%%
% Create Cox-Ross-Rubinstein binomial tree
crrTree = crrtree(underlyingSpec,rateSpec,timeSpec);
%%
% Create European Option
strike = assetPrice*1.0;
optSpec = 'Call';
europeanCall = instoptstock(optSpec,strike,valDate,endDate);
%%
[pxEuropeanTree,pxEuropeanTreeInfo] = crrprice(crrTree,europeanCall);
%compare with BS price
pxEuropeanBS = optstockbybls(rateSpec,underlyingSpec,valDate,endDate,optSpec,strike);
%sanity check
df = rateSpec.Disc;
s = underlyingSpec.AssetPrice;
f = s*exp((risklessRate-divAmt)*rateSpec.EndTimes);
d1 = log(s/strike)+(risklessRate-divAmt+0.5*vol*vol)*rateSpec.EndTimes;
d1 = d1/(vol*sqrt(rateSpec.EndTimes));
d2 = d1-vol*sqrt(rateSpec.EndTimes);
pxEuropeanCheck = df*(f*normcdf(d1)-strike*normcdf(d2));
if abs(pxEuropeanBS-pxEuropeanCheck)>1e-5
    error('error')
end
pxEuropeanBS/assetPrice
%%
%check the converge of the CRR tree to the BS price
% points = 30:10:2000;
% timeSpecs = cell(length(points),1);
% pxPlot = zeros(length(points),1);
% for i = 1:length(points)
%     timeSpecs{i} = crrtimespec(valDate,endDate,points(i));
%     crrTree = crrtree(underlyingSpec,rateSpec,timeSpecs{i});
%     pxPlot(i) = crrprice(crrTree,europeanCall);
% end
% close all;
% plot(points,pxPlot,'b');
% hold on;
% plot(points,ones(length(points),1).*pxBS,'r');
%%
% Create Barrier Option
barrierSpec = 'uo';%up-out barrier
barrier = assetPrice*1.12;
americanOpt = 0;
barrierCall = instbarrier(optSpec,strike,valDate,endDate,americanOpt,barrierSpec,barrier);
[pxBarrier,pxBarrierTreeInfo] = crrprice(crrTree,barrierCall);
pxBarrier/assetPrice


%%
% Create equal probility tree
eqpTree = eqptree(underlyingSpec,rateSpec,timeSpec);
[pxBarrier2,pxBarrierTreeInfo2] = eqpprice(eqpTree,barrierCall);