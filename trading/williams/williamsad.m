function [ wad,trh,trl ] = williamsad( p,usevolume )
%WILLIAMSAD Summary of this function goes here
%   Williams Accumulation Distribution is traded on divergences. When price
%   makes a new high and the indicator fails to exceed its previous high, a
%   distribution is taking place. When price makes a new low and the WAD
%   fails to make a new low, accumulation is occuring. Go long when there
%   is a bullish divergence between Williams Accumulation Distribution and
%   price. Go short on a bearish divergence.

    if nargin < 2
        usevolume = false;
    end
    np = size(p,1);
    %Williams' accumulation distribution
    wad = zeros(np,1);
    %true range high;the greater of high(today) and close price(yesterday)
%     trh = zeros(np,1);
    %true range low:the lesser of low(today) and close yesterday
%     trl = zeros(np,1);
    
    pxhigh = p(:,3);
    pxlow = p(:,4);
    pxclose = p(:,5);
    if usevolume
        volume = p(:,6);
    end
    
    trh_ = max([pxhigh(2:end),pxclose(1:end-1)],[],2);
    trl_ = min([pxlow(2:end),pxclose(1:end-1)],[],2);
    
    trh = [pxhigh(1);trh_];
    trl = [pxlow(1);trl_];
    
    for i = 2:np
%         trh(i) = max(pxhigh(i),pxclose(i-1));
%         trl(i) = min(pxlow(i),pxclose(i-1));
        if pxclose(i)>pxclose(i-1)
            pxmove = pxclose(i)-trl(i);
        elseif pxclose(i)<pxclose(i-1)
            pxmove = pxclose(i)-trh(i);
        elseif pxclose(i) == pxclose(i-1)
            pxmove = 0;
        else
            pxmove = 0;
        end
        if usevolume
            wad(i) = wad(i-1)+pxmove*volume(i);
        else
            wad(i) = wad(i-1)+pxmove;
        end
    end


end

