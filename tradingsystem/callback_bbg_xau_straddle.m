function callback_bbg_xau_straddle(obj,event,c)

if isempty(obj.UserData)
    data = getdata(c,'xau curncy','px_last');
    strike = data.px_last;
    sec = struct('BloombergCode','xau curncy','ContractSize',5);
    notional = 1e6;
    straddle = cStraddle('underlier',sec,...
        'strike',strike,...
        'expirydate',dateadd(today,'3m'),...
        'tradedate',today,...
        'notional',notional);
    strat = cStrategySyntheticStraddle;
    strat = strat.addstraddle(straddle);
    tp = cTradingPlatform;
    userData = struct('Strategy',strat,...
        'TradingPlatform',tp,...
        'Instrument',sec);
    obj.UserData = userData;
end

ud = obj.UserData;

sec = ud.Instrument;
tp = ud.TradingPlatform;
strat = ud.Strategy;

time = event.Data.time;
data = getdata(c,sec.BloombergCode,{'bid','ask','px_last'});
underlierinfo = {struct('Instrument',sec,'Time',datenum(time),'Price',data.px_last)};
underliervol = {struct('Instrument',sec,'Vol',0.01)};

orders = strat.genorder('underlierinfo',underlierinfo,...
    'underliervol',underliervol,...
    'tradingplatform',tp);

for i = 1:length(orders)
    orders{i}.print;
    tradeid = length(tp.gettrades)+1;
    tp = tp.sendorder('order',orders{i},'tradeid',tradeid);
end

for i = 1:size(underlierinfo)
    pnl = tp.calcpnl(underlierinfo{i});
    tp.printpositions;
    fprintf('%s xau: %4.2f; pnl: %4.2f\n',datestr(time),data.px_last,pnl);
end

ud = struct('Strategy',strat,'TradingPlatform',tp,...
        'Instrument',sec);

obj.UserData = ud;




end