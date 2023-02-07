function [data,headers] = tradeopen2table2(obj)
%note:cTradeOpen
%new format compared to old format in function 'tradeopen2table'
%since we shall have trades with different opensignal and risk management
%approach whereas they are saved in the same file at the same time, we
%propose a generic format as required
%the generic format shall be 'opensignalpropnames';
%'opensignalpropvalues';'riskmanagerpropnames';'riskmanagerpropvalues'
    flds = properties(obj);
    nflds = length(flds);
    
    data = cell(nflds-1,1);
    headers = cell(nflds-1,1);
    ncols = 0;
    
    for i = 1:nflds
        propname = flds{i};
        if strcmpi(propname,'instrument_')
            continue
        elseif strcmpi(propname,'opensignal_') || strcmpi(propname,'riskmanager_')
            propvalue = obj.(propname);
            if isempty(propvalue)
                ncols = ncols + 1;
                headers{ncols} = [propname(1:end-1),'propnames_'];
                data{ncols} = '';
                ncols = ncols + 1;
                headers{ncols} = [propname(1:end-1),'propvalues_'];
                data{ncols} = '';
            else
                ncols = ncols + 1;
                headers{ncols} = [propname(1:end-1),'propnames_'];
                flds_info = properties(propvalue);
                propnames = '';
                propvalues = '';
                for j = 1:size(flds_info,1)
                    if strcmpi(flds_info{j},'trade_'),continue;end
                    val = propvalue.(flds_info{j});
                    if j < size(flds_info,1)
                        tmp = [propnames,flds_info{j},';'];
                        propnames = tmp;
                        if isnumeric(val)
                            tmp = [propvalues,num2str(val),';'];
                        elseif islogical(val)
                            if val
                                tmp = [propvalues,num2str(1),';'];
                            else
                                tmp = [propvalues,num2str(0),';'];
                            end
                        else
                            tmp = [propvalues,val,';'];
                        end
                        propvalues = tmp;
                    else
                        tmp = [propnames,flds_info{j}];
                        propnames = tmp;
                        if isnumeric(val)
                            tmp = [propvalues,num2str(val)];
                        else
                            tmp = [propvalues,val];
                        end
                        propvalues = tmp;
                    end
                end
                data{ncols} = propnames;
                ncols = ncols + 1;
                headers{ncols} =[propname(1:end-1),'propvalues_'];
                data{ncols} = propvalues;              
            end
        else
            ncols = ncols + 1;
            headers{ncols} = propname;
            propvalue = obj.(propname);
            data{ncols} = propvalue;
        end
        
        
    end
    
    
end