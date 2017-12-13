%%
login_counter_fut;
%
%%
try
    strat_fut_wr = cStratFutMultiWR;
    strat_fut_wr.registercounter(c_fut);
    fn_ = 'C:\Temp\trading_params_wr.txt';
    fprintf('set parameters for strat wr......\n');
    strat_fut_wr.readparametersfromtxtfile(fn_);
    disp(strat_fut_wr);
catch e
    error(e.message);
end

%%
fprintf('initiate data for strat wr......\n');
strat_fut_wr.initdata;

%%
%start the strategy
strat_fut_wr.start;

%%
%stop the strategy
strat_fut_wr.stop;

%%
strat_fut_wr.printinfo;

%%
strat_fut_wr.pnl_running_

%%
strat_fut_wr.portfolio_.print;
%%
%code:pb1802;volume:-2;volume(today):-2;cost(carry):19207.50;cost(open):19207.50
%code:cu1802;volume:-1;volume(today):-1;cost(carry):52380.00;cost(open):52380.00

