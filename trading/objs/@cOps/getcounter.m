function counter = getcounter(obj)
%cOps
    if strcmpi(obj.countertype_,'unknown')
        counter = [];
    elseif strcmpi(obj.countertype_,'ctp')
        counter = obj.counterCTP_;
    elseif strcmpi(obj.countertype_,'o32')
        counter = obj.counterHSO32_;
    elseif strcmpi(obj.countertype_,'rh')
        counter = obj.counterRH_;
    else
        error('cOps:getcounter:internal error')
    end
end