function [] = debug(~)
    fut = cFutures('rb1801');
    fut.loadinfo('rb1801_info.txt');
    strat_debug = cStratFutMultiWR;
    strat_debug.mode_ = 'debug';
    strat_debug.mde_fut_.mode_ = 'debug';
    strat_debug.mde_opt_.mode_ = 'debug';
    strat_debug.registerinstrument(fut);
    strat_debug.setexecutiontype(fut,'fixed');
    fprintf('init data for debug.....\n');
    strat_debug.initdata4debug(fut,'2017-11-06 09:00:00','2017-11-06 15:00:00');
    
    strat_debug.initdata;
    %%
    strat_debug.dtcount4debug_ = 0;
    strat_debug.mde_fut_.debug_count_ = 0;
    nticks = size(strat_debug.mde_fut_.ticks_{1},1);
%     ncandles = size(strat_demo.mde_fut_.candles_{1},1);
    %clear up
    strat_debug.mde_fut_.ticks_{1} = zeros(nticks,0);
    strat_debug.mde_fut_.candles_{1}(:,2:end) = 0;
    strat_debug.executionperbucket_ = 0;
    strat_debug.executionbucketnumber_ = 0;
    strat_debug.portfolio_ = cPortfolio;
    strat_debug.pnl_close_ = 0;
    strat_debug.pnl_running_ = 0;
    strat_debug.mde_opt_.display_ = 0;
    strat_debug.autotrade_(1) = 1;
    
    %%
    fprintf('start demo......\n');
    strat_debug.timer_interval_ = 0.5;
    strat_debug.start;
    %%
    strat_debug.stop;
end