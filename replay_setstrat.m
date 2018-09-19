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
        replay_strat = cStratFutMultiBatman;
    elseif strcmpi(stratname,'wlprbatman')
        replay_strat = cStratFutMultiWRPlusBatman;
    elseif strcmpi(stratname,'manual')
        replay_strat = cStratManual;
    else
        error('replay_setstrat:invalid strategy name input')
    end
    
    default_timerinterval_strat = 0.5;
    default_timerinterval_ops = 1;
    default_timerinterval_mde = 1;
    
    try
        replay_strat.mode_ = 'replay';
        
        replay_ops.settimerinterval(default_timerinterval_ops/replayspeed);
        replay_mdefut.settimerinterval(default_timerinterval_mde/replayspeed);
        replay_strat.registermdefut(replay_mdefut);
        replay_strat.registerhelper(replay_ops);
        replay_strat.settimerinterval(default_timerinterval_strat/replayspeed);
    catch e
        error(['replay_setstrat:',e.message]);
    end
    
end