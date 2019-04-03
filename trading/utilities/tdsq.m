function [tdBuySetup,tdSellSetup] = tdsq(data,varargin)
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
    for i = nLag+2:n
        if data(i-1,end) >= data(i-1-nLag,end) && data(i,end) <= data(i-nLag,end)
            bearishTDPriceFlip(i,1) = 1;
        end
        if data(i-1,end) <= data(i-1-nLag,end) && data(i,end) >= data(i-nLag,end)
            bullishTDPriceFlip(i,1) = 1;
        end
    end
    
    %after a bearish TD price flip, there must be nConsecutive closes, each
    %one less than the corresponding close nLag bars earlier
    tdBuySetup = zeros(n,1);
    
    %once the bullish TD price flip occurs, a TD sell setup, consisting of
    %nConsecutive closes, each one greater than the corresponding close nLag
    %bars earlier
    tdSellSetup = zeros(n,1);
    
    for i = 1:n
        if bearishTDPriceFlip(i,1) == 1
            tdBuySetup(i,1) = 1;
            for j = i+1:n
                if data(j,end) <= data(j-nLag,end)
                    tdBuySetup(j,1) = tdBuySetup(j-1,1)+1;
                    if tdBuySetup(j,1) == nConsecutive
                        break
                    end
                else
                    break
                end
            end
        end
        %
        if bullishTDPriceFlip(i,1) == 1
            tdSellSetup(i,1) = 1;
            for j = i+1:n
                if data(j,end) >= data(j-nLag,end)
                    tdSellSetup(j,1) = tdSellSetup(j-1,1)+1;
                    if tdSellSetup(j,1) == nConsecutive
                        break
                    end
                else
                    break
                end
            end
        end
    end
end