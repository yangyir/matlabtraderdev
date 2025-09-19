function [] = initreplayer(obj,varargin)
%a cMDEOpt function
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('fn','',@ischar);
    p.addParameter('filenames',{},@iscell);
    p.parse(varargin{:});
    codestr = p.Results.code;
    
    [optflag,~,~,underlierstr] = isoptchar(codestr);
        
    fn = p.Results.fn;
    fns = p.Results.filenames;
    
    if ~isempty(fn) && ~isempty(fns)
        error('ERROR:%s:initreplayer:invalid inputs as both fn and filenames are given',class(obj))
    end
    
    if isempty(obj.replayer_)
        obj.replayer_ = cReplayer;
    end
    
    if optflag
        flag = obj.replayer_.instruments_.hasinstrument(underlierstr);
        if ~flag
            obj.replayer_.registerinstrument(underlierstr);
        end
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
            error('ERROR:%s:initreplayer:inconsistent tick data found on different cob dates',class(obj))
        end
    end
    
    % candles_ and candles4save_'s timevec needs to be inline with replay
    % date
    [f2,idx2] = obj.qms_.instruments_.hasinstrument(codestr);
    if ~f2, error('ERROR:%s:initreplayer:code not registered!',class(obj));end
    instruments = obj.qms_.instruments_.getinstrument;

    if obj.candle_freq_(idx2) ~= 1440
        buckets = getintradaybuckets2('date',obj.replay_date1_,...
            'frequency',[num2str(obj.candle_freq_(idx2)),'m'],...
            'tradinghours',instruments{idx2}.trading_hours,...
            'tradingbreak',instruments{idx2}.trading_break);
        candle_ = [buckets,zeros(size(buckets,1),4)];
    else
        category = getfutcategory(instruments{idx2});
        if category == 1 || category == 2 || category == 3
            buckets = getintradaybuckets2('date',obj.replay_date1_,...
            'frequency',[num2str(obj.candle_freq_(idx2)),'m'],...
            'tradinghours',instruments{idx2}.trading_hours,...
            'tradingbreak',instruments{idx2}.trading_break);
            candle_ = [buckets,zeros(size(buckets,1),4)];
        else
            prevbusdate = businessdate(obj.replay_date1_,-1);
            buckets = [prevbusdate+0.875;obj.replay_date1_+0.875];
            %as the replay ticks start from 09:00 (or 09:30am) on
            %replay_date1, we shall fill the first row of buckets with
            %existing open,high,low,close from 21:00 until market close
            ds = cLocal;
            if category == 4
                candles = ds.intradaybar(instruments{idx2},...
                    datestr(prevbusdate+0.875,'yyyy-mm-dd HH:MM:SS'),...
                    [datestr(prevbusdate,'yyyy-mm-dd'),' 23:00:00'],1,'trade');
            elseif category == 5
                candles = ds.intradaybar(instruments{idx2},...
                    datestr(prevbusdate+0.875,'yyyy-mm-dd HH:MM:SS'),...
                    [datestr(obj.replay_date1_,'yyyy-mm-dd'),' 02:30:00'],1,'trade');
            end
            row1 = [buckets(1),candles(1,2),max(candles(:,3)),min(candles(:,4)),candles(end,5)];
            row2 = [buckets(2),zeros(1,4)];
            candle_ = [row1;row2];
            obj.candles_count_(idx2) = 1;
        end
    end
    
    obj.candles_{idx2} = candle_;

    buckets = getintradaybuckets2('date',obj.replay_date1_,...
        'frequency','1m',...
        'tradinghours',instruments{idx2}.trading_hours,...
        'tradingbreak',instruments{idx2}.trading_break);
    candle_ = [buckets,zeros(size(buckets,1),4)];
    obj.candles4save_{idx2} = candle_;
    
    obj.replay_idx_(idx2) = 0;
    
    % last close needs to be inline with replay date
%     filename = [codestr,'_daily.txt'];
%     dailypx = cDataFileIO.loadDataFromTxtFile(filename);
%     lastbd = businessdate(obj.replay_date1_,-1);
%     idx = dailypx(:,1) == lastbd;
%     lastpx = dailypx(idx,5);
%     if ~isempty(lastpx), obj.lastclose_(idx2) = lastpx;end
    
    % compute num21_00_00_; num21_00_0_5_;num00_00_00_;num00_00_0_5_ if it
    % is required
    if obj.categories_ > 3
        datestr_start = datestr(floor(obj.candles4save_{idx2}(1,1)));
        obj.num21_00_00_ = datenum([datestr_start,' 21:00:00']);
        obj.num21_00_0_5_ = datenum([datestr_start,' 21:00:0.5']);
    end
    if obj.categories_ == 5
        datestr_end = datestr(floor(obj.candles4save_{idx2}(end,1)));
        obj.num00_00_00_ = datenum([datestr_end,' 00:00:00']);
        obj.num00_00_0_5_ = datenum([datestr_end,' 00:00:0.5']);
    end
    
    
    % init datenum_open_ and datenum_close_
    blankstr = ' ';
    nintervals = size(instruments{1}.break_interval,1);
    datenum_open_new = zeros(nintervals,1);
    datenum_close_new = zeros(nintervals,1);
    datestr_start = datestr(floor(obj.candles4save_{1}(1,1)));
    datestr_end = datestr(floor(obj.candles4save_{1}(end,1)));
    for j = 1:nintervals
        datenum_open_new(j,1) = datenum([datestr_start,blankstr,instruments{1}.break_interval{j,1}]);
        if obj.categories_
            datenum_close_new(j,1) = datenum([datestr_start,blankstr,instruments{1}.break_interval{j,2}]);
        else
            if j == nintervals
                datenum_close_new(j,1) = datenum([datestr_end,blankstr,instruments{1}.break_interval{j,2}]);
            else
                datenum_close_new(j,1) = datenum([datestr_start,blankstr,instruments{1}.break_interval{j,2}]);
            end
        end
    end
    obj.datenum_open_ = datenum_open_new;
    obj.datenum_close_ = datenum_close_new;
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