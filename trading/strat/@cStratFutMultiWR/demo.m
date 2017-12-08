function [] = demo(~)
    fut = cFutures('rb1801');
    fut.loadinfo('rb1801_info.txt');
    strat_demo = cStratFutMultiWR;
    strat_demo.registerinstrument(fut);
    fprintf('init data for debug.....\n');
    strat_demo.initdata4debug(fut,'2017-11-06 09:00:00','2017-11-06 15:00:00');
    
    strat_demo.initdata;
    
    strat_demo.dtcount4debug_ = 0;
    strat_demo.mde_fut_.debug_count_ = 0;
    nticks = size(strat_demo.mde_fut_.ticks_{1},1);
%     ncandles = size(strat_demo.mde_fut_.candles_{1},1);
    %clear up
    strat_demo.mde_fut_.ticks_{1} = zeros(nticks,0);
    strat_demo.mde_fut_.candles_{1}(:,2:end) = 0;
    strat_demo.executionperbucket_ = 0;
    strat_demo.executionbucketnumber_ = 0;
    strat_demo.portfolio_ = cPortfolio;
    strat_demo.pnl_close_ = 0;
    strat_demo.pnl_running_ = 0;
    strat_demo.mde_opt_.display_ = 0;
    strat_demo.autotrade_(1) = 1;
    
    
    fprintf('start demo......\n');
    strat_demo.start;
    
    strat_demo.stop;
end