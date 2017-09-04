function codenum = exchangenum(codestr)
    if strcmpi(codestr,'.CFE') || strcmpi(codestr,'CFE') || ...
            strcmpi(codestr,'.CFFEX') || strcmpi(codestr,'CFFEX')
        try
            codenum = double(ExchangeType.CFFEX);
        catch
            codenum = 4;
        end
    elseif strcmpi(codestr,'.CZC') || strcmpi(codestr,'CZC') || ...
            strcmpi(codestr,'.CZCE') || strcmpi(codestr,'CZCE') 
        try
            codenum = double(ExchangeType.CZCE);
        catch
            codenum = 5;
        end
    elseif strcmpi(codestr,'.DCE') || strcmpi(codestr,'DCE') 
        try
            codenum = double(ExchangeType.DCE);
        catch
            codenum = 6;
        end
    elseif strcmpi(codestr,'.SHF') || strcmpi(codestr,'SHF') || ...
            strcmpi(codestr,'.SHFE') || strcmpi(codestr,'SHFE')
        try
            codenum = double(ExchangeType.SHFE);
        catch
            codenum = 7;
        end
    else
        error('exchangenum:exchange not supported')
    end
            
end



