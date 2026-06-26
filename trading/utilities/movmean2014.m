function val = movmean2014(x,nperiod)
% simple moving average, e.g.movemean. with NaN for the warm-up region
% this runs for Matlab2014 and other newer versions
n = length(x);
if n < nperiod
    val = nan(n,1);
    return;
end

val = filter(ones(nperiod,1)/nperiod,1,x);

val(1:nperiod-1) = NaN;

end