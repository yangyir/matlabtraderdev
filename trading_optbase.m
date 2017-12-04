%%
login_counter_opt1;

%%
fprintf('register option strategy with options......\n');
try
    stratopt1 = cStratOpt;
    stratopt1.registercounter(c_opt1);
    stratopt1.registeroptions('m1805',7);
    stratopt1.timer_interval_ = 60;
catch e
    error(e.message);
end

%%
stratopt1.start;

%%
stratopt1.stop;

%%
stratopt1.loadportfoliofromcounter;
stratopt1.portfolio_.print;

%%
%End of day pnl and risk
[pnltbl,risktbl] = stratopt1.pnlriskeod;
printpnltbl(pnltbl);
printrisktbl(risktbl);

%%
%real-time pnl and risk
[pnltbl,risktbl] = stratopt1.pnlriskrealtime;
printpnltbl(pnltbl);
printrisktbl(risktbl);
fprintf('\n');
%%
stratopt1.mde_opt_.refresh;stratopt1.mde_fut_.refresh;stratopt1.updategreeks;
codes= {'m1805-C-2800';'m1805-P-2850';'m1805-C-2900';'m1805-P-2950'};
lots = [0;5;5;5];
for i = 1:size(codes,1)
    stratopt1.shortopensingleinstrument(codes{i},lots(i));
end
%%
stratopt1.updateentrusts;
%%
[~,risktbl] = stratopt1.pnlriskrealtime;
printrisktbl(risktbl);fprintf('\n');

%%
stratopt1.saveportfoliotofile('c:\temp\pos_check.txt');


