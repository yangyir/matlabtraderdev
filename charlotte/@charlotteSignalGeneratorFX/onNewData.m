function [] = onNewData(obj,~,eventData)
% a charlotteSignalGeneratorFX method
    data = eventData.MarketData;
    ncodes = size(obj.codes_,1);
    nsignal = 0;
    nindicator = 0;
    for i = 1:ncodes
        try
            data_i = data{i};
        catch
            data_i = [];
        end
        if ~isempty(data_i)
            newcandle_i = [data_i.time,data_i.open,data_i.high,data_i.low,data_i.close];
            nindicator = nindicator + 1;
            candles_i = obj.candles_{i};
            obj.candles_{i} = [candles_i;newcandle_i];
            if ~strcmpi(obj.codes_{i},'XAUUSD'),continue;end
            obj.signals_{i} = obj.genSignal(obj.codes_{i});
            if ~isempty(obj.signals_{i})
                nsignal = nsignal + 1;
            end
        end
        %
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
        if ~strcmpi(obj.codes_{i},'XAUUSD'),continue;end
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
    
    if nindicator > 0
        data = struct('codes_',{obj.codes_},...
            'ei_',{obj.extrainfo_},...
            'kellytables_',{obj.kellytables_});
        notify(obj,'NewIndicatorGenerated',charlotteDataFeedEventData(data));
    end
    
    if nsignal > 0
        data = struct('signals_',{obj.signals_},...
            'ei_',{obj.extrainfo_},...
            'codes_',{obj.codes_},...
            'freq_',{obj.freq_},...
            'kellytables_',{obj.kellytables_});
        notify(obj,'NewSignalGenerated',charlotteDataFeedEventData(data));
    end
    
    
    fprintf('\n');
    
end