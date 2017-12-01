%%
if ~exist('md_ctp','var') || ~isa(md_ctp,'cCTP')
    md_ctp = cCTP.citic_kim_fut;
end
if ~md_ctp.isconnect, md_ctp.login; end
%%
%demo_cstratoptmultishortvol
strat = cStratOpt;
%register options
strat.registeroptions('m1805',5);
strat.setmdeconnection('ctp');
strat.portfolio_.print;
% strat.registercounter(c_ly);

%%
strat.mde_opt_.refresh;
strat.mde_fut_.refresh;
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
[~,risktbl] = strat.pnlriskeod;
% printpnltbl(pnltbl);
printrisktbl(risktbl);

%%
%real-time pnl and risk
[~,risktbl] = strat.pnlriskrealtime;
% printpnltbl(pnltbl);
printrisktbl(risktbl);

%%
strat.calcrunningpnl(strat.instruments_.getinstrument{idx});
disp(strat.pnl_running_(idx))
%%
strat.loadportfoliofromcounter;


