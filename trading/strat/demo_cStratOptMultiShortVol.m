%demo_cstratoptmultishortvol
strat = cStratOptMultiShortVol;
%load options
strat.loadoptions('m1805');
% strat.loadoptions('SR805');
strat.setmdeconnection('ctp');

strat.registercounter(c_ly);

%%
strat.mde_opt_.refresh;
strat.mde_opt_.voltable;

%%
strat.shortopensingleopt('m1805-C-2900',5)

%%
strat.updateentrusts

%%
strat.portfolio_.print
