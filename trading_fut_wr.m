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
%try to load positions of instruments from the counter and return empty
%portfolio in case none instruments are found
% if strcmpi(strat_wr.mode_,'realtime')
%     strat_wr.loadportfoliofromcounter;
%     strat_wr.portfolio_.print;
% end

%%
fprintf('initiate data for strat wr......\n');
strat_wr.initdata;

%%
%start the strategy
if strcmpi(strat_wr.mode_,'debug')
    strat_wr.dtcount4debug_ = 0;
    strat_wr.mde_fut_.debug_count_ = 0;
    nticks = size(strat_wr.mde_fut_.ticks_{1},1);
    ncandles = size(strat_wr.mde_fut_.candles_{1},1);
    %clear up
    strat_wr.mde_fut_.ticks_{1} = zeros(nticks,0);
    strat_wr.mde_fut_.candles_{1}(:,2:end) = 0;
    strat_wr.executionperbucket_ = 0;
    strat_wr.executionbucketnumber_ = 0;
    strat_wr.portfolio_ = cPortfolio;
    strat_wr.pnl_close_ = 0;
    strat_wr.pnl_running_ = 0;
end
strat_wr.start;

%%
%stop the strategy
strat_wr.stop;

%%
strat_wr.printinfo;

%%

