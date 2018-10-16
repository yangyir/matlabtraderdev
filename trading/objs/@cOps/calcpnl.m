function pnl = calcpnl(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Code','all',@ischar);
    p.parse(varargin{:});
    codestr = p.Results.Code;
    
    if ~strcmpi(codestr,'all')
        instrumentstrs = regexp(codestr,',','split');
        n = length(instrumentstrs);
        pnl = zeros(n,2);
        for i = 1:n
            [flong,idxlong] = obj.book_.haslongposition(instrumentstrs{i});
            if flong && idxlong > 0
                pnl(i,1) = obj.book_.positions_{idxlong}.calc_pnl(varargin{:});
            end
            %
            [fshort,idxshort] = obj.book_.hasshortposition(instrumentstrs{i});
            if fshort && idxshort > 0
                pnl(i,2) = obj.book_.positions_{idxshort}.calc_pnl(varargin{:});
            end
        end
        return
        
    end
    
    n = size(obj.book_.positions_,1);
    instrumentstrs = cell(n,1);
    for i = 1:n
        instrumentstrs{i} = obj.book_.positions_{i}.code_ctp_;
    end
    instrumentstrs = unique(instrumentstrs);
    n = size(instrumentstrs,1);
    pnl = zeros(n,2);
    for i = 1:n
        [flong,idxlong] = obj.book_.haslongposition(instrumentstrs{i});
        if flong && idxlong > 0
            pnl(i,1) = obj.book_.positions_{idxlong}.calc_pnl(varargin{:});
        end
        %
        [fshort,idxshort] = obj.book_.hasshortposition(instrumentstrs{i});
        if fshort && idxshort > 0
            pnl(i,2) = obj.book_.positions_{idxshort}.calc_pnl(varargin{:});
        end
    end
    
end