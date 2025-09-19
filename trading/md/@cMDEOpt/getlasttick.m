function tick = getlasttick(mdeopt,instrument)
% a cMDEOpt function
    if ischar(instrument)
        code_ctp = instrument;
    elseif isa(instrument,'cInstrument')
        code_ctp = instrument.code_ctp;
    else
        error('%s:getlasttick:invalid instrument input',class(mdeopt))
    end

    instruments = mdeopt.qms_.instruments_.getinstrument;
    ns = size(instruments,1);
    flag = false;
    for i = 1:ns
        if strcmpi(code_ctp,instruments{i}.code_ctp)
            flag = true;
            try
                tick = mdeopt.ticksquick_(i,:);
            catch
                tick = [];
            end
            break
        end
    end

    if ~flag
        error('%s:getlaststick:instrument %s not found',class(mdeopt),code_ctp)
    end
end
%end of getlasttick
