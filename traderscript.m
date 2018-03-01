%%
trader = cTraderMaster;
%%
%login to citic fut counter
trader.counterlogin('100');
%login to md
trader.mdlogin;
%%
%check positions
trader.querycounters('100');
%%
%check trades
trader.querycountertrades('100');