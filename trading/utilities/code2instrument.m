function instrument = code2instrument(codestr)
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
            else
                instrument = cStock(codestr);
            end
        end
    end
    instrument.loadinfo([codestr,'_info.txt']);
end