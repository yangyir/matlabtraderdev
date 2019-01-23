assetname = 'deformed bar';
[rollinfo,pxoidata] = bkfunc_genfutrollinfo(assetname);
%%
freq = 5;
[res] = bkfunc_loadintradaydata2(assetname,rollinfo,'frequency',freq,...
    'StartDate','2017-08-08',...
    'EndDate','2017-11-08',...
    'DaysShift',-10);
%%
pricedata = res.pricedata;
for i = 1:size(pricedata,1)
    fprintf('%s\tdt1:%s\tdt2:%s\n',pricedata{i}.codectp,pricedata{i}.dt1str,pricedata{i}.dt2str);
end
%%
clc;
wrmode = 'classic';
pnl = zeros(size(pricedata,1),1);
alltrades = cTradeOpenArray;
% buckets = pnl;
nbds = 0;
for i = 1:size(pricedata,1)
    nbds = nbds+length(unique(floor(pricedata{i}.data(:,1))));
    [trades,~] = bkfunc_gentrades_wlpr(pricedata{i}.codectp,pricedata{i}.data,...
        'wrmode',wrmode,...
        'nperiod',144,...
        'samplefrequency',[num2str(freq),'m'],...
        'overbought',-0,...
        'oversold',-100);
    %filter out trades which are traded in inactive period of the contract
    if i > 1
        ntrades_i = 0;
        for j = 1:trades.latest_
            if trades.node_(j).opendatetime1_ >= res.rollinfotable{i-1,1}
                ntrades_i = ntrades_i + 1;
            end
        end
    else
        ntrades_i = trades.latest_;
    end
    
    fprintf('%s:numberoftrades:%d\n',pricedata{i}.codectp,ntrades_i);
    if ntrades_i > 0
        bkfunc_checktrades(trades,pricedata{i}.data)
    end
    %
    
    for j = 1:trades.latest_
        if i > 1 && trades.node_(j).opendatetime1_ < res.rollinfotable{i-1,1}, continue;end
        tradeout = bkfunc_checksingletrade(trades.node_(j),pricedata{i}.data,'doplot',1,...
            'riskmanagement','OptionPlusWR',...
            'OptionPremiumRatio',0.333,...
            'UseDefaultFlashStopLoss',1,...
            'WRWidth',25);
        fprintf('\ttrade %2s pnl:%6s\n',num2str(j),num2str(tradeout.closepnl_));
        pnl(i) = pnl(i) + tradeout.closepnl_;
        alltrades.push(tradeout);
    end
    fprintf('\tsubtotal pnl:%6s\n',num2str(pnl(i)));
end
fprintf('TOTAL PnL:%6s\n',num2str(sum(pnl)));
%
ntotaltrades = alltrades.latest_;
tradelevelpnl = zeros(ntotaltrades,1);
for itrade = 1:ntotaltrades
    tradelevelpnl(itrade) = alltrades.node_(itrade).closepnl_;
end
figure(2);
plot(cumsum(tradelevelpnl));
sharp = sqrt(nbds)*mean(tradelevelpnl)/std(tradelevelpnl);
title([assetname,'->',num2str(sharp)]);
xlabel('number of trades');
ylabel('cumulative pnl');

%%
i = 1;
[trades,px_used] = bkfunc_gentrades_wlpr(pricedata{i}.codectp,pricedata{i}.data,...
        'wrmode',wrmode,...
        'nperiod',144,...
        'samplefrequency',[num2str(freq),'m'],...
        'overbought',-0,...
        'oversold',-100);
if i > 1
    ntrades_i = 0;
    for j = 1:trades.latest_
        if trades.node_(j).opendatetime1_ >= res.rollinfotable{i-1,1}
            ntrades_i = ntrades_i + 1;
        end
    end
else
    ntrades_i = trades.latest_;
end    
tbl = zeros(ntrades_i,4);
count = 0;
for j = 1:trades.latest_
    if i > 1 && trades.node_(j).opendatetime1_ < res.rollinfotable{i-1,1}, continue;end
    count = count+1;
    tbl(count,1) = trades.node_(j).opendatetime1_;
    tbl(count,2) = trades.node_(j).opendirection_;
    tbl(count,3) = trades.node_(j).openprice_;
    if tbl(count,2) == 1
        tbl(count,4) = trades.node_(j).opensignal_.lowestlow_;
    else
        tbl(count,4) = trades.node_(j).opensignal_.highesthigh_;
    end
end
%%
clc;
j=3;
tradeout = bkfunc_checksingletrade(trades.node_(j),pricedata{i}.data,'doplot',1,...
            'riskmanagement','OptionPlusWR',...
            'OptionPremiumRatio',0.333,...
            'UseDefaultFlashStopLoss',1,...
            'Print',1,...
            'WRWidth',20);
fprintf('%s\n',num2str(tradeout.closepnl_));
%%
tradein = trades.node_(j);
if tradein.opendirection_ == -1
    pxstop = tradein.opensignal_.highesthigh_;
else
    pxstop = tradein.opensignal_.lowestlow_;
end
extrainfo = struct('pxstoploss_',pxstop);
tradein.setriskmanager('name','wrstep','extrainfo',extrainfo);
candlek = pricedata{i}.data;
nperiod = tradein.opensignal_.lengthofperiod_;
wlpr = willpctr(candlek(:,3),candlek(:,4),candlek(:,5),nperiod);
%%
tradein.status_ = 'unset';
tradein.riskmanager_.status_ = 'unset';
for k = 1:size(wlpr,1)
    [tradeout2] = tradein.riskmanager_.riskmanagementwithcandle(candlek(k,:),wlpr(k,:),...
        'UseCandleLastOnly',false,...
        'UpdatePnLForClosedTrade',true,...
        'Debug',true);
    if ~isempty(tradeout2)
        break
    end
end




