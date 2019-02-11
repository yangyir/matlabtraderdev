%%
% load all intraday candles from onedrive
% the intraday data is stored in 5min interval
ui_freq = 5;
dir_ = [getenv('BACKTEST'),'copper\'];
fn = ['copper_intraday_',num2str(ui_freq),'m'];
fldn = ['candles_',num2str(ui_freq),'m'];
data = load([dir_,fn]);
candles = data.(fldn);
dt1 = floor(candles{1,2}(1,1));
dt2 = floor(candles{end,2}(end,1));
bds = gendates('fromdate',dt1,'todate',dt2);
nbds = size(bds,1);

%%
pnls = cell(size(candles,1),1);
ui_wrmode = 'classic';
ui_nperiod = 100;
ui_overbought = 0;
ui_oversold = -100;
ui_stoplossratio = 0.3;

for ifut = 1:size(candles,1)
    candlek = candles{ifut,2};
    [trades,~] = bkfunc_gentrades_wlpr(candles{ifut,1},candlek,...
        'wrmode',ui_wrmode,...
        'nperiod',ui_nperiod,...
        'samplefrequency',[num2str(ui_freq),'m'],...
        'overbought',ui_overbought,...
        'oversold',ui_oversold);
     fprintf('%s:%d trades...\n',candles{ifut,1},trades.latest_);
     ntrades = trades.latest_;
     pnl2 = zeros(ntrades,1);%wrstrp pnl
     for itrade = 1:ntrades
        tradein2 = trades.node_(itrade).copy;
        [tradeout] = bkfunc_checksingletrade(tradein2,candlek,'WRWidth',10,'Print',0,...
            'OptionPremiumRatio',ui_stoplossratio,'DoPlot',0,'buffer',1);
        pnl2(itrade) = tradeout.closepnl_;
     end
     pnls{ifut} = pnl2;
end
pnlmat = cell2mat(pnls);
close all;
plot(cumsum(pnlmat));
sharpratio = sqrt(nbds)*mean(pnlmat)/std(pnlmat);
fprintf('sharp ratio:%4.2f\n',sharpratio);
fprintf('total pnl:%s\n',num2str(sum(pnlmat)));
