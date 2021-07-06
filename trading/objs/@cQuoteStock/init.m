function [] = init(obj,codestr)
%cQuoteStock
    if obj.init_flag && strcmpi(obj.code_wind,codestr)
        return
    end

    codestr = regexp(codestr,',','split');
    nleg = length(codestr);
    code_ctp_ = cell(nleg,1);
    code_wind_ = cell(nleg,1);
    code_bbg_ = cell(nleg,1);

    for i = 1:nleg
        code_ctp_{i} = codestr;
        code_wind_{i} = codestr;
        code_bbg_{i} = codestr;
    end

    if nleg == 1
        obj.code_ctp = code_ctp_{1};
        obj.code_wind = code_wind_{1};
        obj.code_bbg = code_bbg_{1};
    elseif nleg == 2
        obj.code_ctp = [code_ctp_{1},',',code_ctp_{2}];
        obj.code_wind = [code_wind_{1},',',code_wind_{2}];
        obj.code_bbg = [code_bbg_{1},',',code_bbg_{2}];
    else
        error('cQuoteStock:to be implemented for multiple legs')    
    end
    obj.init_flag = true;

end