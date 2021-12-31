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
        code_ctp_{i} = codestr{i};
        if length(codestr{i}) == 6
            if strcmpi(codestr{i}(1),'6') || strcmpi(codestr{i}(1),'5')
                code_wind_{i} = [codestr{i},'.SH'];
            elseif strcmpi(codestr{i}(1),'0') || strcmpi(codestr{i}(1),'3') || strcmpi(codestr{i}(1),'1')
                code_wind_{i} = [codestr{i},'.SZ'];
            else
                error('cQuoteStock:unknown code......');
            end
        elseif length(codestr{i}) == 4
            code_wind_{i} = [codestr{i},'.HK'];
        else
            error('cQuoteStock:unknown or unsupported territory......');
        end
        code_bbg_{i} = 'n/a';
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