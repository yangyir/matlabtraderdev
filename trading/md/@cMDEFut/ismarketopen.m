function [ret] = ismarketopen(mdefut,varargin)
%cMDEFut
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('time',now,@isnumeric);
    p.parse(varargin{:});
    t = p.Results.time;
    
    n = mdefut.qms_.instruments_.count;
    
    ret = zeros(n,1);
    
    for i = 1:n
        dtnum_open = mdefut.datenum_open_{i};
        dtnum_close = mdefut.datenum_close_{i};
        for j = 1:size(dtnum_open,1)
            if t >= dtnum_open(j) && t <= dtnum_close(j)
                ret(i) = 1;
                break
            end
        end
    end
    
    
end