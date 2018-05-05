function instrument = code2instrument(codestr)
    if ~ischar(codestr)
        error('code2instrument:invalid code input')
    end
    
    isopt = isoptchar(codestr);
    if isopt
        instrument = cOption(codestr);
    else
        instrument = cFutures(codestr);
    end
    instrument.loadinfo([codestr,'_info.txt']);
end