%%
% load all intraday candles from onedrive
% the intraday data is stored in 5min interval
ui_freq = 5;
dir_ = [getenv('BACKTEST'),'copper\'];
fn = 'copper_intraday';
data = load([dir_,fn]);
candles = data.candles;
%%
ui_futcode = 'cu1903';
for i = 1:size(candles,1)
    if strcmpi(candles{i,1},ui_futcode),break;end
end
ui_nperiod = 100;
ui_overbought = 0;
ui_oversold = -100;

candlek = candles{i,2};
[trades,~] = bkfunc_gentrades_wlpr(candles{i,1},candlek,...
    'wrmode','classic',...
    'nperiod',ui_nperiod,...
    'samplefrequency',[num2str(ui_freq),'m'],...
    'overbought',ui_overbought,...
    'oversold',ui_oversold);
fprintf('%s:%d trades...\n',ui_futcode,trades.latest_);
%%
% backtest trades with selected risk management approach
% -------------------------- user inputs ---------------------------------%
ui_riskmanagername = 'wrstep';
ui_stoplossratio = 0.3;
% ------------------------------------------------------------------------%
ntrades = trades.latest_;
pnl1 = zeros(ntrades,1);%pnl calculated with bkfunc_checksingletrade function
pxstoploss = zeros(ntrades,1);
trades1 = cTradeOpenArray;
for itrade = 1:ntrades
    tradein1 = trades.node_(itrade).copy;
    [tradeout1,pxstoploss(itrade)] = bkfunc_checksingletrade(tradein1,candlek,...
        'WRWidth',10,'Print',0,...
        'OptionPremiumRatio',ui_stoplossratio,'DoPlot',0,'buffer',1);
    pnl1(itrade) = tradeout1.closepnl_;
    trades1.push(tradeout1);
end
%%
wlpr = willpctr(candlek(:,3),candlek(:,4),candlek(:,5),ui_nperiod);
pnl2 = zeros(ntrades,1);
trades2 = cTradeOpenArray;
for itrade = 1:ntrades
    tradein2 = trades.node_(itrade).copy;
    extrainfo = struct('pxstoploss_',pxstoploss(itrade),'stepvalue_',10);
    tradein2.setriskmanager('name',ui_riskmanagername,'extrainfo',extrainfo);
    openbucket = gettradeopenbucket(tradein2,tradein2.opensignal_.frequency_);
    idxopen = find(candlek(:,1) == openbucket);
    for iprice = idxopen:size(candlek,1)
        candlein = candlek(iprice,:);
        tradeout2 = tradein2.riskmanager_.riskmanagementwithcandle(candlein,wlpr(iprice),...
            'usecandlelastonly',false,'debug',false,...
            'updatepnlforclosedtrade',true);
        if ~isempty(tradeout2)
            if isempty(tradeout2.closeprice_)
                closeprice = candlek(iprice+1,2);
                closetime = candlek(iprice+1,1);
                tradeout2.runningpnl_ = 0;
                tradeout2.closepnl_ = tradeout2.opendirection_*tradeout2.openvolume_*(closeprice-tradeout2.openprice_)/ tradeout2.instrument_.tick_size * tradeout2.instrument_.tick_value;
                tradeout2.closedatetime1_ = closetime;
            end
            pnl2(itrade) = tradeout2.closepnl_;
            trades2.push(tradeout2);
            break
        else
            pnl2(itrade) = tradein2.runningpnl_;
        end
    end
    if isempty(tradeout2), trades2.push(tradein2);end
    
end
%%
fprintf('regession riskmanagement wrsteps successfully done...\n');
%note:some differences seen below is due to different operation on close
%price, i.e. 'bkfunc_checksingletrade' use the open price on next candle
%whereas 'riskmanager' use the close price of the candle

%         -200        -200           0
%         -200        -200           0
%         -150        -150           0
%         -450        -450           0
%         -250        -250           0
%         6150        6150           0
%         -350        -350           0
%         -150        -150           0
%         -200        -200           0
%          700         700           0
%         -100         100        -200
%         -150        -150           0
%         -150        -150           0
%         3650        3650           0
%            0           0           0
%         -150        -150           0
%         -200        -200           0
%         -200        -200           0
%         -200        -200           0
%         -200        -200           0
%         -200        -200           0
%         -150        -150           0
%         -150        -150           0
%         -150        -150           0
%         -200        -200           0
%          -50        -100          50
%            0         -50          50
%         1450        1450           0