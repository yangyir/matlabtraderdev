function [] = removeinstrument(obj,instrument)
    if ~obj.isvalid, return; end
    [bool,idx] = obj.hasinstrument(instrument);
    if ~bool
        %a warning or error message shall be issued
        return;
    else
        n = obj.count;
        if n == 1
            obj.list_ = {};
        else
            list = cell(n-1,1);
            for i = 1:idx-1
                list{i,1} = obj.list_{i,1};
            end
            for i = idx+1:n
                list{i-1,1} = obj.list_{i,1};
            end
            obj.list_ = list;
        end

    end
end
%end of removeinstrument