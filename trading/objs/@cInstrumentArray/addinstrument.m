function [] = addinstrument(obj,instrument)
    if ~obj.isvalid, return; end
    bool = obj.hasinstrument(instrument);
    if ~bool
        n = obj.count;
        list = cell(n+1,1);
        list{n+1,1} = instrument;

        for i = 1:n
            list{i,1} = obj.list_{i,1};    
        end
        obj.list_ = list; 
    end
end
%end of addinstrument