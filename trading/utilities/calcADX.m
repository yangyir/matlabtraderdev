function [ADX, plusDI, minusDI, DX, TR] = calcADX(highpx, lowpx, closepx, n)
% calcADX  Calculate ADX, +DI, -DI using Wilder smoothing
%
% Inputs:
%   high, low, close : column or row vectors of equal length
%   n                : period, e.g. 14
%
% Outputs:
%   ADX      : Average Directional Index
%   plusDI   : +DI
%   minusDI  : -DI
%   DX       : Directional Index
%   TR       : True Range

    if nargin < 4
        n = 14;
    end

    m = length(closepx);
    if length(highpx) ~= m || length(lowpx) ~= m
        error('high, low, close must have the same length');
    end

%     TR = nan(m,1);
%     plusDM = zeros(m,1);
%     minusDM = zeros(m,1);
    
    upMove = [0;diff(highpx)];
    downMove = [0;-diff(lowpx)];
    plusDM = upMove .* (upMove > downMove & upMove > 0);
    minusDM = downMove .* (downMove > upMove & downMove > 0);
    prevClosepx = [closepx(1);closepx(1:end-1)];
    TR = max([highpx-lowpx,abs(highpx-prevClosepx),abs(lowpx-prevClosepx)],[],2);

%     for i = 2:m
%         upMove   = highpx(i) - highpx(i-1);
%         downMove = lowpx(i-1) - lowpx(i);
% 
%         if upMove > downMove && upMove > 0
%             plusDM(i) = upMove;
%         else
%             plusDM(i) = 0;
%         end
% 
%         if downMove > upMove && downMove > 0
%             minusDM(i) = downMove;
%         else
%             minusDM(i) = 0;
%         end
% 
%         TR(i) = max([highpx(i)-lowpx(i), abs(highpx(i)-closepx(i-1)), abs(lowpx(i)-closepx(i-1))]);
%     end

    smTR = nan(m,1);
    smPlusDM = nan(m,1);
    smMinusDM = nan(m,1);

    smTR(n) = sum(TR(2:n));
    smPlusDM(n) = sum(plusDM(2:n));
    smMinusDM(n) = sum(minusDM(2:n));

    for i = n+1:m
        smTR(i) = smTR(i-1) - smTR(i-1)/n + TR(i);
        smPlusDM(i) = smPlusDM(i-1) - smPlusDM(i-1)/n + plusDM(i);
        smMinusDM(i) = smMinusDM(i-1) - smMinusDM(i-1)/n + minusDM(i);
    end

    plusDI = 100 * (smPlusDM ./ smTR);
    minusDI = 100 * (smMinusDM ./ smTR);

    DX = 100 * abs(plusDI - minusDI) ./ (plusDI + minusDI);

    ADX = nan(m,1);
    firstADX = 2*n - 1;
    if firstADX <= m
        tmp = DX(n:firstADX);
        tmp = tmp(~isnan(tmp),:);
        ADX(firstADX) = mean(tmp);
        for i = firstADX+1:m
            ADX(i) = ((n-1)*ADX(i-1) + DX(i)) / n;
        end
    end
end