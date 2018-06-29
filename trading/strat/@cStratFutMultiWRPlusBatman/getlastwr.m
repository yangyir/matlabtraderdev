function [wr,wrts] = getlastwr(obj,instrument)
    if ~(isa(instrument,'cInstrument') || ischar(instrument)) 
        error('cStratFutMultiWRPlusBatman:getlastwr:invalid instrument input')
    end
    wrts = obj.mde_fut_.calc_technical_indicators(instrument);
    wr = wrts(end);
end
%end of getlastwr