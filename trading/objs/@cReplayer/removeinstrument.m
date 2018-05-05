function [] = removeinstrument(obj,instrument)

    if isempty(obj.instruments_), return; end

    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    
    if ~flag,return;end
    
    n = obj.instruments_.count;
    if n == 1
        obj.tickdata_ = {};
    else
        tickdata = cell(n-1,1);
        count = 1;
        for i = 1:n
            if i ~= idx
                tickdata{count} = obj.tickdata_{i};
                count = count + 1;
            end
        end
    end
    
    obj.instruments_.removeinstrument(instrument);
    
    
    
end
%end of 'removeinstrument'