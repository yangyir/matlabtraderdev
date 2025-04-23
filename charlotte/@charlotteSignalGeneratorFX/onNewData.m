function [] = onNewData(obj,~,eventData)
% a charlotteSignalGeneratorFX method
    data = eventData.MarketData;
    ncodes = size(obj.codes_,1);
    nsignal = 0;
    for i = 1:ncodes
        try
            data_i = data{i};
        catch
            data_i = [];
        end
        if ~isempty(data_i)
            newcandle_i = [data_i.time,data_i.open,data_i.high,data_i.low,data_i.close];
        else
            newcandle_i = [];
        end
        if isempty(obj.freq_{i})
            try
                obj.freq_{i} = data_i.freq;
            catch
                obj.freq_{i} = '';
            end
        end
        if isempty(obj.kellytables_{i}) && ~isempty(obj.freq_{i})
            fn_i = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\strat_fx_',obj.freq_{i},'.mat'];
            data_i = load(fn_i);
            obj.kellytables_{i} = data_i.(['strat_fx_',obj.freq_{i}]);
        end
        if isempty(obj.candles_{i}) && ~isempty(obj.freq_{i})
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
        end
        %
        candles_i = obj.candles_{i};
        obj.candles_{i} = [candles_i;newcandle_i];
        obj.signals_{i} = obj.genSignal(obj.codes_{i});
        if ~isempty(obj.signals_{i})
            nsignal = nsignal + 1;
        end
    end
    
    for i = 1:ncodes
        signal_i = obj.signals_{i};
        try
            signal_direction = signal_i.directionkellied;
        catch
            signal_direction = 0;
        end
        try
            signal_kelly = signal_i.kelly;
        catch
            signal_kelly = -0.999;
        end
        try
            signal_wprob = signal_i.wprob;
        catch
            signal_wprob = 0;
        end
        try
            signal_name = signal_i.opkellied;
        catch
            signal_name = '';
        end
        if i == 1
            fprintf('%10s%10s%14s%10s%10s%8s%8s%10s%10s%10s%10s%10s%10s%11s%11s%20s\n',...
                        'Code','Last','Datetime(ldn)','HH','LL','BS','SS','LevelUp','LevelDn','Jaw','Teeth','Lips','Signal','Kelly','WinP','OP');
        end
        if strcmpi(obj.codes_{i},'USDJPY')
            dataformat = '%10s%10s%14s%10s%10s%8s%8s%10s%10s%10.3f%10.3f%10.3f%10d%10.1f%%%10.1f%%%20s\n';
        elseif strcmpi(obj.codes_{i},'XAUUSD')
            dataformat = '%10s%10s%14s%10s%10s%8s%8s%10s%10s%10.2f%10.2f%10.2f%10d%10.1f%%%10.1f%%%20s\n';
        else
            dataformat = '%10s%10s%14s%10s%10s%8s%8s%10s%10s%10.4f%10.4f%10.4f%10d%10.1f%%%10.1f%%%20s\n';
        end
        
        fprintf(dataformat,obj.codes_{i},...
            num2str(obj.extrainfo_{i}.px(end,5)),...
            datestr(obj.extrainfo_{i}.px(end,1),'dd-mmm HH:MM'),...
            num2str(obj.extrainfo_{i}.hh(end)),...
            num2str(obj.extrainfo_{i}.ll(end)),...
            num2str(obj.extrainfo_{i}.bs(end)),...
            num2str(obj.extrainfo_{i}.ss(end)),...
            num2str(obj.extrainfo_{i}.lvlup(end)),...
            num2str(obj.extrainfo_{i}.lvldn(end)),...
            obj.extrainfo_{i}.jaw(end),...
            obj.extrainfo_{i}.teeth(end),...
            obj.extrainfo_{i}.lips(end),...
            signal_direction,...
            signal_kelly*100,...
            signal_wprob*100,...
            signal_name);
    end
    fprintf('\n');
    
    if nsignal > 0
        data = struct('signals_',{obj.signals_},...
            'ei_',{obj.extrainfo_},...
            'codes_',{obj.codes_},...
            'freq_',{obj.freq_});
        notify(obj,'NewSignalGenerated',charlotteDataFeedEventData(data));
    end
    
    
    fprintf('\n');
    
end