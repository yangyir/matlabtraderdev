%%
freq = 5;
nperiod = 97;
lead = 6;
lag = 24;
%
[pnlcell,pnlmat,sharpratio,maxdrawdown,maxdrawdownpct] = bkfunc_wrma_copper( 'SampleFrequency',[num2str(freq),'m'],...
        'NPeriod',nperiod,...
        'Lead',lead,...
        'Lag',lag);
figure(1);
plot(cumsum(pnlmat));
fprintf('total pnl:%8s\n',num2str(sum(pnlmat)));
fprintf('sharp rate:%4.2f\n',sharpratio);
fprintf('max drawdown:%s\n',num2str(maxdrawdown));
fprintf('max drawdownpct:%4.1f%%\n',100*maxdrawdownpct);
pnlmat2 = zeros(size(pnlcell,1),1);
for i = 1:size(pnlcell,1),pnlmat2(i) = sum(pnlcell{i});end
%%
%check single instrument
nperiod = 97;
clc;
fut2check = 'cu1904';
dir_ = [getenv('BACKTEST'),'copper\'];
fn = ['copper_intraday_',num2str(freq),'m'];
data = load([dir_,fn]);
fldn = ['candles_',num2str(freq),'m'];
candles = data.(fldn);
for i = 1:size(candles,1)
    if strcmpi(candles{i,1},fut2check), break;end;
end
[trades,~] = bkfunc_gentrades_wlprma(fut2check,candles{i,2},...
        'SampleFrequency',[num2str(freq),'m'],...
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
fprintf('total:%5s\n',num2str(sum(pnl2)));
%%
% check single trade
clc;
itrade = 3;
[tradeout] = bkfunc_checksingletrade(trades.node_(itrade),candles{i,2},'WRWidth',10,'Print',1,...
    'OptionPremiumRatio',1,'StopRatio',0,'buffer',1,'lead',lead,'lag',lag,'UseDefaultFlashStopLoss',0);
fprintf('%10s:%s\n','opentime',tradeout.opendatetime2_);
fprintf('%10s:%s\n','closetime',tradeout.closedatetime2_)
fprintf('%10s:%s\n','pnl',num2str(tradeout.closepnl_));
%%
bkfunc_checktrades(trades,candles{i,2},3);