%test_cTradingPlatform
%%
clc;

fprintf('\nrunning test_cTradingPlatform.m...\n');
tradingPlatform = cTradingPlatform;

%init two futures contract
au1612 = cContract('AssetName','gold','tenor','1612');
ag1612 = cContract('AssetName','silver','tenor','1612');

%init two orders, one to buy 10 lots of au1612 and the other the sell 80
%lots of ag1612
order1 = cOrder('OrderID','order1','Instrument',au1612,'direction','buy',...
    'offsetflag','open','price',280,'volume',10,'TraderID','yangyiran');
order2 = cOrder('OrderID','order2','Instrument',ag1612,'direction','sell',...
    'offsetflag','open','price',3900,'volume',80,'TraderID','yangyiran');
fprintf('initiate with two orders...\n');
order1.print;
order2.print;

%send order from the tradingPlatform
[tradingPlatform,trade1,order1] = tradingPlatform.sendorder('Order',order1,'TradeID','trade1');


%test of getorders function
orders_au1612 = tradingPlatform.getorders('Instrument',au1612);
if size(orders_au1612,1) ~= 1
    error('internal error!');
end

orders_au1612_sell = tradingPlatform.getorders('Instrument',au1612,'Direction','sell');
if size(orders_au1612_sell,1) ~= 0
    error('internal error!');
end

orders_au1612_close = tradingPlatform.getorders('Instrument',au1612,'offsetflag','close');
if size(orders_au1612_close,1) ~= 0
    error('internal error!');
end

orders_au1612_buyopen = tradingPlatform.getorders('Instrument',au1612,'direction','buy','offsetflag','open');
if size(orders_au1612_buyopen,1) ~= 1
    error('internal error!');
end

fprintf('\ncheck the status of the orders after sending them...\n');
% order1.print;
orders_au1612{1}.print;

tradingPlatform = tradingPlatform.sendorder('Order',order2,'TradeID','trade2');
orders_ag1612 = tradingPlatform.getorders('Instrument',ag1612);
orders_ag1612{1}.print;

%test of gettrades function
trades_au1612 = tradingPlatform.gettrades('Instrument',au1612);
if size(trades_au1612,1) ~= 1
    error('internal error!');
end

trades_au1612_sell = tradingPlatform.gettrades('Instrument',au1612,'Direction','sell');
if size(trades_au1612_sell,1) ~= 0
    error('internal error!');
end

trades_au1612_close = tradingPlatform.gettrades('Instrument',au1612,'offsetflag','close');
if size(trades_au1612_close,1) ~= 0
    error('internal error!');
end

trades_au1612_buyopen = tradingPlatform.gettrades('Instrument',au1612,'direction','buy','offsetflag','open');
if size(trades_au1612_buyopen,1) ~= 1
    error('internal error!');
end

%test of getposition function
fprintf('\nprint all existing positions...\n');
tradingPlatform.printpositions;
fprintf('\nprint all existing positions on au1612...\n');
tradingPlatform.printpositions('Instrument',au1612);
%
%%
%2.now create more orders to test the tradingflatform
fprintf('\ncreate more orders for further tests...\n');
%2.1
order3 = cOrder('OrderID','order3','Instrument',au1612,'direction','buy',...
    'offsetflag','open','price',281,'volume',5,'TraderID','yangyiran');
tradingPlatform = tradingPlatform.sendorder('Order',order3,'tradeID','trade3');
order4 = cOrder('OrderID','order4','Instrument',au1612,'direction','buy',...
    'offsetflag','open','price',282,'volume',3,'TraderID','yangyiran');
tradingPlatform = tradingPlatform.sendorder('Order',order4,'tradeID','trade4');
position_au1612 = tradingPlatform.getposition('Instrument',au1612);
avgpx = position_au1612.pPrice;
volume = position_au1612.pVolume;

trades = tradingPlatform.getorders('Instrument',au1612);
value = 0;
lots = 0;
for i = 1:size(trades)
    value = value + trades{i}.pPrice*trades{i}.pVolumeOriginal;
    lots = lots+trades{i}.pVolumeOriginal;
end
if avgpx ~= value/lots || volume ~= lots 
    error('internal error');
end

fprintf('\nprint all existing positions on au1612...\n');
tradingPlatform.printpositions('Instrument',au1612);

%2.2 some orders to close the postion
order5 = cOrder('OrderID','order5','Instrument',au1612,'direction','buy',...
    'offsetflag','close','price',285,'volume',10,'TraderID','yangyiran');

tradingPlatform = tradingPlatform.sendorder('Order',order5,'tradeID','trade5');
trades = tradingPlatform.gettrades('Instrument',au1612);
fprintf('\nprint all orders on au1612...\n');
for i = 1:size(trades,1)
    trades{i}.print;
end

fprintf('\nprint all existing positions...\n');
tradingPlatform.printpositions;

order6 = cOrder('OrderID','order5','Instrument',au1612,'direction','buy',...
    'offsetflag','close','price',287,'volume',9,'TraderID','yangyiran');
try
    tradingPlatform = tradingPlatform.sendorder('Order',order6,'TradeID','trade6');
catch me
    fprintf(['\nERROR:',me.message,'\n']);
    tradingPlatform.printpositions;
end


