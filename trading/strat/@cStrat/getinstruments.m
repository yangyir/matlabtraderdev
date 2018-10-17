function [instruments] = getinstruments(obj)
%cStrat
    if isempty(obj.instruments_)
        instruments = {};
    else
        instruments = obj.instruments_.getinstrument;
    end
end