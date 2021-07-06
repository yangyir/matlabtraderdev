%%
clear;clc;
w = cWind;
qms = cQMS;
qms.setdatasource('wind');
qms.watcher_.ds = w;
%%
stock = cStock('510050.CH');
stock.init(qms.watcher_.ds);
fut = code2instrument('IH2107');
qms.registerinstrument(stock);
qms.registerinstrument(fut);
%%

%%
qms.refresh;
