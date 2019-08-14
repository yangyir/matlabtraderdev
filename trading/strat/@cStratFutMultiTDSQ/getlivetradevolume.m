function [volume] = getlivetradevolume(obj,code,modename,modetype)
    volume = 0;
    trades2check = obj.helper_.trades_.filterbycode(code);
    
    ntrade = otrades2check.latest_;
    
    for i = 1:ntrade
        trade_i = trades2check.node_(i);
        if ~strcmpi(trade_i,'closed')
            opensignal = trade_i.opensignal_;
            if ~isa(opensignal,'cTDSQInfo'), continue;end
            if strcmpi(modename,'reverse') && strcmpi(opensignal.reversetype_,modetype)
                volume = volume + trade_i.openvolume_;
            end
            if strcmpi(modename,'trend') && strcmpi(opensignal.trendtype_,modetype)
                volume = volume + trade_i.openvolume_*trade_i.opendirection_;
            end
        end
    end
end