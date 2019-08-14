function [trade] = getlivetrade_tdsq(obj,code,modename,typename)
    
    trades = obj.helper_.trades_;
    ntrades = trades.latest_;
    
    trade = [];
    for i = 1:ntrades
        trade_i = trades.node_(i);
        if strcmpi(trade_i.status_,'closed'), continue;end
        if ~strcmpi(trade_i.code_,code),continue;end
        if isempty(trade_i.opensignal_),continue;end
        if ~isa(trade_i.opensignal_,'cTDSQInfo'),continue;end
        opensignal = trade_i.opensignal_;
        if strcmpi(opensignal.mode_,modename) && strcmpi(opensignal.type_,typename)
            trade = trade_i;
            break
        end
    end
    
end