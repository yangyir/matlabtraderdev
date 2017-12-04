%%
if ~exist('c_ccb','var') || ~isa(c_ccb,'CounterCTP')
    c_ccb = CounterCTP.ccb_liyang_fut;
    if ~c_ccb.is_Counter_Login, c_ccb.login; end
end

if ~exist('md_ccb','var') || ~isa(md_ccb,'cCTP')
            md_ccb = cCTP.ccb_liyang_fut;
end
if ~md_ccb.isconnect, md_ccb.login; end

%%
strat = cStratOpt;
%register options
strat.registeroptions('m1805',5);
strat.setmdeconnection('ctp');
strat.portfolio_.print;
strat.registercounter(c_ccb);

%%
strat.mde_opt_.refresh;
strat.mde_fut_.refresh;
strat.updategreeks;

%%
idx = 7;
strat.loadportfoliofromcounter;
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
fprintf('\n');
%%
strat.calcrunningpnl(strat.instruments_.getinstrument{idx});
disp(strat.pnl_running_(idx))



