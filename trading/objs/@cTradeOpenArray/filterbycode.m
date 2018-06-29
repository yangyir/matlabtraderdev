function [new] = filterbycode(obj,code)
    if ~ischar(code)
        error('cTradeOpenArray:filterbycode:invalid code input')
    end
    n = obj.count;
    new = feval(class(obj));
    for i = 1:n
        trade_i = obj.node_(i);
        if strcmpi(trade_i.code_,code)
            new.push(trade_i);
        end
    end
 
end
