function val = getcurrentmargin(obj)
%cStrat
%return margin of all exisiting positions
    instruments = obj.getinstruments;
    ninstruments = size(instruments,1);
    val = 0;
    for i = 1:ninstruments
        try
            [flag,idx] = obj.helper_.book_.hasposition(instruments{i});
            if flag
                pos = obj.helper_.book_.positions_{idx};
                volume = pos.position_total_;
                marginrate = instruments{i}.init_margin_rate;
                ticksize = instruments{i}.tick_size;
                tickvalue = instruments{i}.tick_value;
                tick = obj.mde_fut_.getlasttick(instruments{i});
                if isempty(tick)
                    price = pos.cost_open_;
                else
                    if abs(tick(2)) > 1e10
                        price = pos.cost_open_;
                    else
                        price = tick(2);
                    end
                end
                val = val + price*volume*marginrate/ticksize*tickvalue;
            else
                val = val + 0;
            end
        catch e
            fprintf('%s\n',e.message);
            val = val + 0;
        end
    end
end