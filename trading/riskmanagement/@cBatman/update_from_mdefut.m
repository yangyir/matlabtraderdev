function [] = update_from_mdefut(obj,mdefut)
    if ~isa(mdefut,'cMDEFut')
        error('cBatman:update_from_mdefut:invalid mdefut input');
    end
    %1.¼ì²éBatmanµÄ×´Ì¬
    if strcmpi(obj.status_,'closed'), return; end

    lasttick = mdefut.getlasttick(obj.code_);
    
    update_from_tick(obj,lasttick);
    
end