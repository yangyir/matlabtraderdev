function [ret,trade] = hasShortPosition(obj,code)
    % a charlotteTraderFX function
    n = obj.book_.latest_;
    ret = false;
    trade = [];
    for i = 1:n
        trade_i = obj.book_.node_(i);
        if strcmpi(trade_i.code_,code) && trade_i.opendirection_ == -1 && ~strcmpi(trade_i.status_,'closed')
            ret = true;
            trade = trade_i;
            break
        end
    end
end