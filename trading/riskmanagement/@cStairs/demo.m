%%
db = cLocal;
intradaybar = db.intradaybar(code2instrument('T2003'),'2019-11-21','2019-11-21',15,'trade');


%%
trade = cTradeOpen('id',1,'code','T2003',...
    'opendatetime',datenum('2019-11-21 10:15:01'),'opendirection',-1,...
    'openvolume',1,'openprice',98.275);
signalinfo = struct('name','tdsq','frequency','15m');
trade.setsignalinfo('name','tdsq','extrainfo',signalinfo);
rm = cStairs;
rm.pxstoploss_ = 98.30;
rm.reserveratio_ = 1/3;
rm.trade_ = trade;
%
for i = 1:size(intradaybar,1)
    k = intradaybar(i,:);
    rm.riskmanagementwithcandle(k,'UpdatePnLForClosedTrade',true);
end
display(trade);






% t = gettradeopenbucket(trade,'15m');
% datestr(t)




