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
    for i = 1:strat_fut_wr.count
        strat_fut_wr.setexecutiontype(strat_fut_wr.instruments_.getinstrument{i},'fixed');
    end
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
