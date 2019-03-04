%%
ui_freq = 5;
dir_ = [getenv('BACKTEST'),'copper\'];
fn = ['copper_intraday_',num2str(ui_freq),'m'];
data = load([dir_,fn]);
fldn = ['candles_',num2str(ui_freq),'m'];
candles = data.(fldn);
dt1 = floor(candles{1,2}(1,1));
dt2 = floor(candles{end,2}(end,1));
bds = gendates('fromdate',dt1,'todate',dt2);
nbds = size(bds,1);
nfuts = size(candles,1);
%%
nperiod = 100;
lead = 6;
lag = 24;

pnl = cell(nfuts,1);
for i = 1:nfuts
    futcode = candles{i,1};
    candlek = candles{i,2};
    [trades,~] = bkfunc_gentrades_wlprma(futcode,candlek,...
        'SampleFrequency',[num2str(ui_freq),'m'],...
        'NPeriod',nperiod,...
        'Lead',lead,...
        'Lag',lag);
    ntrades = trades.latest_;
    fprintf('%s:%d trades...\n',futcode,trades.latest_);
    pnl_i = zeros(ntrades,1);
    for itrade = 1:ntrades
        tradein2 = trades.node_(itrade).copy;
        [tradeout] = bkfunc_checksingletrade(tradein2,candlek,'WRWidth',10,'Print',0,...
            'OptionPremiumRatio',1,'stopratio',0,...
            'DoPlot',0,'buffer',1,'lead',lead,'lag',lag,...
            'UseDefaultFlashStopLoss',0);
        pnl_i(itrade) = tradeout.closepnl_;
    end
    pnl{i} = pnl_i;
end

for i = 1:nfuts
    sumpnl = sum(pnl{i});
    fprintf('%s:%8s\n',candles{i,1},num2str(sumpnl));
end
%
pnlmat = cell2mat(pnl);
figure(3);
plot(cumsum(pnlmat));
fprintf('total:%8s\n',num2str(sum(pnlmat)));
sharpratio = sqrt(nbds)*mean(pnlmat)/std(pnlmat);
fprintf('sharp rate:%4.2f\n',sharpratio);

%%
%check single instrument
clc;
fut2check = 'cu1811';
for i = 1:nfuts
    if strcmpi(candles{i,1},fut2check), break;end;
end
[trades,~] = bkfunc_gentrades_wlprma(fut2check,candles{i,2},...
        'SampleFrequency',[num2str(ui_freq),'m'],...
        'NPeriod',nperiod,...
        'Lead',lead,...
        'Lag',lag);

ntrades = trades.latest_;
fprintf('%s:%d trades...\n',fut2check,ntrades);
pnl2 = zeros(ntrades,1);
for itrade = 1:ntrades
    tradein2 = trades.node_(itrade).copy;
    [tradeout] = bkfunc_checksingletrade(tradein2,candles{i,2},'WRWidth',10,'Print',0,...
        'OptionPremiumRatio',1,'stopratio',0,...
        'DoPlot',0,'buffer',1,'lead',lead,'lag',lag,...
        'UseDefaultFlashStopLoss',0);
    pnl2(itrade) = tradeout.closepnl_;
end
figure(2);
plot(cumsum(pnl2),'r-');hold off;
fprintf('\n');
for itrade = 1:ntrades
    fprintf('%5s\n',num2str(pnl2(itrade)));
end
fprintf('%5s\n',num2str(sum(pnl2)));
%%
% check single trade
clc;
itrade = 40;
[tradeout] = bkfunc_checksingletrade(trades.node_(itrade),candles{i,2},'WRWidth',10,'Print',1,...
    'OptionPremiumRatio',1,'StopRatio',0,'buffer',1,'lead',lead,'lag',lag,'UseDefaultFlashStopLoss',0);
fprintf('%10s:%s\n','opentime',tradeout.opendatetime2_);
fprintf('%10s:%s\n','closetime',tradeout.closedatetime2_)
fprintf('%10s:%s\n','pnl',num2str(tradeout.closepnl_));
%%
bkfunc_checktrades(trades,candles{i,2},3);