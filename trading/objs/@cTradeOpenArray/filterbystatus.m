function [new] = filterbystatus(obj,status)
    if ~ischar(status)
        error('cTradeOpenArray:filterbystatus:invalid code input')
    end
    n = obj.count;
    new = feval(class(obj));
    for i = 1:n
        trade_i = obj.node_(i);
        if strcmpi(trade_i.status_,status)
            new.push(trade_i);
        end
    end
 
end
