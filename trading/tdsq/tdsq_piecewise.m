function [bsout,ssout,lvlupout,lvldnout,bcout,scout] = tdsq_piecewise(data,bsin,ssin,lvlupin,lvldnin,bcin,scin,varargin)
%TDSQ_STEPBYSTEP Summary of this function goes here
%   Detailed explanation goes here
%   Calculate TD Sequential variables in a piecewise approach
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Lag',4,@isnumeric);
    p.addParameter('Consecutive',9,@isnumeric);
    p.parse(varargin{:});
    nLag = p.Results.Lag;
    nConsecutive = p.Results.Consecutive;
    
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
    
    try
        %
        bcout = [bcin;NaN];
        scout = [scin;NaN];
        idxbs_latest = find(bsout == 9,1,'last');
        idxss_latest = find(ssout == 9,1,'last');
        
        buycount = 0;
        for j = idxbs_latest:np
            %after TD Buy Setup is in place, look for the initiation of
            %a TD Buy Countdown if the current bar has a close less
            %than, or equal to the low two bars earlier
            
            %first to introduce filters that cancel a developing TD Buy
            %Countdown
            %1.if the price action rallies and generates a TD Sell
            %Setup
            if ssout(j) == nConsecutive, break; end
            
            %2.or the market trades higher and posts a true low above
            %the true high of the prior TD Buy Setup - that is TDST
            %resisitence
            if ~isnan(lvlupout(j)) && lvlupout(j) < data(j,4), break;end
            
            if data(j,5) <= data(j-2,4)
                if ~isnan(bcout(j)) && bcout(j) <= 13
                    %note;here we keep counting in seperate sequence
                    %NEED TO CHECK with paper again
                    buycount = buycount + 1;
                    continue;
                end
                
                if buycount < 12
                    buycount = buycount + 1;
                    bcout(j) = buycount;
                else
                    %to complete a TD buy countdown the low of TD Buy
                    %Countdown bar thirteen must be less than, or equal
                    %to, the close of TD Buy Countdown bar eight
                    idx8 = find(bcout(idxbs_latest:j) == 8);
                    idx8 = idx8 + idxbs_latest-1;
                    close8 = data(idx8,5);
                    if data(j,4) <= close8
                        buycount = buycount + 1;
                        bcout(j) = buycount;
                        break
                    else
                        continue;
                    end
                end
                
                if bcout(j) == 13
                    break
                end
            end
        end
        %
        %
        sellcount = 0;
        for j = idxss_latest:np
            %after TD Sell Setup is in place, look for the initiation
            %of a TD Sell Countdown if the current bar has a close
            %greater than or equal to the high two bars earlier
            
            %first to introduce filters that cancel a developing TD
            %Sell Countdown
            %1.if the price action rallies and generates a TD Buy
            %Setup
            
            if bsout(j) == nConsecutive, break; end
            
            %2.or the market trades lower and posts a true high below
            %the true low of the prior TD Sell Setup - that is TDST
            %support
            if ~isnan(lvldnout(j)) && lvldnout(j) > data(j,3)
                break;
            end
            
            if data(j,5) >= data(j-2,3)
                if ~isnan(scout(j)) && scout(j) <= 13
                    %note;here we keep counting in seperate sequence
                    %NEED TO CHECK with paper again
                    sellcount = sellcount + 1;
                    continue;
                end
                
                if sellcount < 12
                    sellcount = sellcount + 1;
                    scout(j) = sellcount;
                else
                    %to complete a TD Sell countdown the high of TD
                    %Sell Countdown bar thirteen must be greater than, or equal
                    %to, the close of TD Sell Countdown bar eight
                    idx8 = find(scout(idxbs_latest:j) == 8);
                    idx8 = idx8 + idxbs_latest-1;
                    close8 = data(idx8,5);
                    if data(j,3) >= close8
                        sellcount = sellcount + 1;
                        scout(j) = sellcount;
                        break
                    else
                        continue;
                    end
                end
                if scout(j) == 13
                    break
                end
            end
        end
    catch e
        disp(e.message);
        bcout = [bcin;NaN];
        scout = [scin;NaN];
    end
        

end

