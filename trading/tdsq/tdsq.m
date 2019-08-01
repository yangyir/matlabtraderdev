function [tdBuySetup,tdSellSetup,tdSTResistence,tdSTSupport,tdBuyCountdown,tdSellCountdown] = tdsq(data,varargin)
%TD Sequential
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Lag',4,@isnumeric);
    p.addParameter('Consecutive',9,@isnumeric);
    p.parse(varargin{:});
    nLag = p.Results.Lag;
    nConsecutive = p.Results.Consecutive;
    n = size(data,1);
    %a bearish TD price flip occurs when the market records a close greater
    %than the close nLag bars earlier, immediately followed by a close less
    %than the close nLag bars ealier
    bearishTDPriceFlip = zeros(n,1);
    %a bullish TD price flip occurs when the market records a close less than
    %the close nLag bars before, immediately followed by a close greater than
    %the close nLag earlier
    bullishTDPriceFlip = zeros(n,1);
    
    %after a bearish TD price flip, there must be nConsecutive closes, each
    %one less than the corresponding close nLag bars earlier
    tdBuySetup = zeros(n,1);
    
    %once the bullish TD price flip occurs, a TD sell setup, consisting of
    %nConsecutive closes, each one greater than the corresponding close nLag
    %bars earlier
    tdSellSetup = zeros(n,1);
    
    i = nLag + 2;
    while i <= n
        if data(i-1,end) >= data(i-1-nLag,end) && data(i,end) < data(i-nLag,end)
            bearishTDPriceFlip(i,1) = 1;
        end
        if bearishTDPriceFlip(i,1) == 1
            tdBuySetup(i,1) = 1;
            for j = i+1:n
                if data(j,end) < data(j-nLag,end)
                    tdBuySetup(j,1) = tdBuySetup(j-1,1)+1;
                else
                    break
                end
            end
            i = j;
        else
            i = i + 1;
        end
    end
    %
    i = nLag + 2;
    while i <= n
        if data(i-1,end) <= data(i-1-nLag,end) && data(i,end) > data(i-nLag,end)
            bullishTDPriceFlip(i,1) = 1;
        end
        if bullishTDPriceFlip(i,1) == 1
            tdSellSetup(i,1) = 1;
            for j = i+1:n
                if data(j,end) > data(j-nLag,end)
                    tdSellSetup(j,1) = tdSellSetup(j-1,1)+1;
                else
                    break
                end
            end
            i = j;
        else
            i = i + 1;
        end
    end
    %%
    %
    tdSTResistence = nan(n,1);
    tdSTSupport = nan(n,1);
    for i = 1:n
        if tdBuySetup(i) == nConsecutive
            tdSTResistence(i:n) = max(data(i-nConsecutive+1:i,3));
        end
    end
    
    for i = 1:n
        if tdSellSetup(i) == nConsecutive
            tdSTSupport(i:n) = min(data(i-nConsecutive+1:i,4));
        end
    end
        
    %%
    tdBuyCountdown = nan(n,1);
    tdSellCountdown = nan(n,1);
    for i = 1:n
        if tdBuySetup(i) == nConsecutive
            buycount = 0;
            for j = i:n
                %after TD Buy Setup is in place, look for the initiation of
                %a TD Buy Countdown if the current bar has a close less
                %than, or equal to the low two bars earlier
                
                %first to introduce filters that cancel a developing TD Buy
                %Countdown
                %1.if the price action rallies and generates a TD Sell
                %Setup
                if tdSellSetup(j) == nConsecutive, break; end
                
                %2.or the market trades higher and posts a true low above
                %the true high of the prior TD Buy Setup - that is TDST
                %resisitence
                if ~isnan(tdSTResistence(j)) && tdSTResistence(j) < data(j,4), break;end
                
                if data(j,5) <= data(j-2,4)
                   if ~isnan(tdBuyCountdown(j)) && tdBuyCountdown(j) <= 13
                       %note;here we keep counting in seperate sequence
                       %NEED TO CHECK with paper again
                       buycount = buycount + 1;
                       continue;
                    end
                    
                    if buycount < 12
                        buycount = buycount + 1;
                        tdBuyCountdown(j) = buycount;
                    else
                        %to complete a TD buy countdown the low of TD Buy
                        %Countdown bar thirteen must be less than, or equal
                        %to, the close of TD Buy Countdown bar eight
                        idx8 = find(tdBuyCountdown(i:j) == 8);
                        idx8 = idx8 + i-1;
                        close8 = data(idx8,5);
                        if data(j,4) <= close8
                            buycount = buycount + 1;
                            tdBuyCountdown(j) = buycount;
                            break
                        else
                            continue;
                        end
                    end
                    
                    if tdBuyCountdown(j) == 13
                        break
                    end
                end
            end
        end
    end
    %%
