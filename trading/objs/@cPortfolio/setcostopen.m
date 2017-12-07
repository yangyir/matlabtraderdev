function [] = setcostopen(port,instrument,cost_open)
    [flag,idx] = port.hasposition(instrument);
    if ~flag
        return
    end
    port.pos_list{idx}.cost_open_ = cost_open;
end