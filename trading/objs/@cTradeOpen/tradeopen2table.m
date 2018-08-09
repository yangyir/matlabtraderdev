function [data,headers] = tradeopen2table(obj)
    flds = properties(obj);
    nflds = length(flds);
    
    data = cell(nflds-1,1);
    headers = cell(nflds-1,1);
    ncols = 0;
    
    for i = 1:nflds
        propname = flds{i};
        if strcmpi(propname,'instrument_'), continue;end
        propvalue = obj.(propname);
        ncols = ncols + 1;
        headers{ncols} = propname;
        
        if strcmpi(propname,'opensignal_');
            if isempty(propvalue)
                data{ncols} = '';
            else
                flds_info = properties(propvalue);
                header_i = '';
                data_i = '';
                for j = 1:size(flds_info,1)
                    tmp1 = [header_i,'opensignal_',flds_info{j},';'];
                    header_i = tmp1;
                    val = propvalue.(flds_info{j});
                    if isnumeric(val)
                        tmp2 = [data_i,num2str(val),';'];
                    elseif ischar(val)
                        tmp2 = [data_i,val,';'];
                    else
                        error('data type not supported')
                    end
                    data_i = tmp2;
                end
                headers{ncols} = header_i;
                data{ncols} = data_i;
            end          
        elseif strcmpi(propname,'riskmanager_');
            if isempty(propvalue)
                data{ncols} = '';
            else
                flds_info = properties(propvalue);
                header_i = '';
                data_i = '';
                for j = 1:size(flds_info,1)
                    val = propvalue.(flds_info{j});
                    if isa(val,'cTradeOpen'), continue; end
                    tmp1 = [header_i,'riskmanager_',flds_info{j},';'];
                    header_i = tmp1;
                    if isnumeric(val)
                        tmp2 = [data_i,num2str(val),';'];
                    elseif ischar(val)
                        tmp2 = [data_i,val,';'];
                    else
                        error('data type not supported')
                    end
                    data_i = tmp2;
                end
                headers{ncols} = header_i;
                data{ncols} = data_i;
            end
        else
            data{ncols} = propvalue;
        end
    end
    
    
end