%     NEED TO CHECK WITH NOTES AGAIN
%     %TD Buy Countdown Recycle Qualifer
%     %When a TD Buy Setup that began before,on,or after the completion of a
%     %developing TD Buy Countdown,but prior to a bullish TD Price Flip,
%     %extends to eighteen bars
%     for i = 1:n
%         if tdBuyCountdown(i) == 13
%             for j = i:n
%                 if tdSellSetup(j) == 1
%                     break
%                 end
%                 if tdBuySetup(j) == 18
%                     tdBuyCountdown(i) = -1;
%                     break
%                 end
%             end
%         end
%     end

    %%
    for i = 1:n
        if tdSellSetup(i) == nConsecutive
            sellcount = 0;
            for j = i:n
                %after TD Sell Setup is in place, look for the initiation
                %of a TD Sell Countdown if the current bar has a close
                %greater than or equal to the high two bars earlier
                
                %first to introduce filters that cancel a developing TD
                %Sell Countdown
                %1.if the price action rallies and generates a TD Buy
                %Setup
                
                if tdBuySetup(j) == nConsecutive, break; end
                
                %2.or the market trades lower and posts a true high below
                %the true low of the prior TD Sell Setup - that is TDST
                %support
                if ~isnan(tdSTSupport(j)) && tdSTSupport(j) > data(j,3)
                    break;
                end
   
                if data(j,5) >= data(j-2,3)
                    if ~isnan(tdSellCountdown(j)) && tdSellCountdown(j) <= 13
                       %note;here we keep counting in seperate sequence
                       %NEED TO CHECK with paper again
                       sellcount = sellcount + 1;
                       continue;
                    end
                    
                    if sellcount < 12
                        sellcount = sellcount + 1;
                        tdSellCountdown(j) = sellcount;
                    else
                        %to complete a TD Sell countdown the high of TD
                        %Sell Countdown bar thirteen must be greater than, or equal
                        %to, the close of TD Sell Countdown bar eight
                        idx8 = find(tdSellCountdown(i:j) == 8);
                        idx8 = idx8 + i-1;
                        close8 = data(idx8,5);
                        if data(j,3) >= close8
                            sellcount = sellcount + 1;
                            tdSellCountdown(j) = sellcount;
                            break
                        else
                            continue;
                        end
                    end
                    if tdSellCountdown(j) == 13
                        break
                    end
                end
            end
        end
    end
    %%
%     NEED TO CHECK WITH NOTES AGAIN
%     %TD Sell Countdown Recycle Qualifer
%     %When a TD Sell Setup that began before,on,or after the completion of a
%     %developing TD Sell Countdown,but prior to a bearish TD Price Flip,
%     %extends to eighteen bars
%     for i = 1:n
%         if tdSellCountdown(i) == 13
%             for j = i:n
%                 if tdBuySetup(j) == 1
%                     break
%                 end
%                 if tdSellSetup(j) == 18
%                     tdSellCountdown(i) = -1;
%                     break
%                 end
%             end
%         end
%     end     
    
end