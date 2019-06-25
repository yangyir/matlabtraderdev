function data = realtime(obj,instruments,fields)
    %note fields are not used here
    variablenotused(fields);
    if ~obj.isconnected_
        data = {};
        return
    end

    if isa(instruments,'cInstrument')
%         [mkt, level, updatetime] = getoptquote(instruments.code_ctp);
        %20190613:code change due to regulatory issue
        [mkt, level, updatetime] = getoptquote(obj.loginid_,instruments.code_ctp);
        data = cell(1,1);
        data{1} = struct('mkt',mkt,'level',level,'updatetime',updatetime);
    elseif iscell(instruments)
        n = length(instruments);
        data = cell(n,1);
        for i = 1:n
            if isa(instruments,'cInstrument')
                [mkt, level, updatetime] = getoptquote(obj.loginid_,instruments{i}.code_ctp);
            else
                [mkt, level, updatetime] = getoptquote(obj.loginid_,instruments{i});
            end
            data{i} = struct('mkt',mkt,'level',level,'updatetime',updatetime);
        end
    else
        [mkt, level, updatetime] = getoptquote(obj.loginid_,num2str(instruments));
        data = cell(1,1);
        data{1} = struct('mkt',mkt,'level',level,'updatetime',updatetime);
    end
end
%end of realtime