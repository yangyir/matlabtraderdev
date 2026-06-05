function instrument = code2instrument(codestr)
    
    warning off;
    if ~ischar(codestr)
        error('code2instrument:invalid code input')
    end
    
    isopt = isoptchar(codestr);
    if isopt
        instrument = cOption(codestr);
    else
        try
            instrument = cFutures(codestr);
        catch
            if isfx(codestr)
                instrument = cFX(codestr);
            elseif strcmpi(codestr,'AD') || strcmpi(codestr,'EC') || strcmpi(codestr,'BP') || ...
                    strcmpi(codestr,'CD') || strcmpi(codestr,'SF') || strcmpi(codestr,'JY') || strcmpi(codestr,'NE') || ...
                    strcmpi(codestr,'GC') || strcmpi(codestr,'SI') || ...
                    strcmpi(codestr,'NQ') || strcmpi(codestr,'ES')
                instrument = cFX(codestr);
            else
                instrument = cStock(codestr);
            end
        end
    end
    instrument.loadinfo([codestr,'_info.txt']);
end