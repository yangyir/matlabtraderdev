%%
% load table with rolling information of the selected asset
ui_assetname = 'nickel';
[ret,tbl] = bkfunc_loadrollinfotbl(ui_assetname);
%%
% choose a particular futures contract and download its intraday prices
% -------------------------- user inputs ---------------------------------%
ui_futcode = 'ni1901';
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
db = cLocal;
instrument = code2instrument(ui_futcode);
candlek = db.intradaybar(instrument,dt1,dt2,ui_freq,'trade');
%%
% generate trades with user inputs of wrmode and other inputs as required
% -------------------------- user inputs ---------------------------------%
ui_wrmode = 'classic';
ui_nperiod = 144;
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
for itrade = 1:ntrades
    tradein = trades.node_(itrade).copy;
    tradein.setriskmanager('name',ui_riskmanagername,'extrainfo',extrainfo);
    openbucket = gettradeopenbucket(tradein,tradein.opensignal_.frequency_);
    idxopen = find(candlek(:,1) == openbucket);
    for iprice = idxopen:size(candlek,1)
        candlein = candlek(iprice,:);
        unwindtrade = tradein.riskmanager_.riskmanagementwithcandle(candlein,...
            'usecandlelastonly',false,...
            'updatepnlforclosedtrade',true);
        if ~isempty(unwindtrade)
            fprintf('%s\n',num2str(unwindtrade.closepnl_));
            pnl(itrade) = unwindtrade.closepnl_;
            break
        end
    end
end
plot(cumsum(pnl));
 
    
    