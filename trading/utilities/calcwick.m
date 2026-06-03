function wick = calcwick(openpx,highpx,lowpx,closepx)
    
    np = size(closepx,1);
    if size(openpx,1) ~= np
        error('calcwick:invalid input of openpx...');
    end
    
    if size(highpx,1) ~= np
        error('calcwick:invalid input of highpx...');
    end
    
    if size(lowpx,1) ~= np
        error('calcwich:invalid input of lowpx...');
    end
    
    candlerange = highpx - lowpx;
    
    wick = zeros(np,1);
    
    for i = 1:np
        if closepx(i) >= openpx(i)
            wick(i) = (highpx(i) - closepx(i)) / candlerange(i);
        else
            wick(i) = (closepx(i)-lowpx(i)) / candlerange(i);
        end
    end
end