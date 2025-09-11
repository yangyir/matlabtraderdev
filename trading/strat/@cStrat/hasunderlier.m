function [flag,idx] = hasunderlier(obj,underlier)
%cStrat
    [flag,idx] = obj.underliers_.hasinstrument(underlier);

end
%end of hasunderlier