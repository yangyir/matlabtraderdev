function [] = registerinstrument(obj,instrument)
    if ~(ischar(instrument) || isa(instrument,'cInstrument'))
        error('cStratFutMultiWRPlusBatman:registerinstrument:invalid data type of instrument')
    end
    %registerinstrument of superclass
    registerinstrument@cStrat(obj,instrument);
    
    %highest of nperiods
    if isempty(obj.highnperiods_)
        obj.highnperiods_ = NaN(obj.count,1);
    else
        if size(obj.highnperiods_,1) < obj.count
            obj.highnperiods_ = [obj.highnperiods_;NaN];
        end
    end
    
    %lowest of nperiods
    if isempty(obj.lownperiods_)
        obj.lownperiods_ = NaN(obj.count,1);
    else
        if size(obj.lownperiods_,1) < obj.count
            obj.lownperiods_ = [obj.lownperiods_;NaN];
        end
    end
    
end