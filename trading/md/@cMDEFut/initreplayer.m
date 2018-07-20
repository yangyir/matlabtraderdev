function [] = initreplayer(obj,varargin)
%cMyTimerObj
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('fn','',@ischar);
    p.addParameter('filenames',{},@iscell);
    p.parse(varargin{:});
    codestr = p.Results.code;
    fn = p.Results.fn;
    fns = p.Results.filenames;
    
    if ~isempty(fn) && ~isempty(fns)
        error('cMDEFut:initreplayer:invalid inputs as both fn and filenames are given')
    end
    
    if ~isempty(fn)
        r = cReplayer;
        r.mode_ = 'singleday';
        r.loadtickdata('code',codestr,'fn',fn);        
    elseif ~isempty(fns)
        r = cReplayer;
        r.mode_ = 'multiday';
        r.multidayfiles_ = fns;
        r.multidayidx_ = 1;
        r.loadtickdata('code',codestr,'fn',fns{r.multidayidx_});
    end
    
    obj.replayer_ = r;
    obj.mode_ = 'replay';

    [~,idx] = r.instruments_.hasinstrument(codestr);
    obj.replay_date1_ = floor(r.tickdata_{idx}(1,1));
    obj.replay_date2_ = datestr(obj.replay_date1_,'yyyy-mm-dd');
    %     
    obj.replay_datetimevec_ = r.tickdata_{idx}(:,1);
    obj.replay_count_ = 1;
    obj.replay_time1_ = obj.replay_datetimevec_(obj.replay_count_);
    obj.replay_time2_ = datestr(obj.replay_time1_,'yyyy-mm-dd HH:MM:SS');

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
    
    % compute num21_00_00_; num21_00_0_5_;num00_00_00_;num00_00_0_5_ if it
    % is required
    if obj.categories_(idx2) > 3
        datestr_start = datestr(floor(obj.candles4save_{idx2}(1,1)));
        obj.num21_00_00_ = datenum([datestr_start,' 21:00:00']);
        obj.num21_00_0_5_ = datenum([datestr_start,' 21:00:0.5']);
    end
    if obj.categories_(idx2) == 5
        datestr_end = datestr(floor(obj.candles4save_{idx2}(end,1)));
        obj.num00_00_00_ = datenum([datestr_end,' 00:00:00']);
        obj.num00_00_0_5_ = datenum([datestr_end,' 00:00:0.5']);
    end
    
    
    % init datenum_open_ and datenum_close_
    blankstr = ' ';
    nintervals = size(instruments{idx2}.break_interval,1);
    datenum_open_new = zeros(nintervals,1);
    datenum_close_new = zeros(nintervals,1);
    datestr_start = datestr(floor(obj.candles4save_{idx2}(1,1)));
    datestr_end = datestr(floor(obj.candles4save_{idx2}(end,1)));
    for j = 1:nintervals
        datenum_open_new(j,1) = datenum([datestr_start,blankstr,instruments{idx2}.break_interval{j,1}]);
        if obj.categories_(idx2) ~= 5
            datenum_close_new(j,1) = datenum([datestr_start,blankstr,instruments{idx2}.break_interval{j,2}]);
        else
            if j == nintervals
                datenum_close_new(j,1) = datenum([datestr_end,blankstr,instruments{idx2}.break_interval{j,2}]);
            else
                datenum_close_new(j,1) = datenum([datestr_start,blankstr,instruments{idx2}.break_interval{j,2}]);
            end
        end
    end
    obj.datenum_open_{idx2,1} = datenum_open_new;
    obj.datenum_close_{idx2,1} = datenum_close_new;
    
    
end