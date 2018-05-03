function [ret,entrusts] = cancelorders(obj,codestr,ops)
%cTrader
    variablenotused(obj);
    if ~ischar(codestr), error('cTrader:cancelorders:invalid code input');end
    if ~isa(ops,'cOps'), error('cTrader:cancelorders:invalid ops input');end
    
    c = ops.book_.counter_;
    pe = ops.entrustspending_;
    ret = 0;
    entrusts = EntrustArray;
    for i = 1:pe.latest
        e = ops.entrustspending_.node(i);
        if strcmpi(e.instrumentCode,codestr)
            if strcmpi(ops.mode_,'realtime')
                ret = withdrawentrust(c,e);
                entrusts.push(e);
            elseif strcmpi(ops.mode_,'replay')
                ops.entrustspending_.removeByIndex(i);
                entrusts.push(e);
            end
        end
    end
    if entrusts.latest > 0, ret = 1;end
    
end