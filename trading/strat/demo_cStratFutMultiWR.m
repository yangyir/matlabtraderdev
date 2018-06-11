%demo_cStratFutMultiWR
demo_strat_wr = cStratFutMultiWR;
if exist('c_kim','var')
    demo_strat_wr.registercounter(c_kim);
else
    fprintf('counter is missing......\n');
end

%%
%read parameters from file
fprintf('set parameters for strat wr......\n');
fn_ = 'C:\Temp\trading_params_wr.txt';
demo_strat_wr.readparametersfromtxtfile(fn_);
% demo_strat_wr.mode_ = 'debug';
disp(demo_strat_wr);

%%
%try to load positions of instruments from the counter and return empty
%portfolio in case none instruments are found
if strcmpi(demo_strat_wr.mode_,'realtime')
    demo_strat_wr.loadportfoliofromcounter;
    demo_strat_wr.portfolio_.print;
end

%%
instrument = demo_strat_wr.instruments_.getinstrument{1};
demo_strat_wr.initdata4debug(instrument,'2017-11-06 09:00:00','2017-11-06 15:00:00');

%%
fprintf('initiate data for strat wr......\n');
demo_strat_wr.initdata;

%%
demo_strat_wr.startat([datestr(today,'yyyy-mm-dd'),' 09:00:00']);

%%
if strcmpi(demo_strat_wr.mode_,'debug')
    demo_strat_wr.dtcount4debug_ = 0;
    demo_strat_wr.mde_fut_.debug_count_ = 0;
    nticks = size(demo_strat_wr.mde_fut_.ticks_{1},1);
    ncandles = size(demo_strat_wr.mde_fut_.candles_{1},1);
    %clear up
    demo_strat_wr.mde_fut_.ticks_{1} = zeros(nticks,1);
    demo_strat_wr.mde_fut_.candles_{1}(:,2:end) = 0;
    demo_strat_wr.executionperbucket_ = 0;
    demo_strat_wr.executionbucketnumber_ = 0;
    demo_strat_wr.portfolio_ = cPortfolio;
    demo_strat_wr.pnl_close_ = 0;
    demo_strat_wr.pnl_running_ = 0;
end
demo_strat_wr.start;

%%
demo_strat_wr.stop;

%%
demo_strat_wr.printinfo;

%%

