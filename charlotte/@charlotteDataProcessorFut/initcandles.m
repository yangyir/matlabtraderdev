function [] = initcandles(obj,code)
% a charlotteDataProcessorFut function
    hh = hour(now);
    if hh < 2
        cobdate = today - 1;
    elseif hh  == 2
        mm = minute(now);
        if mm > 30
            cobdate = today;
        else
            cobdate = today - 1;
        end
    else
        cobdate = today;
    end

    ncodes = size(obj.codes_,1);
    for i = 1:ncodes
        fut_i = code2instrument(obj.codes_{i});
        buckets_m1 = getintradaybuckets2('date',cobdate,...
            'frequency','1m',...
            'tradinghours',fut_i.trading_hours,...
            'tradingbreak',fut_i.trading_break);
        
                    
    end
end