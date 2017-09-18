function [ret] = withdrawentrust(counter,entrust)
%note:this function is a wrapper which accepts different data types in
%which the entrust_id is included.

    if ~isa(counter,'CounterCTP')
        error('withdrawentrust:invalid ctp counter input')
    end
    
    if isa(entrust,'Entrust')
        entrust_id = entrust.entrustId;
    elseif isstruct(entrust);
        entrust_id = entrust.entrust_id;
    elseif isnumeric(entrust)
        entrust_id = entrust;
    else
        error('withdrawentrust:invalid entrust(id) input')
    end
    
    counter_id = counter.counterId;
    ret = withdrawoptentrust(counter_id,entrust_id);
    %note: ret == 1 indicates the entrust is successfully withdrawn and
    %vice verse.
    
    if ret ~= 1
        warning(['entrust with id ',num2str(entrust_id),' not withdrawed!'])
    end
    
end