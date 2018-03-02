function ret = registerinstruments(obj,instrumentstr)
    if ~ischar(instrumentstr)
        error('cTraderMaster:registerinstruments:invalid string input')
    end
    
    instrs = regexp(instrumentstr,';','split');
    n = size(instrs,2);
    
    for i = 1:n
        isopt = isoptchar(instrs{i});
        if isopt
            sec = cOption(instrs{i});
        else
            sec = cFutures(instrs{i});
        end
        sec.loadinfo([instrs{i},'_info.txt']);
        obj.registerinstrument(sec);
    end
    
    ret = 1;
    
end