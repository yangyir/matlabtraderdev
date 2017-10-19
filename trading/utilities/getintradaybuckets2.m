function buckets = getintradaybuckets2(varargin)
    %note:get intraday buckets from the one whole trading day
    %start on the trading hours, i.e. 09:00 am
    %ends on the trading hours, i.e. 01:00 am on the next day
    p = inputParser;
    p.CaseSensitive = false;
    p.KeepUnmatched = true;
    p.addParameter('Date',[],...
        @(x) validateattributes(x,{'char','numeric'},{},'','Date'));
    p.addParameter('Frequency',{},...
        @(x) validateattributes(x,{'char'},{},'','Frequency'));
    p.addParameter('TradingHours',{},...
        @(x) validateattributes(x,{'char','cell'},{},'','TradingHours'));
    p.addParameter('TradingBreak',{},...
        @(x) validateattributes(x,{'char','cell'},{},'','TradingBreak'));
    p.parse(varargin{:});
    day = p.Results.Date;
    freq = p.Results.Frequency;
    tradingHours = p.Results.TradingHours;
    tradingBreak = p.Results.TradingBreak;
    if isempty(day), day = today; end
    if isempty(freq), freq = '1m';end
    
    %sanity checks
    if isempty(tradingHours) && ~isempty(tradingBreak)
        error('getintradaybuckets2:missing trading hours inputs once trading break is given');
    end
    
    if strcmpi(freq(end),'m')
        bucket = str2double(freq(1:end-1));
    elseif strcmpi(freq(end),'h')
        bucket = str2double(freq(1:end-1))*60;
    else
        error('getintradaybuckets2:invalid interval inputs');
    end
    
    minutes_per_day = 1440;
    if mod(minutes_per_day,bucket) > 0
        error('getintradaybuckets2:intraday buckets cannot be equally distrubuted');
    end
    
    if ~isempty(tradingHours)
        th = regexp(tradingHours,';','split');
        startstr = regexp(th{1},'-','split');
        bucket_start = 60*str2double(startstr{1}(1:2))+str2double(startstr{1}(end-1:end));
        endstr = regexp(th{end},'-','split');
        bucket_end = 60*str2double(endstr{2}(1:2))+str2double(endstr{2}(end-1:end));
        
        if bucket_end < bucket_start
            bucket_end = bucket_end + minutes_per_day;
        end
    else
        bucket_start = 0;
        bucket_end = minutes_per_day;
    end
    
    buckets = NaN(minutes_per_day,1);
    m = bucket_start;
    count = 1;
    while m < bucket_end
        buckets(count,1) = m;
        m = m + bucket;
        count = count + 1;
    end
    % remove NaNs
    idx = ~isnan(buckets);
    buckets = buckets(idx,:);
    
    % trading hours
    if ~isempty(tradingHours) || ~isempty(tradingBreak)
        use = zeros(length(buckets),1);
        th = regexp(tradingHours,';','split');
        m = regexp(th{1},'-','split');
        a = regexp(th{2},'-','split');   
        m_open = 60*str2double(m{1}(1:2))+str2double(m{1}(end-1:end));
        m_close = 60*str2double(m{2}(1:2))+str2double(m{2}(end-1:end));
        a_open = 60*str2double(a{1}(1:2))+str2double(a{1}(end-1:end));
        a_close = 60*str2double(a{2}(1:2))+str2double(a{2}(end-1:end));
        for i = 1:length(buckets)
            if (buckets(i) >= m_open && buckets(i) < m_close) || ...
               (buckets(i) >= a_open && buckets(i) < a_close)
                use(i) = 1;
            end
        end    
        if size(th,2) == 3
            e = regexp(th{3},'-','split');
            e_open = 60*str2double(e{1}(1:2))+str2double(e{1}(end-1:end));
            e_close = 60*str2double(e{2}(1:2))+str2double(e{2}(end-1:end));
            for i = 1:length(buckets)
                if e_close > m_open
                    if (buckets(i) >= e_open && buckets(i) < e_close)
                        use(i) = 1;
                    end
                else
                    % overnight trades
                    if (buckets(i) >= e_open && buckets(i) < minutes_per_day+e_close)
                        use(i) = 1;
                    end
                end
            end
        end
        if ~isempty(tradingBreak)
            tb = regexp(tradingBreak,'-','split');
            if length(tb) == 2
                tb_start = 60*str2double(tb{1}(1:2))+str2double(tb{1}(end-1:end));
                tb_end = 60*str2double(tb{2}(1:2))+str2double(tb{2}(end-1:end));
                for i = 1:length(buckets)
                    if buckets(i) >= tb_start && buckets(i) < tb_end
                        use(i) = 0;
                    end
                end
            end
        end
        idx = use == 1;
        buckets = buckets(idx,:);
    end
    
    buckets = datenum(day) + buckets./minutes_per_day;
    %
        
end