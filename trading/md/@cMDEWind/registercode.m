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
        lastbd = businessdate(cobdate,-1);
    else
        %the day's trading has finished
        lastbd = cobdate;
    end

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
        obj.candlesdaily_{i,1} = dailypx;
        obj.candlesintraday_{i,1} = intradaypx;
    else
        codes = cell(n+1,1);
        codeswind = cell(n+1,1);
        kintraday = cell(n+1,1);
        kdaily = cell(n+1,1);
        for i = 1:n
            codes{i,1} = obj.codes_{i,1};
            codeswind{i,1} = obj.codeswind_{i,1};
            kintraday{i,1} = obj.candlesintraday_{i,1};
            kdaily{i,1} = obj.candlesdaily_{i,1};
        end
        codes{n+1,1} = code;
        if strcmpi(code(1),'5') || strcmpi(code(1),'6')
            codeswind{n+1,1} = [code,'.SH'];
        else
            codeswind{n+1,1} = [code,'.SZ'];
        end
        obj.codes_ = codes;
        obj.codeswind_ = codeswind;
        %              
        kdaily{n+1,1} = dailypx;
        obj.candlesdaily_ = kdaily;
        %
        kintraday{n+1,1} = intradaypx;
        obj.candlesintraday_ = kintraday;

    end
end