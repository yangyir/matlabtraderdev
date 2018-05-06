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
    elseif strcmpi(stratname,'manual')
        replay_strat = cStratManual;
    else
        error('replay_setstrat:invalid strategy name input')
    end
    
    try
        replay_strat.mode_ = 'replay';
        replay_strat.mde_fut_ = replay_mdefut;
        replay_strat.trader_ = replay_trader;
        replay_strat.helper_ = replay_ops;
        replay_strat.bookrunning_ = replay_book;
        replay_strat.bookbase_ = replay_book;
        replay_strat.counter_ = replay_counter;
        replay_strat.timer_interval_ = 60/replayspeed;
        replay_strat.helper_.timer_interval_ = 1/replayspeed;
        replay_strat.mde_fut_.timer_interval_ = 0.5/replayspeed;
    catch e
        error(['replay_setstrat:',e.message]);
    end
    
end