function tick = getlasttick(mdefut,instrument)
    if ischar(instrument)
        code_ctp = instrument;
    elseif isa(instrument,'cInstrument')
        code_ctp = instrument.code_ctp;
    else
        error('cMDEFut:getlasttick:invalid instrument input')
    end

    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);
    flag = false;
    for i = 1:ns
        if strcmpi(code_ctp,instruments{i}.code_ctp)
            flag = true;
            try
                ticks = mdefut.ticks_{i};
                if mdefut.ticks_count_(i) > 0
                    tick = ticks(mdefut.ticks_count_(i),:);
                else
                    tick = [];
                end
            catch
                tick = [];
            end
            break
        end
    end

    if ~flag
        error('cMDEFut:getlaststick:instrument %s not found',code_ctp)
    end
end
%end of getlasttick
