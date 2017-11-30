function [wr,wrts] = getlastwr(strategy,instrument)
    if ~isa(instrument,'cInstrument')
        error('cStratFutMultiWR:getlastwr:invalid instrument input')
    end
    wrts = strategy.mde_fut_.calc_technical_indicators(instrument);
    wr = wrts(end);
end
%end of getlastwr