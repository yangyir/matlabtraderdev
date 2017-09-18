clc;
%%
code_ctp = 'ni1801';
instrument_nickel = cFutures(code_ctp);
instrument_nickel.loadinfo([code_ctp,'_info.txt']);

%%
qms.refresh;
quote_trading = qms.getquote(instrument_nickel);
quote_trading.print;

%%
rollinfo = rollfutures(instrument_nickel.asset_name,'ForecastPeriod',42,'UpdateTimeSeries',true);

%%
strat_nickel_syntheticopt = cStratFutSingleSyntheticOpt;
strat_nickel_syntheticopt.registerinstrument(instrument_nickel);
%set strategy
fv = rollinfo.ForecastResults.ForecastedAnnualVol;
notional = 1e6;
expiry = '2017-11-17';
%trade a strangle
strat_nickel_syntheticopt.addoptleg('c',1.01,expiry,1e6,fv/sqrt(252));
strat_nickel_syntheticopt.addoptleg('p',0.99,expiry,1e6,fv/sqrt(252));

%%
ts_trading = cTradingSystem;
ts_trading.registerinstrument(instrument_nickel);
ts_trading.qms_ = qms;
ts_trading.counter_ = c_kim;
ts_trading.strat_ = strat_nickel_syntheticopt;
ts_trading.autotrade;

%%
ts_trading.manualtrade


%%
ts_trading.stop;