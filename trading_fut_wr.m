%demo_cStratFutMultiWR
fprintf('init strategy......\n');
strat_wr = cStratFutMultiWR;
if exist('c_kim','var')
    strat_wr.registercounter(c_kim);
else
    fprintf('counter is missing......\n');
end

%%
%read parameters from file
fprintf('set parameters for strat wr......\n');
fn_ = 'C:\Temp\trading_params_wr.txt';
strat_wr.readparametersfromtxtfile(fn_);
disp(strat_wr);

%%
fprintf('initiate data for strat wr......\n');
strat_wr.initdata;

%%
%start the strategy
strat_wr.start;

%%
%stop the strategy
strat_wr.stop;

%%
strat_wr.printinfo;

%%
strat_wr.pnl_running_

%%
code = 'al1802';
futs = strat_wr.instruments_.getinstrument(code);
strat_wr.unwindposition(futs{1});

