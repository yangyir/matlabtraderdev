function [ret,trade] = hasSpecialTrade(obj,condsignal,eisignal)
% a charlotteTraderFX method
% to identify whether special trade has already been placed
    ret = 0;
    trade = [];
    
    freq = condsignal.frequency;
    code = condsignal.code;
    direction = condsignal.directionkellied;
    
    % note that all the special trade has marked the same open time which 
    % is the last bar time of the signal bar
    nspecialtrades = obj.specialbook_.latest_;
    for i = 1:nspecialtrades
        trade_i = obj.specialbook_.node_(i);
        if strcmpi(trade_i.status_,'closed'), continue;end
        if strcmpi(trade_i.riskmanager_.status_,'closed'),continue;end
        if strcmpi(trade_i.code_,code) && ...
                strcmpi(trade_i.opensignal_.frequency_,freq) && ...
                sign(trade_i.opendirection_) == direction && ...
                abs(trade_i.opendatetime1_ - eisignal.px(end,1)) < 1/1440
            ret = 1;
            trade = trade_i;
            break
        end
    end
end