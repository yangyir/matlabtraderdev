%demo_cstratoptmultishortvol
strat = cStratOpt;
%register options
strat.registerinstrument('m1801-C-2600');
strat.registerinstrument('m1801-P-2600');
strat.registerinstrument('m1801-C-2650');
strat.registerinstrument('m1801-P-2650');
strat.registerinstrument('m1801-C-2700');
strat.registerinstrument('m1801-P-2700');
strat.registerinstrument('m1801-C-2750');
strat.registerinstrument('m1801-P-2750');
strat.registerinstrument('m1801-C-2850');
strat.registerinstrument('m1801-C-2900');
strat.registerinstrument('m1801-P-2900');
strat.registerinstrument('m1805-C-2850');
strat.registerinstrument('m1805-C-2900');
strat.registerinstrument('m1805-P-2800');
strat.registerinstrument('m1805-P-2850');
strat.setmdeconnection('bloomberg');

% strat.registercounter(c_ly);

%%
strat.mde_opt_.refresh;
strat.mde_opt_.voltable;

%%
strat.loadportfoliofromfile('opt_pos_trial','2017-11-23');
%%
fprintf('\nstrategy portfolio base:\n');
strat.portfoliobase_.print;
fprintf('strategy portfolio current:\n');
strat.portfolio_.print;

%%
[pnltbl,risktbl] = strat.pnlriskeod;
printpnltbl(pnltbl);
printrisktbl(risktbl);

%%
p = cPortfolio;
for i = 1:strat.portfolio_.count
    instrument = strat.portfolio_.instrument_list{i};
    cost = strat.portfolio_.instrument_avgcost(i);
    volume = strat.portfolio_.instrument_volume(i);
    p.addinstrument(instrument,cost,volume,getlastbusinessdate);
end
p.print;

%%
p.addinstrument(instrument,70,5,now,1);
%%
p.print


