%%
trader = cTraderMaster;
%%
%login to citic fut counter
trader.counterlogin('100');
%login to md
trader.mdlogin;
%%
%check positions
trader.queryaccounts('100');
%%
%check trades
trader.querytrades('100');
%%
trader.registerinstruments('T1806;TF1806');
trader.registerinstruments('m1805-C-3100');
trader.registerinstruments('m1805-P-3100');
trader.registerinstruments('m1805-C-3150');
trader.registerinstruments('m1805-P-3150');
trader.registerinstruments('m1805-C-3200');
trader.registerinstruments('m1805-P-3200');
trader.getquotes;
%%
trader.voltable;