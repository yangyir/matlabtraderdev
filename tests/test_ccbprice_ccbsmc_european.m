%test_ccbprice_ccbsmc_european
clc;
fprintf('running test_ccbprice_ccbx_european.m......\n');
underlier = cContract('AssetName','gold','tenor','1712');
data = underlier.getTimeSeries('fields',{'close','volume'},'connection','bloomberg',...
    'datasource','local','fromdate','2016-07-28','todate','2016-07-28',...
    'frequency','1d');
close = data(1,2);
assetname = underlier.WindCode(1:end-4);

yc = CreateObj('cny','yieldcurve','valuationdate','2017-07-31','currency','cny');
%
mktdata = CreateObj('gold','mktdata','valuationdate','2017-07-31',...
    'currency','cny','assetname',assetname,'spot',1.0);
%
model = CreateObj('ccbsmc','model','modelname','ccbsmc');
%
vol = CreateObj('goldvol','vol','volname','marketvol','voltype','strikevol',...
    'assetname',assetname,'strikes',1.0,'expiries',today,'vols',0.12);

option1 = CreateObj('leg1','security','securityname','european',...
    'underlier',underlier,'assetname',assetname,...
    'strike',1.0,'issuedate','2017-07-28','expirydate','2017-08-28',...
    'referencespot',close,'optiontype','call','notional',1e7);

option2 = CreateObj('leg2','security','securityname','european',...
    'underlier',underlier,'assetname',assetname,...
    'strike',1.01,'issuedate','2017-07-28','expirydate','2017-08-28',...
    'referencespot',close,'optiontype','call','notional',-1e7);

book={option1;option2};

dictionary = CreateObj('dict_price','DICTIONARY',...
    'Mode','Price',...
    'YieldCurve',yc,...
    'MktData',mktdata,...
    'Vol',vol,...
    'Model',model,...
    'Book',book);

%price mode
res_pv = CCBPrice(dictionary);
fprintf(['total netvalue of the book:',num2str(round(res_pv.netvalue,2)),'.\n']);
%now change the extraresults to 1 to see detail pv info
model.ExtraResults = 1;
dictionary.Model = model;
res_pv_extraresults = CCBPrice(dictionary);
secNames = res_pv_extraresults.extraresults.Properties.RowNames;
prices = res_pv_extraresults.extraresults.price;
for i = 1:size(secNames,1)
    fprintf(['netvalue of ',secNames{i},':',num2str(round(prices(i),2)),'.\n']);
end
%
dictionary.Mode = 'SPOTGAMMA';
res_spotgamma = CCBPrice(dictionary);
spotdelta = res_spotgamma.spotdelta;
spotgamma = res_spotgamma.spotgamma;
fprintf('\n');
fprintf(['total spotdelta of the book:',num2str(round(spotdelta,2)),'.\n']);
fprintf(['total spotgamma of the book:',num2str(round(spotgamma,2)),'.\n']);
deltas = res_spotgamma.extraresults.spotdelta;
gammas = res_spotgamma.extraresults.spotgamma;
secNames = res_spotgamma.extraresults.Properties.RowNames;
for i = 1:size(secNames,1)
    fprintf(['delta of ',secNames{i},':',num2str(round(deltas(i),2)),...
        ' gamma of ',secNames{i},':',num2str(round(gammas(i),2)),'.\n']);
end
%
dictionary.Mode = 'SPOTTHETA';
res_spottheta = CCBPrice(dictionary);
spottheta = res_spottheta.spottheta;
fprintf('\n');
fprintf(['total spotdelta of the book:',num2str(round(spottheta,2)),'.\n']);
thetas = res_spottheta.extraresults.spottheta;

secNames = res_spottheta.extraresults.Properties.RowNames;
for i = 1:size(secNames,1)
    fprintf(['theta of ',secNames{i},':',num2str(round(thetas(i),2)),'.\n']);
end

fprintf('test done!\n');






