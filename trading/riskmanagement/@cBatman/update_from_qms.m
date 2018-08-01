function [] = update_from_qms(obj,qms)
    if ~isa(mdefut,'cQMS')
        error('cBatman:update_from_qms:invalid cQMS input');
    end
    
    if strcmpi(obj.status_,'closed'), return; end
    
    instrument = code2instrument(obj.code_);
    quote = qms.getquote(instrument);
    tick = zeros(1,4);
    tick(1) = quote.update_time1;
    tick(2) = quote.bid1;
    tick(3) = quote.ask1;
    tick(4) = quote.last_trade;
    
    update_from_tick(obj,tick);
    
end