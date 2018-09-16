clc;
trades = cTradeOpenArray;
batman_extrainfo = struct('bandstoploss',0.01,'bandtarget',0.02);
code1 = 'ni1811';
extrainfo1 = struct('frequency','3m','lengthofperiod',144,'highesthigh',12000,'lowestlow',11090);
trade1 = cTradeOpen('id','trade1','counter','citic_kim_fut','book','bookdemo','code',code1,'opendatetime',datenum('2018-08-03 09:00:01'),'openvolume',1,'openprice',11090,'opendirection',1);trade1.status_ = 'set';
trade1.setsignalinfo('name','williamsr','extrainfo',extrainfo1);trade1.setriskmanager('name','batman','extrainfo',batman_extrainfo);
trades.push(trade1);
trade2 = cTradeOpen('id','trade2','counter','citic_kim_fut','book','bookdemo','code',code1,'opendatetime',datenum('2018-08-03 09:00:02'),'openvolume',1,'openprice',11070,'opendirection',1);trade2.status_ = 'set';
trade2.setsignalinfo('name','williamsr','extrainfo',extrainfo1);trade2.setriskmanager('name','batman','extrainfo',batman_extrainfo);
trades.push(trade2);
trade3 = cTradeOpen('id','trade3','counter','citic_kim_fut','book','bookdemo','code',code1,'opendatetime',datenum('2018-08-03 09:00:03'),'openvolume',1,'openprice',11040,'opendirection',1);trade3.status_ = 'set';
trade3.setsignalinfo('name','williamsr','extrainfo',extrainfo1);trade3.setriskmanager('name','batman','extrainfo',batman_extrainfo);
trades.push(trade3);
trade4 = cTradeOpen('id','trade4','counter','citic_kim_fut','book','bookdemo','code',code1,'opendatetime',datenum('2018-08-03 09:00:04'),'openvolume',1,'openprice',11000,'opendirection',1);trade4.status_ = 'set';
trade4.setsignalinfo('name','williamsr','extrainfo',extrainfo1);trade4.setriskmanager('name','batman','extrainfo',batman_extrainfo);
trades.push(trade4);
trade5 = cTradeOpen('id','trade5','counter','citic_kim_fut','book','bookdemo','code',code1,'opendatetime',datenum('2018-08-03 09:00:05'),'openvolume',1,'openprice',10090,'opendirection',1);trade5.status_ = 'set';
trade5.setsignalinfo('name','williamsr','extrainfo',extrainfo1);trade5.setriskmanager('name','batman','extrainfo',batman_extrainfo);
trades.push(trade5);

positions = trades.convert2positions;
positions{1}.print;

code2 = 'rb1810';
extrainfo2 = struct('frequency','3m','lengthofperiod',144,'highesthigh',4081,'lowestlow',4800);
trade6 = cTradeOpen('id','trade6','counter','citic_kim_fut','book','bookdemo','code',code2,'opendatetime',datenum('2018-08-03 09:00:11'),'openvolume',1,'openprice',4081,'opendirection',-1);trade6.status_ = 'set';
trade6.setsignalinfo('name','williamsr','extrainfo',extrainfo2);trade6.setriskmanager('name','batman','extrainfo',batman_extrainfo);
trades.push(trade6);
trade7 = cTradeOpen('id','trade7','counter','citic_kim_fut','book','bookdemo','code',code2,'opendatetime',datenum('2018-08-03 09:00:12'),'openvolume',1,'openprice',4082,'opendirection',-1);trade7.status_ = 'set';
trade7.setsignalinfo('name','williamsr','extrainfo',extrainfo2);trade7.setriskmanager('name','batman','extrainfo',batman_extrainfo);
trades.push(trade7);
trade8 = cTradeOpen('id','trade8','counter','citic_kim_fut','book','bookdemo','code',code2,'opendatetime',datenum('2018-08-03 09:00:13'),'openvolume',1,'openprice',4083,'opendirection',-1);trade8.status_ = 'set';
trade8.setsignalinfo('name','williamsr','extrainfo',extrainfo2);trade8.setriskmanager('name','batman','extrainfo',batman_extrainfo);
trades.push(trade8);
trade9 = cTradeOpen('id','trade9','counter','citic_kim_fut','book','bookdemo','code',code2,'opendatetime',datenum('2018-08-03 09:00:14'),'openvolume',1,'openprice',4084,'opendirection',-1);trade9.status_ = 'set';
trade9.setsignalinfo('name','williamsr','extrainfo',extrainfo2);trade9.setriskmanager('name','batman','extrainfo',batman_extrainfo);
trades.push(trade9);
trade10 = cTradeOpen('id','trade10','counter','citic_kim_fut','book','bookdemo','code',code2,'opendatetime',datenum('2018-08-03 09:00:15'),'openvolume',1,'openprice',4085,'opendirection',-1);trade10.status_ = 'set';
trade10.setsignalinfo('name','williamsr','extrainfo',extrainfo2);trade10.setriskmanager('name','batman','extrainfo',batman_extrainfo);
trades.push(trade10);
positions = trades.convert2positions;
fprintf('\n');
positions{1}.print;
positions{2}.print;
%%
tbl = trades.totable;
open tbl;
%%
trades.toexcel('c:\yangyiran\trades.xlsx');
%%
trades2 = cTradeOpenArray;
trades2.fromexcel('c:\yangyiran\trades.xlsx','tradeopen');
positions2 = trades2.convert2positions;
fprintf('\n');
positions2{1}.print;
positions2{2}.print;
%%
trades.totxt('c:\yangyiran\trades.txt');
%%
trades3 = cTradeOpenArray;
trades3.fromtxt('c:\yangyiran\trades.txt');
positions3 = trades3.convert2positions;

fprintf('\n');
positions3{1}.print;
positions3{2}.print;