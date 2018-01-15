%%
login_counter_opt2;

%%
fprintf('register option strategy with options......\n');
try
    stratopt_ly = cStratOpt;
    stratopt_ly.registercounter(c_opt2);
    stratopt_ly.registeroptions('m1805',9);
    stratopt_ly.timer_interval_ = 60;
    stratopt_ly.loadportfoliofromcounter;
    stratopt_ly.portfolio_.print;
catch e
    error(e.message);
end

%%
stratopt_ly.start;

%%
stratopt_ly.stop;

%%
%real-time pnl and risk
[pnltbl,risktbl] = stratopt_ly.pnlriskrealtime;
printpnltbl(pnltbl);printrisktbl(risktbl);fprintf('\n');

%%
code = 'm1805-C-3050';
lots = 5;
stratopt_ly.shortopensingleinstrument(code,lots);
%%
pnltbleod = cHelper.pnlrisk1(stratopt_ly.portfolio_,getlastbusinessdate);
printpnltbl(pnltbleod);


