function [] = onNewData(obj,~,eventData)
% a charlotteSignalGeneratorFX method
    data = eventData.MarketData;
    ncodes = size(obj.codes_,1);
    newSignals = zeros(ncodes,1);
    newIndicators = zeros(ncodes,1);
    symbols = cell(ncodes,1);
    modes = cell(ncodes,1);
    for i = 1:ncodes
        strsplit = regexp(obj.codes_{i},'-','split');
        symbols{i} = strsplit{1};
        try
            data_i = data{i};
        catch
            data_i = [];
        end
        if ~isempty(data_i)
            if ~obj.calcflag_(i)
                continue;
            end
            newcandle_i = [data_i.time,data_i.open,data_i.high,data_i.low,data_i.close];
            newIndicators(i) = 1;
            modes{i} = data_i.mode;
            candles_i = obj.candles_{i};
            obj.candles_{i} = [candles_i;newcandle_i];
            
            
            obj.signals_{i} = obj.genSignal(symbols{i},obj.freq_{i},modes{i});
            if ~isempty(obj.signals_{i})
                newSignals(i) = 1;
            end
        end
        %
    end
    
    nindicator = sum(newIndicators);
    nsignal = sum(newSignals);
    
    if nindicator > 0
        data = struct('codes_',{obj.codes_},...
            'freq_',{obj.freq_},...
            'ei_',{obj.extrainfo_},...
            'kellytables_',{obj.kellytables_},...
            'signals_',{obj.signals_},...
            'newindicators_',{newIndicators},...
            'newsignals_',{newSignals},...
            'modes_',{modes});
        notify(obj,'NewIndicatorGenerated',charlotteDataFeedEventData(data));
    end
    
    if nsignal > 0
        data = struct('signals_',{obj.signals_},...
            'ei_',{obj.extrainfo_},...
            'codes_',{obj.codes_},...
            'freq_',{obj.freq_},...
            'kellytables_',{obj.kellytables_},...
            'newsignals_',{newSignals},...
            'modes_',{modes});
        notify(obj,'NewSignalGenerated',charlotteDataFeedEventData(data));
    end
    
    if ~obj.printSignal_, return; end
    
    if nindicator == 0,return;end
    for i = 1:ncodes
        %
        if i == 1
            fprintf('%10s%10s%10s%14s%10s%10s%8s%8s%10s%10s%10s%10s%10s%10s%11s%11s%30s\n',...
                        'Code','Freq','Last','Datetime(ldn)','HH','LL','BS','SS','LevelUp','LevelDn','Jaw','Teeth','Lips','Signal','Kelly','WinP','SignalName');
        end
        
        if ~obj.calcflag_(i) 
            continue;
        end
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
        
        if strcmpi(symbols{i},'USDJPY')
            dataformat = '%10s%10s%10.3f%14s%10.3f%10.3f%8d%8d%10.3f%10.3f%10.3f%10.3f%10.3f%10d%10.1f%%%10.1f%%%30s\n';
        elseif strcmpi(symbols{i},'XAUUSD')
            dataformat = '%10s%10s%10.2f%14s%10.2f%10.2f%8d%8d%10.2f%10.2f%10.2f%10.2f%10.2f%10d%10.1f%%%10.1f%%%30s\n';
        else
            dataformat = '%10s%10s%10.5f%14s%10.5f%10.5f%8d%8d%10.5f%10.5f%10.5f%10.5f%10.4f%10d%10.1f%%%10.1f%%%30s\n';
        end
        
        fprintf(dataformat,symbols{i},...
            obj.freq_{i},...
            obj.extrainfo_{i}.px(end,5),...
            datestr(obj.extrainfo_{i}.px(end,1),'dd-mmm HH:MM'),...
            obj.extrainfo_{i}.hh(end),...
            obj.extrainfo_{i}.ll(end),...
            obj.extrainfo_{i}.bs(end),...
            obj.extrainfo_{i}.ss(end),...
            obj.extrainfo_{i}.lvlup(end),...
            obj.extrainfo_{i}.lvldn(end),...
            obj.extrainfo_{i}.jaw(end),...
            obj.extrainfo_{i}.teeth(end),...
            obj.extrainfo_{i}.lips(end),...
            signal_direction,...
            signal_kelly*100,...
            signal_wprob*100,...
            signal_name);
        if i == ncodes
            fprintf('\n');
        end     
    end
    fprintf('\n');
    
    
end