function [] = registercode(obj,code,varargin)
%cMDEWind
%     p = inputParser;
%     p.CaseSensitive = false;p.KeepUnmatched = true;
%     p.addParameter('Time',now,@isnumeric);
%     p.parse(varargin{:});
%     t = p.Results.Time;

    hh = hour(now);
    if strcmpi(obj.mode_,'realtime') || strcmpi(obj.mode_,'demo')
        if hh < 3
            cobdate = today - 1;
        else
            cobdate = today;
        end
    else
        error('cMDEWind:registercode:not implemented for replay mode yet')
%         cobdate = obj.replay_date1_;
    end
    if hh < 16 && hh > 2
        %the day's trading has not finished
        lastbd = businessdate(cobdate,-1);
    else
        %the day's trading has finished
        lastbd = cobdate;
    end
    cobdailypx = [cobdate,0,0,0,0];
    buckets = getintradaybuckets2('date',cobdate,...
        'frequency','30m',...
        'tradinghours','09:30-11:30;13:00-15:00',...
        'tradingbreak','');
    cobintradaypx = [buckets,zeros(size(buckets,1),4)];
    
    n = size(obj.codes_,1);
    isregisted = false;
    for i = 1:n
        if strcmpi(obj.codes_{i},code)
            isregisted = true;
            break
        end
    end
    
    %init historical daily bar   
    dailyfilename = [code,'_daily.txt'];
    dailypx = cDataFileIO.loadDataFromTxtFile(dailyfilename);
    idx = dailypx(:,1) == lastbd;
    lastpx = dailypx(idx,5);
    if isempty(lastpx)
        error('cMDEWind:registercode:daily bar not updated to the last business date')
    end
    idx_ = find(dailypx(:,1) >= lastbd-365,1,'first');
    dailypx = dailypx(idx_:end,1:5);
    %
    %init historical intraday bar
    intradayfilename = [getenv('ONEDRIVE'),'\matlabdev\equity\',code,'\',code,'.mat'];
    data = load(intradayfilename);
    intradaypx = data.data;
    if floor(intradaypx(end,1)) ~= lastbd
        error('cMDEWind:registercode:intraday bar not updated to the last business date')
    end
    
    if isregisted
        obj.hcandlesdaily_{i,1} = dailypx;
        obj.hcandlesintraday_{i,1} = intradaypx;
        obj.candlesdaily_{i,1} = cobdailypx;
        obj.candlesintraday_{i,1} = cobintradaypx;
    else
        codes = cell(n+1,1);
        codeswind = cell(n+1,1);
        freq = zeros(n+1,1);
        kintraday = cell(n+1,1);
        kdaily = cell(n+1,1);
        for i = 1:n
            codes{i,1} = obj.codes_{i,1};
            codeswind{i,1} = obj.codeswind_{i,1};
            freq(i,1) = obj.freq_(i,1);
            kintraday{i,1} = obj.hcandlesintraday_{i,1};
            kdaily{i,1} = obj.hcandlesdaily_{i,1};
        end
        codes{n+1,1} = code;
        if strcmpi(code(1),'5') || strcmpi(code(1),'6')
            codeswind{n+1,1} = [code,'.SH'];
        else
            codeswind{n+1,1} = [code,'.SZ'];
        end
        obj.codes_ = codes;
        obj.codeswind_ = codeswind;
        freq(n+1,1) = 30;
        obj.freq_ = freq;
        %              
        kdaily{n+1,1} = dailypx;
        obj.hcandlesdaily_ = kdaily;
        %
        kintraday{n+1,1} = intradaypx;
        obj.hcandlesintraday_ = kintraday;
        %
        obj.candlesdaily_{n+1,1} = cobdailypx;
        obj.candlesintraday_{n+1,1} = cobintradaypx;
        
        obj.ticks_count_ = zeros(n+1,1);
        obj.candles_count_ = zeros(n+1,1);
    end
    %
    % init datenum_open_ and datenum_close_
    blankstr = ' ';
    ns = size(obj.codes_,1);
    break_interval = {'09:30:00','11:30:00';'13:00:00','15:00:00'};
    if isempty(obj.datenum_open_)
        obj.datenum_open_ = cell(ns,1);
        obj.datenum_close_ = cell(ns,1);
        datenum_open = zeros(2,1);
        datenum_close = zeros(2,1);
        datestr_start = datestr(cobdate,'yyyy-mm-dd');
        for j = 1:2
            datenum_open(j,1) = datenum([datestr_start,blankstr,break_interval{j,1}]);
            datenum_close(j,1) = datenum([datestr_start,blankstr,break_interval{j,2}]);
        end
        obj.datenum_open_{ns,1} = datenum_open;
        obj.datenum_close_{ns,1} = datenum_close;
    else
        ns_ = size(obj.datenum_open_,1);
        if ns_ ~= ns
            datenum_open = cell(ns,1);
            datenum_close = cell(ns,1);
            for i = 1:ns_
                datenum_open{i} = obj.datenum_open_{i};
                datenum_close{i} = obj.datenum_close_{i};
            end
            datenum_open_new = zeros(2,1);
            datenum_close_new = zeros(2,1);
            blankstr = ' ';
            datestr_start = datestr(cobdate,'yyyy-mm-dd');
            for j = 1:2
                datenum_open_new(j,1) = datenum([datestr_start,blankstr,break_interval{j,1}]);
                datenum_close_new(j,1) = datenum([datestr_start,blankstr,break_interval{j,2}]);
            end
            datenum_open{ns,1} = datenum_open_new;
            datenum_close{ns,1} = datenum_close_new;
            obj.datenum_open_ = datenum_open;
            obj.datenum_close_ = datenum_close;
        end
    end
    
    if isempty(obj.newset_)
        %default value of newset is zero
        obj.newset_ = zeros(ns,1);
    else
        ns_ = size(obj.newset_,1);
        if ns_ ~= ns
            newset = zeros(ns,1);
            newset(1:ns_) = obj.newset_;
            %default value of newset is zero
            newset(ns_+1:ns) = 0;
            obj.newset_ = newset;
        end
    end
    %
end