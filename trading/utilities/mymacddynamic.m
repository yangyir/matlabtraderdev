function diffval = mymacddynamic(x,p)
    pvec = [p(end-35:end,5);x];
    [vec1,vec2] = macd(pvec);
    diffval = vec1(end)-vec2(end);
end


