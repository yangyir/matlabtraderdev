function pnl = calcrunningpnl(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Code','all',@ischar);
    p.parse(varargin{:});
    codestr = p.Results.Code;
    
    if ~strcmpi(codestr,'all')
        instrumentstrs = regexp(codestr,',','split');
        n = length(instrumentstrs);
    else
        n = size(obj.book_.positions_,1);
        instrumentstrs = cell(n,1);
        for i = 1:n
            instrumentstrs{i} = obj.book_.positions_{i}.code_ctp_;
        end
    end
    
    pnl = zeros(n,1);
    for i = 1:n
        pnl(i) = pos.cal_pnl(varargin{:});
    end
    
end