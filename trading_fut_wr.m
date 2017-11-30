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
code = 'ni1805';
strat_wr.longopensingleinstrument(code,1);
%%
strat_wr.withdrawentrusts(code);
%%
strat_wr.shortclosesingleinstrument(code,1,1);

%%
strat_wr.portfolio_.print;
