%demo_cstratoptmultishortvol
strat = cStratOpt;
%register options
strat.registeroptions('m1805',5);
strat.setmdeconnection('bloomberg');
strat.portfolio_.print;
% strat.registercounter(c_ly);

%%
strat.mde_opt_.refresh;
strat.mde_fut_.refresh;
strat.mde_opt_.voltable;
strat.updategreeks;

%%
idx = 7;
codestr_opt = strat.instruments_.getinstrument{idx}.code_ctp;
data = cDataFileIO.loadDataFromTxtFile([codestr_opt,'_daily.txt']);
closep = data(data(:,1) == getlastbusinessdate,5);
volume = -20;
strat.portfoliobase_.addinstrument(strat.instruments_.getinstrument{idx},closep,volume,getlastbusinessdate);
strat.portfolio_.addinstrument(strat.instruments_.getinstrument{idx},closep,volume,getlastbusinessdate);
strat.portfolio_.print;

%%
%End of day pnl and risk
[pnltbl,risktbl] = strat.pnlriskeod;
printpnltbl(pnltbl);
printrisktbl(risktbl);

%%
%real-time pnl and risk
[pnltbl,risktbl] = strat.pnlriskrealtime;
printpnltbl(pnltbl);
printrisktbl(risktbl);

%%
strat.calcrunningpnl(strat.instruments_.getinstrument{idx});
disp(strat.pnl_running_(idx))



