function replay_strat = replay_setstrat(stratname,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('StrategyName',@ischar);
    p.addParameter('ReplaySpeed',1,@isnumeric);
    p.parse(stratname,varargin{:});
    stratname = p.Results.StrategyName;
    replayspeed = p.Results.ReplaySpeed;
    
    try
        replay_init;
    catch e
        error(['replay_setstrat:',e.message]);
    end
    
    if strcmpi(stratname,'wlpr')
        replay_strat = cStratFutMultiWR;
    elseif strcmpi(stratname,'batman')
        replay_strat = cStratFutBatman;
    elseif strcmpi(stratname,'wlprbatman')
        replay_strat = cStratFutMultiWRPlusBatman;
    elseif strcmpi(stratname,'manual')
        replay_strat = cStratManual;
    else
        error('replay_setstrat:invalid strategy name input')
    end
    
    default_timerinterval_strat = 1;
    default_timerinterval_ops = 0.5;
    default_timerinterval_mde = 0.5;
    
    try
        replay_strat.mode_ = 'replay';
        replay_strat.registermdefut(replay_mdefut);
        replay_strat.trader_ = replay_trader;
        replay_strat.helper_ = replay_ops;
        replay_strat.bookrunning_ = replay_book;
        replay_strat.bookbase_ = replay_book;
        replay_strat.counter_ = replay_counter;
        replay_strat.timer_interval_ = default_timerinterval_strat/replayspeed;
        replay_strat.helper_.timer_interval_ = default_timerinterval_ops/replayspeed;
        replay_strat.mde_fut_.timer_interval_ = default_timerinterval_mde/replayspeed;
    catch e
        error(['replay_setstrat:',e.message]);
    end
    
end