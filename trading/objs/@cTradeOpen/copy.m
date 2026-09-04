function [newtrade] = copy(obj)
    newtrade = eval(class(obj));
    propnames = properties(obj);
    for i = 1:size(propnames,1)
        if strcmpi(propnames{i},'opendatetime2_')
            continue
        elseif strcmpi(propnames{i},'stopdatetime2_')
            continue
        elseif strcmpi(propnames{i},'closedatetime2_')
            continue
        elseif strcmpi(propnames{i},'instrument_')
            continue
        elseif strcmpi(propnames{i},'closestr_')
            continue
        elseif strcmpi(propnames{i},'riskmanager_')
            continue;
        elseif strcmpi(propnames{i},'opensignal_')
            os1 = obj.opensignal_;
            os2 = eval(class(os1));
            os_propnames = properties(os1);
            for j = 1:size(os_propnames,1)
                os2.(os_propnames{j}) = os1.(os_propnames{j});
                newtrade.opensignal_ = os2;
            end
        else
            newtrade.(propnames{i}) = obj.(propnames{i});
        end
    end
    %
    % special treatment for riskmanger_ property
    
    rm1 = obj.riskmanager_;
    rm2 = struct('info','newrm');
    rm_propnames = properties(rm1);
    for j = 1:size(rm_propnames,1)
        if strcmpi(rm_propnames{j},'trade_')
            continue;
        end
        rm2.(rm_propnames{j}) = rm1.(rm_propnames{j});
    end
    newtrade.setriskmanager('name','spiderman','extrainfo',rm2);
end