function [] = initreplayer(obj,varargin)
%cMyTimerObj
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('fn','',@ischar);
    p.parse(varargin{:});
    codestr = p.Results.code;
    fn = p.Results.fn;
    
%     obj.registerinstrument(codestr);
    
    r = cReplayer;
    r.loadtickdata('code',codestr,'fn',fn);
    obj.replayer_ = r;
    
    obj.mode_ = 'replay';
    
    [~,idx] = r.instruments_.hasinstrument(codestr);
    
    obj.replay_date1_ = floor(r.tickdata_{idx}(1,1));
    obj.replay_date2_ = datestr(obj.replay_date1_,'yyyy-mm-dd');
%     
    obj.replay_datetimevec_ = r.tickdata_{idx}(:,1);
    obj.replay_count_ = 1;
    
    % candles_ and candles4save_'s timevec needs to be inline with replay
    % date
    [f2,idx2] = obj.qms_.instruments_.hasinstrument(codestr);
    if ~f2, error('cMDEFut:initreplayer:code not registered!');end
    instruments = obj.qms_.instruments_.getinstrument;
    
    buckets = getintradaybuckets2('date',obj.replay_date1_,...
        'frequency',[num2str(obj.candle_freq_(idx2)),'m'],...
        'tradinghours',instruments{idx2}.trading_hours,...
        'tradingbreak',instruments{idx2}.trading_break);
    candle_ = [buckets,zeros(size(buckets,1),4)];
    obj.candles_{idx2} = candle_;
    
    buckets = getintradaybuckets2('date',obj.replay_date1_,...
        'frequency','1m',...
        'tradinghours',instruments{idx2}.trading_hours,...
        'tradingbreak',instruments{idx2}.trading_break);
    candle_ = [buckets,zeros(size(buckets,1),4)];
    obj.candles4save_{idx2} = candle_;
    
end