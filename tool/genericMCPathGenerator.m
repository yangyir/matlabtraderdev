function [paths] = genericMCPathGenerator(mktdata,yc,expiry,vol,model,varargin)
%generic Monte-Carlo path generator
%
%1.transform yieldcurve object to ratespec object
settle = yc.ValuationDate;
rates = yc.ZeroRate(expiry);
compounding = yc.Compounding;
basis = yc.DiscountBasis;
rateSpec = intenvset('valuationdate',settle,'statedates',settle,...
    'enddates',expiry,'rates',rates,...
    'compounding',compounding,'basis',basis);
%
%2.transform mktdata and vol object to stockspec object
if ~strcmpi(mktdata.Type,'FORWARD')
    error('genericMCPathGenerator:invalid mktdata type!')
end
divType = {'continuous'};
divAmount = rates;
assetSpec = stockspec(vol.getVol,mktdata.Spot,divType,divAmount);







 optstockbyls(rateSpec,stockSpec,optSpec,strike,settle,expiry,...
    'AmericanOpt',1,...
    'NumTrials',numTrials,...
    'Antithetic',true,...
    'Z',Z);

blsdelta(sims_i(j),strike,rates,tCarry,sigma,divAmount);


%%
rates = 4.5/100;
expiry = [today,dateadd(today,'4m')];
irdc = IRDataCurve('zero',today,expiry,[rates,rates],'compounding',-1,'basis',3);

yc = CreateObj('cny','yieldcurve','valuationdate',today,'dates',expiry,'rates',[rates,rates]);

contract = cContract('assetname','soybean','tenor','1801');
data = getdata(conn,contract.BloombergCode,'last_trade');
spot = data.last_trade;

mktdata = CreateObj('soybeanmktdata','mktdata','valuationdate',today,...
    'currency','cny','assetname','soybean','spot',spot);

lv = 17.3/100;
vol = CreateObj('soybeanvol','vol','volname','localvol','voltype','flatvol',...
    'assetname','soybean','flatvol',lv);

model = CreateObj('ccbx','model','modelname','ccbx',...
    'variancereduction','antithetic');

