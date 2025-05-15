function obj = init(obj,varargin)
% a charlotteSignalGenerator (private) function
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('datafeed',{},@(x) validateattributes(x,{'charlotteDataFeedFX'},{},'','datafeed'));
    p.parse(varargin{:});
    datafeed = p.Results.datafeed;
    obj.codes_ = datafeed.codes_;
    ncodes = size(obj.codes_,1);
    obj.ticksize_ = zeros(ncodes,1);
    obj.calcflag_ = ones(ncodes,1);
    obj.printSignal_ = true;
    for i = 1:ncodes
        fx_i = code2instrument(obj.codes_{i});
        obj.ticksize_(i) = fx_i.tick_size;
    end
    obj.signals_ = cell(ncodes,1);
    obj.freq_ = cell(ncodes,1);
    for i = 1:ncodes
        obj.freq_{i} = datafeed.getFrequency(obj.codes_{i});
    end
    %
    obj.kellytables_ = cell(ncodes,1);
    for i = 1:ncodes
        try
            if strcmpi(obj.freq_{i},'5m')
                freq_mt4 = 'm5';
            elseif strcmpi(obj.freq_{i},'15m')
                freq_mt4 = 'm15';
            elseif strcmpi(obj.freq_{i},'30m')
                freq_mt4 = 'm30';
            elseif strcmpi(obj.freq_{i},'1h')
                freq_mt4 = 'h1';
            elseif strcmpi(obj.freq_{i},'4h')
                freq_mt4 = 'h4';
            elseif strcmpi(obj.freq_{i},'daily')
                freq_mt4 = 'd1';
            end
            fn_i = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\strat_fx_',freq_mt4,'.mat'];
            data_i = load(fn_i);
            obj.kellytables_{i} = data_i.(['strat_fx_',freq_mt4]);
        catch ME
            notify(obj, 'ErrorOccurred', ...
                    charlotteErrorEventData(ME.message));
        end
    end
    %
    obj.candles_ = cell(ncodes,1);
    for i = 1:ncodes
        if strcmpi(datafeed.mode_,'realtime')
            if strcmpi(obj.freq_{i},'5m')
                fnappendix = '.lmx_M5_running.csv';
            elseif strcmpi(obj.freq_{i},'15m')
                fnappendix = '.lmx_M15_running.csv';
            elseif strcmpi(obj.freq_{i},'30m')
                fnappendix = '.lmx_M30_running.csv';
            elseif strcmpi(obj.freq_{i},'1h')
                fnappendix = '.lmx_H1_running.csv';
            elseif strcmpi(obj.freq_{i},'4h')
                fnappendix = '.lmx_H4_running.csv';
            elseif strcmpi(obj.freq_{i},'daily')
                fnappendix = '.lmx_D1_running.csv';
            else
                fnappendix = '';
            end
            fn_i = [getenv('APPDATA'),'\MetaQuotes\Terminal\Common\Files\Data\',obj.codes_{i},fnappendix];
            data =  readtable(fn_i,'readvariablenames',1);
            idxlast = find(~isnan(data.Close),1,'last');
            % for save memory, we cut the latest 100 candles
            if idxlast >= 100
                idxfirst = idxlast - 99;
            else
                idxfirst = 1;
            end
            candleopen = data.Open(idxfirst:idxlast);
            candlehigh = data.High(idxfirst:idxlast);
            candlelow = data.Low(idxfirst:idxlast);
            candleclose = data.Close(idxfirst:idxlast);
            candledate = data.Date(idxfirst:idxlast);
            candletime = data.Time(idxfirst:idxlast);
            n = size(candledate,1);
            candledatetime = zeros(n,1);
            for j = 1:n
                thisbardate = candledate{j};
                thisbartime = candletime{j};
                thisbardatestr = [thisbardate(1:4),thisbardate(6:7),thisbardate(9:10)];
                candledatetime(j) = datenum([thisbardatestr,' ',thisbartime],'yyyymmdd HH:MM');
            end
            obj.candles_{i} = [candledatetime,candleopen,candlehigh,candlelow,candleclose];
        elseif strcmpi(datafeed.mode_,'replay')
            replaydata = datafeed.getReplayData(obj.codes_{i});
            idx = datafeed.getReplayCount(obj.codes_{i});
            replaydata = replaydata(1:idx,:);
            idxlast = size(replaydata,1);
            if idxlast >= 100
                idxfirst = idxlast - 99;
            else
                idxfirst = 1;
            end
            obj.candles_{i} = replaydata(idxfirst:end,1:5);
        end
    end
    %
    obj.extrainfo_ = cell(ncodes,1);
    for i= 1:ncodes
        obj.signals_{i} = obj.genSignal(obj.codes_{i});
    end
end