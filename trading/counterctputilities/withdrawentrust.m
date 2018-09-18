function [ret] = withdrawentrust(counter,entrust)
%note:this function is a wrapper which accepts different data types in
%which the entrust_id is included.

    if ~(isa(counter,'CounterCTP') || isa(counter,'cCounterRH'))
        error('withdrawentrust:invalid counter input:either a CTP counter or a RH counter')
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
    if isa(counter,'CounterCTP')
        ret = withdrawoptentrust(counter_id,entrust_id);
    elseif isa(counter,'cCounterRH')
        ret = rh_counter_withdrawoptentrust(counter_id,entrust_id);
    %note: ret == 1 indicates the entrust is successfully withdrawn and
    %vice verse.
    
    if ret ~= 1
        warning(['entrust with id ',num2str(entrust_id),' not withdrawed!'])
%     else
%         fprintf(['entrust ',num2str(entrust.entrustNo),' withdrawed!\n']);
    end
    
end