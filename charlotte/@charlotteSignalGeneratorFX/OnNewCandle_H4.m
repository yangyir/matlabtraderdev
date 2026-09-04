function [] = OnNewCandle_H4(obj,~,eventData)
% a charlotteSignalGeneratorFX method
    try
        data = eventData.MarketData;
        ncodes = size(obj.codes_,1);
        
        newSignals = zeros(ncodes,1);
        for i = 1:ncodes
            freq_i = obj.freqs_{i};
            if ~strcmpi(freq_i,'h4')
                continue;
            end
            data_i = data{i};
            extrainfo_new = data_i.extrainfo;
            p_new = data_i.time;
            if p_new > obj.extrainfo_{i}.px(end,1)
                obj.extrainfo_{i} = extrainfo_new;
            end
            %
            obj.signals_{i} = obj.genSignal(obj.codes_{i},obj.freqs_{i},data_i.mode);
            if ~isempty(obj.signals_{i})
                newSignals(i) = 1;
            end
        end
        
        nsignal = sum(newSignals);
        
        if nsignal > 0
            data = struct('signals',{obj.signals_},...
                'extrainfo',{obj.extrainfo_},...
                'codes_',{obj.codes_},...
                'freqs_',{obj.freqs_},...
                'newsignals',{newSignals},...
                'modes',data_i.mode);
            notify(obj,'NewSignalGenerated',charlotteDataFeedEventData(data));
        end
        
    catch ME
        msg = ['charlotteSignalGeneratorFX:OnNewCandle_H1:',ME.message];
        error(msg);
    end
    

    
end