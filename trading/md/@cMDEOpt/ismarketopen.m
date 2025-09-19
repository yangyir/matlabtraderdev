function [ret] = ismarketopen(mdeopt,varargin)
% a cMDEOpt function
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('time',now,@isnumeric);
    p.parse(varargin{:});
    t = p.Results.time;
    
    ret = 0;
    for j = 1:size(mdeopt.datenum_open_,1)
        if t >= mdeopt.datenum_open_(j) && t <= mdeopt.datenum_close_(j)
            ret = 1;
            break
        end
    end
    
    
    
end