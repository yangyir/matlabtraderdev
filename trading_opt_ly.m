%%
login_counter_opt2;

%%
fprintf('register option strategy with options......\n');
try
    stratopt_ly = cStratOpt;
    stratopt_ly.registercounter(c_opt2);
    stratopt_ly.registeroptions('m1805',9);
    stratopt_ly.timer_interval_ = 60;
catch e
    error(e.message);
end

%%
stratopt_ly.start;

%%
stratopt_ly.stop;

%%
stratopt_ly.loadportfoliofromcounter;
stratopt_ly.portfolio_.print;

%%
%real-time pnl and risk
[pnltbl,risktbl] = stratopt_ly.pnlriskrealtime;
printpnltbl(pnltbl);printrisktbl(risktbl);fprintf('\n');

%%
pnltbl = cHelper.pnlrisk1(stratopt_ly.portfolio_,getlastbusinessdate);
printpnltbl(pnltbl)


