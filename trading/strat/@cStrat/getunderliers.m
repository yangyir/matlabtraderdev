function [underliers] = getunderliers(obj)
%cStrat
    if isempty(obj.underliers_)
        underliers = {};
    else
        underliers = obj.underliers_.getinstrument;
    end
end