function codestr = exchangestr(codenum)
    if codenum == 4
        codestr = '.CFE';
    elseif codenum == 5
        codestr = '.CZC';
    elseif codenum == 6
        codestr = '.DCE';
    elseif codenum == 7
        codestr = '.SHF';
    else
        error('exchangestr:exchange not supported')
    end

end



