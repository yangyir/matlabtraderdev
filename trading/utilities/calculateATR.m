function [atrvalue,tr] = calculateATR(highpx,lowpx,closepx,period)
    %inputs: high/low/close as vectors (same length), period = 14 as
    %default
    %output: ATR vector (NaN first period-1 bars)

    if nargin == 3
        period = 14;
    end

    n = length(highpx);
    if n ~= length(lowpx) || n ~= length(closepx)
        error('calculateATR:different lengths of high,low and close...')
    end

    
    %True range calculation
%     tr = zeros(n,1);
%     for i = 2:n
%         tr1 = highpx(i) - lowpx(i);
%         tr2 = abs(highpx(i) - closepx(i-1));
%         tr3 = abs(lowpx(i) - closepx(i-1));
%         tr(i) = max([tr1,tr2,tr3]);
%     end
%     tr(1) = highpx(1)-lowpx(1); %First bar no prev close
    prevClosepx = [closepx(1);closepx(1:end-1)];
    tr = max([highpx-lowpx,abs(highpx-prevClosepx),abs(lowpx-prevClosepx)],[],2);
    
    try
        atrvalue = movavg(tr,'simple',period);
    catch
        [atrvalue,~] = movavg(tr,period,period,0);
    end

    atrvalue(1:period-1) = NaN;



end