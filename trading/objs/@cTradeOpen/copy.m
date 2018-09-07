function [newtrade] = copy(obj)
    newtrade = eval(class(obj));
    propnames = properties(obj);
    for i = 1:size(propnames)
        if strcmpi(propnames{i},'opendatetime2_')
            continue
        elseif strcmpi(propnames{i},'stopdatetime2_')
            continue
        elseif strcmpi(propnames{i},'closedatetime2_')
            continue
        elseif strcmpi(propnames{i},'instrument_')
            continue
        else
            newtrade.(propnames{i}) = obj.(propnames{i});
        end
    end
end