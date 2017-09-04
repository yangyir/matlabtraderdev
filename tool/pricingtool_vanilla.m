function [results,book] = pricingtool_vanilla(varargin)
%
clc;
flag = input('use existing vanilla structure for pricing?(YES=1/NO=0): ');

if flag == 1
    if isempty(varargin)
        error('pricingtool_vanilla:existing vanilla struture is missing!');
    end
    book = varargin{1};
    n = size(book,1);
else
    assetname = input('pls type in the underlying asset of your vanilla struture: ');
    tenor = input('pls type in the contract year and month of the underlying asset, for example 1612: ');
    futures = cContract('AssetName',assetname,'Tenor',num2str(tenor));
    n = input('how many option legs in your vanilla structure: ');
    strikes = zeros(1,n);
    expiries = zeros(n,1);
    optiontype = cell(n,1);
    notional = zeros(n,1);
    book = cell(n,1);
end

runladder = input('run spot ladder for vanilla structure?(YES=1/NO=0): ');

vols = zeros(1,n);
rownames = cell(n,1);

for i = 1:n
    fprintf(['pls set-up elements of leg',num2str(i),'...\n']);
    if flag == 0
        strikes(i) = input('strike: ');
        datetenor = input('expiry: ');
        try
            expiries(i) = datenum(datetenor);
        catch
            expiries(i) = dateadd(today,datetenor,1);
        end
        
        optiontype{i} = input('option type: ');
        if ~(strcmpi(optiontype{i},'c') || ...
                strcmpi(optiontype{i},'p') || ...
                strcmpi(optiontype{i},'call') || ...
                strcmpi(optiontype{i},'put'))
            error('invalid option type!')
        end
        notional(i) = input('notional: ');
    end
    vols(i) = input('volatility: ');
    handle = ['leg',num2str(i)];
    rownames{i} = handle;
    if flag == 0
        book{i} = CreateObj(handle,'security','securityname','european',...
            'issuedate',today,'expirydate',expiries(i),...
            'strike',strikes(i),'notional',notional(i),...
            'optiontype',optiontype{i},'underlier',futures);
    else
        strikes(i) = book{i}.Strike;
        expiries(i) = datenum(book{i}.ExpiryDate);
    end
end

%sanity check for option expiry inputs
if n > 1
    T = expiries(1);
    for i = 2:n
        if expiries(i) ~= T
            error('calendar structure not implemented yet');
        end
    end
else
    T = expiries(1);
end

%sanity check for volatility inputs
k = unique(strikes);
sigma = unique(vols);
if isscalar(sigma)  && ~isscalar(k)
    sigma = sigma*ones(1,length(k));
elseif ~isscalar(sigma) && ~isscalar(k)
    if length(sigma) > length(k)
        error('invalid volatility inputs');
    end
end

refspot = 1.0;

marketvol = CreateObj('vol','vol','volname','marketvol',...
    'voltype','strikevol','assetname',book{1}.AssetName,...
    'interpolationmethod','next',...'
    'referencespot',refspot,...
    'strikes',k,...
    'expiries',T,...
    'vols',sigma);

yc = CreateObj('CNY','yieldcurve','valuationdate',today,'currency','CNY');

mktdata = CreateObj([book{1}.AssetName,'_mktdata'],'mktdata','valuationdate',...
    today,'currency','CNY','assetname',book{1}.AssetName,'spot',refspot);

model = CreateObj('ccbsmc','model','modelname','ccbsmc','extraresults',1);

dictionary = CreateObj('dict','dictionary',...
    'yieldcurve',yc,...
    'mktdata',mktdata,...
    'vol',marketvol,...
    'model',model,...
    'book',book,...
    'mode','spotgamma');

res = CCBPrice(dictionary);
netvalue = res.extraresults.price;
delta = res.extraresults.spotdelta;
gamma = res.extraresults.spotgamma;

dictionary.Mode = 'spottheta';
res = CCBPrice(dictionary);
theta = res.extraresults.spottheta;

carrydate = businessdate(yc.ValuationDate,1);
ycdecay = yc.DecayYieldCurve('decaydate',carrydate);
mktdatadecay = mktdata.DecayMktData('decaydate',carrydate);

dictionarydecay = CreateObj('dictdecay','dictionary',...
    'yieldcurve',ycdecay,...
    'mktdata',mktdatadecay,...
    'vol',marketvol,...
    'model',model,...
    'book',book,...
    'mode','spotgamma');

res = CCBPrice(dictionarydecay);
carrydelta = res.extraresults.spotdelta;
carrygamma = res.extraresults.spotgamma;

results = table(netvalue,delta,gamma,theta,carrydelta,carrygamma,'rownames',rownames);

%additional ladder compulation
if runladder
    spots = 0.85:0.005:1.15;
    ladder_pv = zeros(1,length(spots));
    ladder_delta = ladder_pv;
    ladder_gamma = ladder_pv;

    dictionary.Mode = 'spotgamma';
    for i = 1:length(spots)
        mktdata.Spot = spots(i);
        dictionary = CreateObj('dict','dictionary',...
            'yieldcurve',yc,...
            'mktdata',mktdata,...
            'vol',marketvol,...
            'model',model,...
            'book',book,...
            'mode','spotgamma');
        res_i = CCBPrice(dictionary);
        ladder_pv(i) = res_i.netvalue;
        ladder_delta(i) = res_i.spotdelta;
        ladder_gamma(i) = res_i.spotgamma;
    end
    
    close all;
    figure(1);
    plot(spots,ladder_pv);title('pv ladder');xlabel('spot');
    figure(2);
    plot(spots,ladder_delta);title('delta ladder');xlabel('spot');
    figure(3);
    plot(spots,ladder_gamma);title('gamma ladder');xlabel('spot');
end



    




clear i n assetname tenor strikes expiries optiontype notional underlier answer
clear handle
end
