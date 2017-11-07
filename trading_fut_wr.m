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
if strcmpi(strat_wr.mode_,'realtime')
    strat_wr.loadportfoliofromcounter;
    strat_wr.portfolio_.print;
end

%%
instrument = strat_wr.instruments_.getinstrument{1};
strat_wr.initdata4debug(instrument,'2017-11-06 09:00:00','2017-11-06 15:00:00');

%%
fprintf('initiate data for strat wr......\n');
strat_wr.initdata;

%%
strat_wr.startat([datestr(today,'yyyy-mm-dd'),' 09:00:00']);

%%
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
strat_wr.stop;

%%
strat_wr.printinfo;

%%

