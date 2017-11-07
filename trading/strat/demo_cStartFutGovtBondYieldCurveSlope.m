code_5y = 'TF1803';bnd_5y = cFutures(code_5y);bnd_5y.loadinfo([code_5y,'_info.txt']);
code_10y = 'T1803';bnd_10y = cFutures(code_10y);bnd_10y.loadinfo([code_10y,'_info.txt']);

strat = cStratFutGovtBondYieldCurveSlope;
strat.registerinstrument(bnd_5y);
strat.registerinstrument(bnd_10y);
strat.mde_fut_.qms_.setdatasource('bloomberg');

%%
strat.mde_fut_.qms_.refresh;

%%
strat.start;

%%
strat.stop;

%%
strat.printfinfo
