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
    
    if isempty(obj.replayer_)
        obj.replayer_ = cReplayer;
    end
    
    [flag,idx] = obj.replayer_.instruments_.hasinstrument(codestr);
    if ~flag
        obj.replayer_.registerinstrument(codestr);
        idx = obj.replayer_.instruments_.count;
    end
    
    
    if ~isempty(fn)
        obj.replayer_.mode_ = 'singleday';
        obj.replayer_.loadtickdata('code',codestr,'fn',fn);        
    elseif ~isempty(fns)
        obj.replayer_.mode_ = 'multiday';
        obj.replayer_.multidayfiles_{1,idx} = fns;
        obj.replayer_.multidayidx_ = 1;
        obj.replayer_.loadtickdata('code',codestr,'fn',fns{obj.replayer_.multidayidx_});
    end
    
    obj.mode_ = 'replay';

    
    if isempty(obj.replay_date1_)
        obj.replay_date1_ = floor(obj.replayer_.tickdata_{idx}(1,1));
        obj.replay_date2_ = datestr(obj.replay_date1_,'yyyy-mm-dd');
    else
        checkdate = floor(obj.replayer_.tickdata_{idx}(1,1));
        if checkdate ~= obj.replay_date1_
            error('cMDEFut:initreplayer:inconsistent tick data found on different cob dates')
        end
    end
    
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
    
    obj.replay_idx_(idx2) = 0;
    
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
    %
    %
%     if obj.replayer_.instruments_.count == 1
%         obj.replay_datetimevec_ = obj.replayer_.tickdata_{idx}(:,1);
%         obj.replay_count_ = 1;
%         obj.replay_time1_ = obj.replay_datetimevec_(obj.replay_count_);
%         obj.replay_time2_ = datestr(obj.replay_time1_,'yyyy-mm-dd HH:MM:SS');
%     else
        % note:with more than 1 instrument
        % we create a timevec in seconds between 09:00am and 02:30am on the
        % next date
        dtstart = 529*60;
        dtend = 86400 + 161*60;
        dtvec = (dtstart:1:dtend)';
        obj.replay_datetimevec_ = dtvec;
        obj.replay_count_ = 1;
        obj.replay_time1_ = obj.replay_date1_ + dtvec(obj.replay_count_)/86400;
        obj.replay_time2_ = datestr(obj.replay_time1_,'yyyy-mm-dd HH:MM:SS');
        
%     end

    
end