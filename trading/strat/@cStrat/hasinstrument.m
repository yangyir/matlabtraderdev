function [flag,idx] = hasinstrument(obj,instrument)
%cStrat
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
end