function [] = onNewBarSetM5(obj,~,eventData)
% a charlotteSignalGenerator function
    data = eventData.MarketData;
    ncodes = size(obj.codes_,1);
    newIndicators = zeros(ncodes,1);
    newSignals = zeros(ncodes,1);
    
    for i = 1:ncodes
        data_i = data{i};
        if isempty(data_i)
            continue;
        end
        
        newBar = [data_i.datetime,data_i.open,data_i.high,data_i.low,data_i.close];
        lastT = obj.candles_m5_{i}(end,1);
        
        if lastT >= newBar(1)
            continue;
        end
        
        newIndicators(i) = 1;
        obj.candles_m5_{i} = [obj.candles_m5_{i};newBar];
        
        nfractal = charlotte_freq2nfractal('m5');
        
        [~,ei_m5_i] = tools_technicalplot1(obj.candles_m5_{i},nfractal,0,'volatilityperiod',0,'tolerance',0);
        
        obj.ei_m5_{i} = ei_m5_i;
        
        code = data_i.code;
        
        signal = obj.genSignal(code,'m5');
        
        if ~isempty(signal)
            obj.signals_m5_{i} = signal;
            newSignals(i) = 1;
        else
            obj.signals_m5_{i} = signal;
        end
    end
    
    nsignal = sum(newSignals);
    
    if nsignal > 0
        data = struct('codes_',{obj.codes_},...
            'freq_','m5',...
            'ei_',{obj.ei_m5_},...
            'signals_',{obj.signals_m5_},...
            'kellytable_',obj.kellytable_m5_,...
            'newindicators_',{newIndicators},...
            'newsignals_',{newSignals},...
            'mode_',obj.mode_);
        notify(obj,'NewSignalGeneratedM5',charlotteDataFeedEventData(data));
        
    end
    
    nindicator = sum(newIndicators);
    
    if nindicator == 0, return;end
    
    for i = 1:ncodes
        if i == 1
            fprintf('%10s%10s%10s%14s%10s%10s%10s%10s%10s%10s%10s%10s%10s%10s%11s%11s%30s\n',...
                        'Code','Freq','Last','Datetime','HH','LL','BS','SS','LvlUp','LvlDn','Jaw','Teeth','Lips','Signal','Kelly','WinP','SignalName');     
        end
        
        signal_i = obj.signals_m5_{i};
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
        
        dataformat = '%10s%10s%10.1f%14s%10.1f%10.1f%10d%10d%10.1f%10.1f%10.1f%10.1f%10.1f%10d%10.1f%%%10.1f%%%30s\n';
        
        fprintf(dataformat,obj.codes_{i},...
            'm5',...
            obj.ei_m5_{i}.px(end,5),...
            datestr(obj.ei_m5_{i}.px(end,1),'dd-mmm HH:MM'),...
            obj.ei_m5_{i}.hh(end),...
            obj.ei_m5_{i}.ll(end),...
            obj.ei_m5_{i}.bs(end),...
            obj.ei_m5_{i}.ss(end),...
            obj.ei_m5_{i}.lvlup(end),...
            obj.ei_m5_{i}.lvldn(end),...
            obj.ei_m5_{i}.jaw(end),...
            obj.ei_m5_{i}.teeth(end),...
            obj.ei_m5_{i}.lips(end),...
            signal_direction,...
            signal_kelly*100,...
            signal_wprob*100,...
            signal_name);
        
    end
    
    
end