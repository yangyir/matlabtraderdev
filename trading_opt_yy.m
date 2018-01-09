%%
login_counter_opt1;

%%
fprintf('register option strategy with options......\n');
try
    stratopt_yy = cStratOpt;
    stratopt_yy.registercounter(c_opt1);
    stratopt_yy.registeroptions('m1805',9);
    stratopt_yy.timer_interval_ = 60;
    stratopt_yy.loadportfoliofromcounter;
    stratopt_yy.portfolio_.print;
catch e
    error(e.message);
end

%%
stratopt_yy.start;

%%
%real-time pnl and risk
[pnltbl,risktbl] = stratopt_yy.pnlriskrealtime;
printpnltbl(pnltbl);
printrisktbl(risktbl);
fprintf('\n');

%%
stratopt_yy.stop;
%%
stratopt_yy.saveportfoliotofile('c:\temp\check1.txt');

%%
pnltbl = stratopt_yy.pnlriskeod;
printpnltbl(pnltbl);
fprintf('\n');

%%
code = 'm1805-C-3000';
lots = 5;
stratopt_yy.shortopensingleinstrument(code,lots);
%%
pnltbleod = cHelper.pnlrisk1(stratopt_yy.portfolio_,getlastbusinessdate);
printpnltbl(pnltbleod);
