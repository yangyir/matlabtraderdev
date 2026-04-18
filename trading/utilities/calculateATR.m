function atrvalue = calculateATR(high,low,close,period)
    %inputs: high/low/close as vectors (same length), period = 14 as
    %default
    %output: ATR vector (NaN first period-1 bars)

    if nargin == 3
        period = 14;
    end

    n = length(high);
    if n ~= length(low) || n ~= length(close)
        error('calculateATR:different lengths of high,low and close...')
    end

    
    %True range calculation
    tr = zeros(n,1);
    for i = 2:n
        tr1 = high(i) - low(i);
        tr2 = abs(high(i) - close(i-1));
        tr3 = abs(low(i) - close(i-1));
        tr(i) = max([tr1,tr2,tr3]);
    end
    tr(1) = high(1)-low(1); %First bar no prev close

    atrvalue = movavg(tr,'simple',period);

    atrvalue(1:period-1) = NaN;



end