function [obj] = table2tradeopen2(obj,headers,data)
    if length(headers) ~= length(data)
        error('cTradeOpen:table2tradeopen2:mismatch between size of headers and data')
    end

    className = class(obj);
    eval(['obj = ' className ';' ]);
    
    idxsignal = -1;
    idxrisk = -1;
    
    for i = 1:length(headers)
        if strcmpi(headers{i},'opensignalpropnames_')
            idxsignal = i;
            break
        end
    end
    
    for i = 1:length(headers)
        if strcmpi(headers{i},'riskmanagerpropnames_')
            idxrisk = i;
            break
        end
    end
    
    for i = 1:length(headers)
        if i ~= idxsignal && i ~= idxsignal+1 && ...
                i ~= idxrisk && i ~= idxrisk+1
            if ~isempty(strfind(headers{i},'datetime2_'))
                continue;
            end
            if ~isempty(strfind(headers{i},'closestr'))
                continue;
            end
            if ~isempty(strfind(headers{i},'oneminb4close2_'))
                if ~isempty(data{i}) && ~strcmpi(data{i},'NaN')
                    obj.(headers{i}) = data{i};
                else
                    obj.(headers{i}) = NaN;
                end
                continue;
            end
            if ~isempty(strfind(headers{i},'oneminb4close1_'))
                if ~isempty(data{i}) && ~strcmpi(data{i},'NaN')
                    obj.(headers{i}) = data{i};
                else
                    obj.(headers{i}) = NaN;
                end
                continue;
            end
            if isempty(data{i})
                continue;
            end
            obj.(headers{i}) = data{i};
        end
    end
    
    if idxsignal > 0
        names = data{idxsignal};
        values = data{idxsignal+1};
        proplist = regexp(names,';','split');
        vallist = regexp(values,';','split');
        if length(proplist) ~= length(vallist)
            error('cTradeOpen:table2tradeopen2:mismatch between properties and values of open signal info')
        end
        for k = 1:length(proplist)
            if strcmpi(proplist{k},'name_')
                opensignal_name = vallist{k};
                break
            end
        end
        if strcmpi(opensignal_name,'WilliamsR')
            signal = cWilliamsRInfo;
        elseif strcmpi(opensignal_name,'TDSQ')
            signal = cTDSQInfo;
        elseif strcmpi(opensignal_name,'Fractal')
            signal = cFractalInfo;
        elseif strcmpi(opensignal_name,'Manual')
            signal = cManualInfo;
        else
            error('cTradeOpen:table2tradeopen2:%s signal name not supported',opensignal_name)
        end
        
        for k = 1:length(proplist)
            if isempty(proplist{k}),continue;end
            if strcmpi(proplist{k},'name_'), continue;end
            if ~isnan(str2double(vallist{k}))
                signal.(proplist{k}) = str2double(vallist{k});
            else
                signal.(proplist{k}) = vallist{k};
            end
        end
        obj.opensignal_ = signal;
    end
    %
    %
    
    if idxrisk > 0
        names = data{idxrisk};
        values = data{idxrisk+1};
        proplist = regexp(names,';','split');
        vallist = regexp(values,';','split');
        if length(proplist) ~= length(vallist)
            error('cTradeOpen:table2tradeopen2:mismatch between properties and values of risk manager info')
        end
        
        riskmanager_name = '';
        for k = 1:length(proplist)
            if strcmpi(proplist{k},'name_')
                riskmanager_name = vallist{k};
                break
            end
        end
        
        if ~isempty(riskmanager_name)
            if ~(strcmpi(riskmanager_name,'standard') || ...
                    strcmpi(riskmanager_name,'batman') || ...
                    strcmpi(riskmanager_name,'wrstep') || ...
                    strcmpi(riskmanager_name,'stairs') || ...
                    strcmpi(riskmanager_name,'spiderman'))
                error('cTradeOpen:table2tradeopen2:%s risk manager type not implemented',riskmanager_name);
            end

            riskmangerinfo = struct;
            for k = 1:length(proplist)
                if isempty(proplist{k}),continue;end
                if strcmpi(proplist{k},'name_'), continue;end
                if ~isnan(str2double(vallist{k}))
                    riskmangerinfo.(proplist{k}) = str2double(vallist{k});
                else
                    riskmangerinfo.(proplist{k}) = vallist{k};
                end
            end
            obj.setriskmanager('name',riskmanager_name,'extrainfo',riskmangerinfo);
        end
        
    end
    
    
    
    
    

    
    
    
end