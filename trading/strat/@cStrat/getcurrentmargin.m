function val = getcurrentmargin(obj)
%cStrat
%return margin of all exisiting positions
    if isa(obj,'cStratOptMultiFractal')
        positions = obj.helper_.book_.positions_;
        val = 0;
        for i = 1:size(positions,1)
            pos = positions{i};
            volume = pos.position_total_;
            ticksize = pos.instrument_.tick_size;
            tickvalue = pos.instrument_.tick_value;
            tick = obj.mde_opt_.getlasttick(pos.instrument_);
            if isempty(tick)
                price = pos.cost_open_;
            else
                if abs(tick(2)) > 1e10
                    price = pos.cost_open_;
                else
                    price = tick(2);
                end
            end
            if pos.is_opt_
                val = val + price*volume/ticksize*tickvalue;
            else
                marginrate = pos.instrument_.init_margin_rate;
                val = val + price*volume*marginrate/ticksize*tickvalue;
            end
        end
    else
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
end