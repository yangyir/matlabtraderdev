function [obj] = table2tradeopen(obj,headers,data)
    if length(headers) ~= length(data)
        error('cTradeOpen:table2tradeopen:mismatch between size of headers and data')
    end

    className = class(obj);
    eval(['obj = ' className ';' ]);
    for i = 1:length(headers)
        if ~isempty(strfind(headers{i},'opensignal_'))
            proplist = regexp(headers{i},';','split');
            vallist = regexp(data{i},';','split');
            if length(proplist) ~= length(vallist), error('cTradeOpen:table2tradeopen:mismatch between properties and values of open signal info');end
            opensignal_name = '';
            for k = 1:length(proplist)
                if strcmpi(proplist{k},'opensignal_name_')
                    opensignal_name = vallist{k};
                    break
                end
            end
            if isempty(opensignal_name), continue; end
            if ~(strcmpi(opensignal_name,'WilliamsR') || strcmpi(opensignal_name,'BatmanManual') ...
                    ||strcmpi(opensignal_name,'Manual'))
                error('cTradeOpen:table2tradeopen:%s signal type not implemented',opensignal_name);
            end
            
            if strcmpi(opensignal_name,'WilliamsR')
                signal = cWilliamsRInfo;
            elseif strcmpi(opensignal_name,'BatmanManual')
                signal = cBatmanManual;
            elseif strcmpi(opensignal_name,'Manual')
                signal = cSignalInfo;
            end
                
            for k = 1:length(proplist)
                if isempty(proplist{k}),continue;end
                if strcmpi(proplist{k},'opensignal_name_'), continue;end
                if ~isnan(str2double(vallist{k}))
                    signal.(proplist{k}(length('opensignal_')+1:end)) = str2double(vallist{k});
                else
                    signal.(proplist{k}(length('opensignal_')+1:end)) = vallist{k};
                end
            end
            obj.opensignal_ = signal;
            %
        elseif ~isempty(strfind(headers{i},'riskmanager_'))
            proplist = regexp(headers{i},';','split');
            vallist = regexp(data{i},';','split');
            if length(proplist) ~= length(vallist), error('cTradeOpen:table2tradeopen:mismatch between properties and values of risk manager info');end
            riskmanager_name = '';
            for k = 1:length(proplist)
                if strcmpi(proplist{k},'riskmanager_name_')
                    riskmanager_name = vallist{k};
                    break
                end
            end
            if isempty(riskmanager_name), continue; end
            if ~(strcmpi(riskmanager_name,'standard') || strcmpi(riskmanager_name,'batman'))
                error('cTradeOpen:table2tradeopen:%s risk manager type not implemented',riskmanager_name);
            end
            
            riskmangerinfo = struct;
            for k = 1:length(proplist)
                if isempty(proplist{k}),continue;end
                if strcmpi(proplist{k},'riskmanager_name_'), continue; end
                if ischar(vallist{k})
                    valnum = str2double(vallist{k});
                    if isnan(valnum)
                        riskmangerinfo.(proplist{k}(length('riskmanager_')+1:end)) = vallist{k};
                    else
                        riskmangerinfo.(proplist{k}(length('riskmanager_')+1:end)) = valnum;
                    end
                else
                    riskmangerinfo.(proplist{k}(length('riskmanager_')+1:end)) = vallist{k};
                end                
%                 if isnumchar(vallist{k})
%                     riskmangerinfo.(proplist{k}(length('riskmanager_')+1:end)) = str2double(vallist{k});
%                 else
%                     riskmangerinfo.(proplist{k}(length('riskmanager_')+1:end)) = vallist{k};
%                 end
            end
            obj.setriskmanager('name',riskmanager_name,'extrainfo',riskmangerinfo);
        elseif ~isempty(strfind(headers{i},'datetime2_'))
            continue;
        else
            if isempty(data{i}), continue;end
            obj.(headers{i}) = data{i};
        end
    end
    
    
    
end