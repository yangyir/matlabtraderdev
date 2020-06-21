function [ momentum ] = tdsq_momentum(p,bs,ss,lvlup,lvldn)
    lastbs9 = find(bs==9,1,'last');
    lastss9 = find(ss==9,1,'last');
    if isempty(lastbs9) && isempty(lastss9)
        %in case neither TDST Buy Sequential nor Sell Sequential is formed,
        %the market momentum is relatively neutral
        momentum = 0;
        return
    end
    %
    if isempty(lastbs9) && ~isempty(lastss9)
        %in case only TDST Sell Sequential is formed
        %
        %if the price is above lvldn, the market is regarded
        %bullish,otherwise it is bearish
        if p(end,5) > lvldn(end)
            momentum = 1;
        elseif p(end,5) < lvldn(end)
            momentum = -1;
        else
            momentum = 0;
        end
        return
    end
    %
    if ~isempty(lastbs9) && isempty(lastss9)
        %in case only TDST Buy Sequential is formed
        %
        %if the price is below lvlup, the market is regarded bearish,
        %otherwise it is bullish
        if p(end,5) < lvlup(end)
            momentum = -1;
        elseif p(end,5) > lvlup(end)
            momentum = 1;
        else
            momentum = 0;
        end
        return
    end
    %
    %
    if lvlup(end) > lvldn(end)
        if lastss9 > lastbs9
            %a TDST Sell Sequential is formed later than the last Buy
            %Sequential, i.e. market rally
            if p(end,5) > lvlup(end)
                momentum = 1;
            elseif p(end,5) < lvldn(end)
                momentum = -1;
            else
                momentum = 0;
            end
        else
            %a TDST Buy Sequential is formed later than the last Sell
            %Sequential, i.e.market collapsed
            if p(end,5) < lvldn(end)
                momentum = -1;
            elseif p(end,5) > lvlup(end)
                momentum = 1;
            else
                momentum = 0;
            end
        end
    elseif lvlup(end) < lvldn(end)
        if lastss9 > lastbs9
            %a TDST Sell Sequential is formed later than the last Buy
            %Sequential, i.e. market rally
            %also the lowest price of the Sell Sequential is above lvlup,
            %indicating the market is bullish in a upper-trend
            if p(end,5) > lvldn(end)
                momentum = 1;
            else
                momentum = 0;
            end
        else
            %a TDST Buy Sequential is formed later than the last Sell
            %Sequential, i.e.market collapsed
            %also the highest price of the Buy Sequential is below lvldn,
            %indicating the market is bearish in a downward-trend
            if p(end,5) < lvlup(end)
                momentum = -1;
            else
                momentum = 0;
            end
        end
        
    else
        %lvlup(end) == lvldn(end)
        
    end
end

