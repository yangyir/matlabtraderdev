
%%
ui_freq = 15;
dir_ = [getenv('BACKTEST'),'copper\'];
fn = ['copper_intraday_',num2str(ui_freq),'m'];
data = load([dir_,fn]);
fldn = ['candles_',num2str(ui_freq),'m'];
candles = data.(fldn);
dt1 = floor(candles{1,2}(1,1));
dt2 = floor(candles{end,2}(end,1));
bds = gendates('fromdate',dt1,'todate',dt2);
nbds = size(bds,1);

%%
% choose a particular futures contract and download its intraday prices
% -------------------------- user inputs ---------------------------------%
ui_futcode = 'cu1808';
% ------------------------------------------------------------------------%
for i = 1:size(candles,1)
    if strcmpi(candles{i,1},ui_futcode),break;end
end
candlek = candles{i,2};
%%
% generate trades with user inputs of wrmode and other inputs as required
% -------------------------- user inputs ---------------------------------%
ui_wrmode = 'classic';
ui_nperiod = 200;
ui_overbought = -0.6;
ui_oversold = -99.4;
% ------------------------------------------------------------------------%
[trades,~] = bkfunc_gentrades_wlpr(ui_futcode,candlek,...
        'wrmode',ui_wrmode,...
        'nperiod',ui_nperiod,...
        'samplefrequency',[num2str(ui_freq),'m'],...
        'overbought',ui_overbought,...
        'oversold',ui_oversold);
fprintf('%s:%d trades...\n',ui_futcode,trades.latest_);    
%%
% backtest trades with selected risk management approach
% -------------------------- user inputs ---------------------------------%
ui_riskmanagername = 'batman';
ui_bandtarget = 0.2;
ui_bandstoploss = 0.05;
% ------------------------------------------------------------------------%
extrainfo = struct('bandstoploss_',ui_bandstoploss,...
    'bandtarget_',ui_bandtarget);
ntrades = trades.latest_;
pnl = zeros(ntrades,1);
pnl2 = zeros(ntrades,1);
for itrade = 1:ntrades
    tradein = trades.node_(itrade).copy;
    tradein2 = trades.node_(itrade).copy;
    tradein.setriskmanager('name',ui_riskmanagername,'extrainfo',extrainfo);
    openbucket = gettradeopenbucket(tradein,tradein.opensignal_.frequency_);
    idxopen = find(candlek(:,1) == openbucket);
    for iprice = idxopen:size(candlek,1)
        candlein = candlek(iprice,:);
        unwindtrade = tradein.riskmanager_.riskmanagementwithcandle(candlein,...
            'usecandlelastonly',false,...
            'updatepnlforclosedtrade',true);
        if ~isempty(unwindtrade)
            pnl(itrade) = unwindtrade.closepnl_;
            break
        end
    end
    [tradeout] = bkfunc_checksingletrade(tradein2,candlek,'WRWidth',10,'Print',0,...
        'OptionPremiumRatio',0.3,'DoPlot',0,'buffer',1);
    pnl2(itrade) = tradeout.closepnl_;
end
figure(2);
plot(cumsum(pnl));hold on;
plot(cumsum(pnl2),'r-');hold off;
legend('batman','wrstep');
fprintf('\n');
for itrade = 1:ntrades
    fprintf('%5s\t%5s\n',num2str(pnl(itrade)),num2str(pnl2(itrade)));
end
fprintf('%5s\t%5s\n',num2str(sum(pnl)),num2str(sum(pnl2)));
%
bkfunc_checktrades(trades,candlek,3);
%%
itrade = 5;
[tradeout] = bkfunc_checksingletrade(trades.node_(itrade),candlek,'WRWidth',10,'Print',1,...
    'OptionPremiumRatio',0.3,'StopRatio',0,'buffer',1);
fprintf('%s\n',num2str(tradeout.closepnl_));
 
    
    