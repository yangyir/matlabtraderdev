function [buysetup,sellsetup,levelup,leveldn,buycountdown,sellcountdown] = calc_tdsq_(mdefut,instrument,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('Instrument', @(x) validateattributes(x,{'cInstrument'},{},'','Instrument'));
    p.addParameter('Lag',4,@isnumeric);
    p.addParameter('Consecutive',9,@isnumeric);
    p.addParameter('IncludeLastCandle',0,@isnumeric);
    p.parse(instrument,varargin{:});
    instrument = p.Results.Instrument;
    nLag = p.Results.Lag;
    nConsecutive = p.Results.Consecutive;
    includeLastCandle = p.Results.IncludeLastCandle;
    
    histcandles = mdefut.gethistcandles(instrument);
    candlesticks = mdefut.getcandles(instrument);
    
    if isempty(histcandles)
        histcandles = [];
    else
        histcandles = histcandles{1};
    end
    
    if isempty(candlesticks)
        candlesticks = [];
    else
        candlesticks = candlesticks{1};
        if ~includeLastCandle
            candlesticks = candlesticks(1:end-1,:);
        end
    end
    
    if isempty(histcandles) && isempty(candlesticks)
        timevec = [];
        openp = [];
        highp = [];
        lowp = [];
        closep = [];
    elseif isempty(histcandles) && ~isempty(candlesticks)
        timevec = candlesticks(:,1);
        openp = candlesticks(:,2);
        highp = candlesticks(:,3);
        lowp = candlesticks(:,4);
        closep = candlesticks(:,5);
    elseif ~isempty(histcandles) && isempty(candlesticks)
        timevec = histcandles(:,1);
        openp = histcandles(:,2);
        highp = histcandles(:,3);
        lowp = histcandles(:,4);
        closep = histcandles(:,5);
    elseif ~isempty(histcandles) && ~isempty(candlesticks)
        timevec = [histcandles(:,1);candlesticks(:,1)];
        openp = [histcandles(:,2);candlesticks(:,2)];
        highp = [histcandles(:,3);candlesticks(:,3)];
        lowp = [histcandles(:,4);candlesticks(:,4)];
        closep = [histcandles(:,5);candlesticks(:,5)];
    end
    
    %remove possible zeros
    checks = openp.*highp.*lowp.*closep;
    idx = checks ~= 0;
    timevec = timevec(idx);
    openp = openp(idx);
    highp = highp(idx);
    lowp = lowp(idx);
    closep = closep(idx);
    %%
    n = size(closep,1);
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
    buysetup = zeros(n,1);
    
    %once the bullish TD price flip occurs, a TD sell setup, consisting of
    %nConsecutive closes, each one greater than the corresponding close nLag
    %bars earlier
    sellsetup = zeros(n,1);
    
    i = nLag + 2;
    while i <= n
        if closep(i-1) >= closep(i-1-nLag) && closep(i) < closep(i-nLag)
            bearishTDPriceFlip(i,1) = 1;
        end
        if bearishTDPriceFlip(i,1) == 1
            buysetup(i,1) = 1;
            for j = i+1:n
                if closep(j) <= closep(j-nLag)
                    buysetup(j,1) = buysetup(j-1,1)+1;
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
        if closep(i-1) <= closep(i-1-nLag) && closep(i) > closep(i-nLag)
            bullishTDPriceFlip(i,1) = 1;
        end
        if bullishTDPriceFlip(i,1) == 1
            sellsetup(i,1) = 1;
            for j = i+1:n
                if closep(j) >= closep(j-nLag)
                    sellsetup(j,1) = sellsetup(j-1,1)+1;
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
    levelup = nan(n,1);
    leveldn = nan(n,1);
    for i = 1:n
        tdbuysetup = buysetup(1:i);
        tdsellsetup = sellsetup(1:i);
        idx_buysetups = find(tdbuysetup == nConsecutive);
        idx_sellsetups = find(tdsellsetup == nConsecutive);
        ii = find(idx_buysetups < i,1,'last');
        if ~isempty(ii)
            idx_latestbuysetup = idx_buysetups(ii);
        else
            idx_latestbuysetup = [];
        end
        %
        ii = find(idx_sellsetups < idx,1,'last');
        if ~isempty(ii)
            idx_latestsellsetup = idx_sellsetups(ii);
        else
            idx_latestsellsetup = [];
        end
               
        if ~isempty(idx_latestbuysetup)
            levelup(i) = max(highp(idx_latestbuysetup-8:idx_latestbuysetup));
        end
        
        if ~isempty(idx_latestsellsetup)
            leveldn(i) = min(lowp(idx_latestsellsetup-8:idx_latestsellsetup));
        end
    end
    
    %%
    buycountdown = nan(n,1);
    sellcountdown = nan(n,1);
    
    for i = 1:n
        if buysetup(i) == nConsecutive
            buycount = 0;
            for j = i:n
                %after TD Buy Setup is in place, look for the initiation of
                %a TD Buy Countdown if the current bar has a close less
                %than, or equal to the low two bars earlier
                
                %first to introduce filters that cancel a developing TD Buy
                %Countdown
                %1.if the price action rallies and generates a TD Sell
                %Setup
                if sellsetup(j) == nConsecutive, break; end
                
                %2.or the market trades higher and posts a true low above
                %the true high of the prior TD Buy Setup - that is TDST
                %resisitence
                if ~isnan(levelup(j)) && levelup(j) < lowp(j), break;end
                
                if closep(j) <= lowp(j-2)
                   if ~isnan(buycountdown(j)) && buycountdown(j) <= 13
                       buycount = buycount + 1;
                       continue;
                    end
                    
                    if buycount < 12
                        buycount = buycount + 1;
                        buycountdown(j) = buycount;
                    else
                        %to complete a TD buy countdown the low of TD Buy
                        %Countdown bar thirteen must be less than, or equal
                        %to, the close of TD Buy Countdown bar eight
                        idx8 = find(buycountdown(i:j) == 8);
                        idx8 = idx8 + i-1;
                        close8 = closep(idx8);
                        if lowp(j) <= close8
                            buycount = buycount + 1;
                            buycountdown(j) = buycount;
                            break
                        else
                            continue;
                        end
                    end
                    
                    if buycountdown(j) == 13
                        break
                    end
                end
            end
        end
    end
    %%
%     %TD Buy Countdown Recycle Qualifer
%     %When a TD Buy Setup that began before,on,or after the completion of a
%     %developing TD Buy Countdown,but prior to a bullish TD Price Flip,
%     %extends to eighteen bars
%     for i = 1:n
%         if buycountdown(i) == 13
%             for j = i:n
%                 if sellsetup(j) == 1
%                     break
%                 end
%                 if buysetup(j) == 18
%                     buycountdown(i) = -1;
%                     break
%                 end
%             end
%         end
%     end
%     %
    %%
    for i = 1:n
        if sellsetup(i) == nConsecutive
            sellcount = 0;
            for j = i:n
                %after TD Sell Setup is in place, look for the initiation
                %of a TD Sell Countdown if the current bar has a close
                %greater than or equal to the high two bars earlier
                
                %first to introduce filters that cancel a developing TD
                %Sell Countdown
                %1.if the price action rallies and generates a TD Buy
                %Setup
                
                if buysetup(j) == nConsecutive, break; end
                
                %2.or the market trades lower and posts a true high below
                %the true low of the prior TD Sell Setup - that is TDST
                %support
                if ~isnan(leveldn(j)) && leveldn(j) > highp(j)
                    break;
                end

                if closep(j) >= highp(j-2)
                    if ~isnan(sellcountdown(j)) && sellcountdown(j) <= 13
                        %
                       sellcount = sellcount + 1;
                       continue;
                    end
                    
                    if sellcount < 12
                        sellcount = sellcount + 1;
                        sellcountdown(j) = sellcount;
                    else
                        %to complete a TD Sell countdown the high of TD Buy
                        %Countdown bar thirteen must be greater than, or equal
                        %to, the close of TD Sell Countdown bar eight
                        idx8 = find(sellcountdown(i:j) == 8);
                        idx8 = idx8 + i-1;
                        close8 = closep(idx8);
                        if highp(j) >= close8
                            sellcount = sellcount + 1;
                            sellcountdown(j) = sellcount;
                            break
                        else
                            continue;
                        end
                    end
                    if sellcountdown(j) == 13
                        break
                    end
                end
            end
        end
    end
    %%
%     %TD Sell Countdown Recycle Qualifer
%     %When a TD Sell Setup that began before,on,or after the completion of a
%     %developing TD Sell Countdown,but prior to a bearish TD Price Flip,
%     %extends to eighteen bars
%     for i = 1:n
%         if sellcountdown(i) == 13
%             for j = i:n
%                 if buysetup(j) == 1
%                     break
%                 end
%                 if sellsetup(j) == 18
%                     sellcountdown(i) = -1;
%                     break
%                 end
%             end
%         end
%     end
    %
    %        

    
end
