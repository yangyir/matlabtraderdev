function pnl = runningpnl(obj,quotes)
    n = obj.count;
    pnl = 0;
    for i = 1:n
        instr_i = obj.instrument_list{i}; 
        code_i = instr_i.code_ctp;
        tick_value_i = instr_i.tick_value;
        tick_size_i = instr_i.tick_size;
        volume_i = obj.instrument_volume(i);
        cost_i = obj.instrument_avgcost(i);
        if volume_i ~= 0
            flag = false;
            for j = 1:size(quotes,1)
                q = quotes{j};
                if strcmpi(code_i,q.code_ctp)
                    pnl = pnl + (q.last_trade-cost_i)/tick_size_i*tick_value_i*volume_i;
                    flag = true;
                    break
                end
            end
            if ~flag
                error(['missing quote for ',code_i])
            end
        end

    end
end
%end of runningpnl