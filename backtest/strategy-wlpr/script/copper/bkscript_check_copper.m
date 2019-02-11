%%
% load table with rolling information of the selected asset
db = cLocal;
ui_assetname = 'copper';
[ret,tbl] = bkfunc_loadrollinfotbl(ui_assetname);
%%
% list futures of interest 
ui_freq = 5;
ui_futlist = {'cu1709';'cu1710';'cu1711';'cu1712';...
    'cu1801';'cu1802';'cu1803';'cu1804';'cu1805';'cu1806';'cu1807';'cu1808';'cu1809';'cu1810';'cu1811';'cu1812';...
    'cu1901';'cu1902';'cu1903'};
nfut = size(ui_futlist,1);
candles = cell(nfut,1);
for ifut = 1:nfut
    fut = ui_futlist{ifut};
    for j = 1:size(tbl,1)
        if strcmpi(tbl{j,5},fut),break;end
    end
    rolldtnum = tbl{j,1};
    nbshift = wrfreq2busdayshift(ui_freq);
    dt1 = dateadd(rolldtnum,['-',num2str(nbshift),'b']);
    dt1 = datestr(dt1,'yyyy-mm-dd');
    if j ~= size(tbl,1)
        dt2 = datestr(tbl{j+1,1},'yyyy-mm-dd');
    else
        dt2 = datestr(getlastbusinessdate,'yyyy-mm-dd');
    end
    instrument = code2instrument(fut);
    candles{ifut} = db.intradaybar(instrument,dt1,dt2,ui_freq,'trade');
end
%%
dir_ = 'C:\Users\Administrator\OneDrive\backtest\copper\';
if ui_freq == 5
    fn = [ui_assetname,'_intraday'];
elseif ui_freq == 15
    fn = [ui_assetname,'_15m_intraday'];
end
save([dir_,fn],'candles');

%%
% choose a particular futures contract and download its intraday prices
% -------------------------- user inputs ---------------------------------%
ui_futcode = 'cu1903';
ui_freq = 5;
% ------------------------------------------------------------------------%
for i = 1:size(tbl,1)
    if strcmpi(tbl{i,5},ui_futcode),break;end
end
rolldtnum = tbl{i,1};
nbshift = wrfreq2busdayshift(ui_freq);
dt1 = dateadd(rolldtnum,['-',num2str(nbshift),'b']);
dt1 = datestr(dt1,'yyyy-mm-dd');
if i ~= size(tbl,1)
    dt2 = datestr(tbl{i+1,1},'yyyy-mm-dd');
else
    dt2 = datestr(getlastbusinessdate,'yyyy-mm-dd');
end

instrument = code2instrument(ui_futcode);
candlek = db.intradaybar(instrument,dt1,dt2,ui_freq,'trade');
%%
% generate trades with user inputs of wrmode and other inputs as required
% -------------------------- user inputs ---------------------------------%
ui_wrmode = 'classic';
ui_nperiod = 100;
ui_overbought = 0;
ui_oversold = -100;
% ------------------------------------------------------------------------%
[trades,~] = bkfunc_gentrades_wlpr(ui_futcode,candlek,...
        'wrmode',ui_wrmode,...
        'nperiod',ui_nperiod,...
        'samplefrequency',[num2str(ui_freq),'m'],...
        'overbought',ui_overbought,...
        'oversold',ui_oversold);
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
        'OptionPremiumRatio',0.6,'DoPlot',0,'buffer',1);
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
%
bkfunc_checktrades(trades,candlek,3);
%%
itrade = 18;
[tradeout] = bkfunc_checksingletrade(trades.node_(itrade),candlek,'WRWidth',10,'Print',1,...
    'OptionPremiumRatio',0.6,'StopRatio',0,'buffer',1);
fprintf('%s\n',num2str(tradeout.closepnl_));
 
    
    