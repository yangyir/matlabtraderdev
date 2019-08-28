function [ bsout,ssout,lvlupout,lvldnout ] = tdsq_piecewise_setup( data,bsin,ssin,lvlupin,lvldnin)
%TDSQ_PIECEWISE_SETUP Summary of this function goes here
%   Detailed explanation goes here
%     p = inputParser;
%     p.CaseSensitive = false;p.KeepUnmatched = true;
%     p.addParameter('Lag',4,@isnumeric);
%     p.addParameter('Consecutive',9,@isnumeric);
%     p.parse(varargin{:});
    nLag = 4;
    nConsecutive = 9;
    
    np = size(data,1);
    nbs = size(bsin,1);
    if np - nbs ~= 1, error('tdsq_piecewise:invalid input');end
    
    try
        if bsin(end) > 0 
            if data(np,end) < data(np-nLag,end)
                bsout = [bsin;bsin(end)+1];
                ssout = [ssin;0];    
            end
        else
            if data(np-1,end) >= data(np-1-nLag,end) && data(np,end) < data(np-nLag,end)
                bsout = [bsin;1];
                ssout = [ssin;0];
            end
        end
        %
        if ssin(end) > 0
            if data(np,end) > data(np-nLag,end)
                bsout = [bsin;0];
                ssout = [ssin;ssin(end)+1];
            end
        else
            if data(np-1,end) <= data(np-1-nLag,end) && data(np,end) > data(np-nLag,end)
                bsout = [bsin;0];
                ssout = [ssin;1];
            end
        end
        %
        if bsout(end) == nConsecutive
            newlvlup = max(data(np-nConsecutive+1:np,3));
            lvlupout = [lvlupin;newlvlup];
        else
            lvlupout = [lvlupin;lvlupin(end)];
        end
        %
        if ssout(end) == nConsecutive
            newlvldn = min(data(np-nConsecutive+1:np,4));
            lvldnout = [lvldnin;newlvldn];
        else
            lvldnout = [lvldnin;lvldnin(end)];
        end
    catch
        bsout = [bsin;0];
        ssout = [ssin;0];
        lvlupout = [lvlupin;lvlupin(end)];
        lvldnout = [lvldnin;lvldnin(end)];
    end

end

