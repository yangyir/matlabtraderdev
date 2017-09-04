%%
%make sure this part of script has been run before the market open at 9:15
%on each business date
[rollinfo5y,rollinfo10y,yldspdEOD,yldspdIntraday] = govtbond_trading_init;
%
%
%%
%print volatility information of bond price and implied yield 
voloutput = govtbond_trading_volinfo(rollinfo5y,rollinfo10y,yldspdEOD); 
%
%
%%
%print the information including price, price change, implied yield and
%implied yield change and duration
govtbond_trading_eodinfo(yldspdEOD);
%
%
%%
%print the eod risk
carryPositions = struct('Position5y',220,'Position10y',-109);
govtbond_trading_eodpnlrisk(rollinfo5y,rollinfo10y,'CarryPositions',carryPositions);
%
%
%%
%real-time trading information
govtbond_trading_realtimeinfo(conn,rollinfo5y,rollinfo10y);
%
%
%%
%
govtbond_trading_realtimetimer;

