function ao = calcAO(highpx,lowpx,fastLen,slowLen)
% calculate awesome oscillator
% matlab 2014-compatible awesome oscillator
% usage:
% ao = calcAO(highpx,lowpx)
% ao = calcAO(highpx,lowpx,fastLen,slowLen)

% inputs:
% highpx, lowpx: price vectors of equal length
% fastLen: fast SMA length, default = 5
% slowLen: slow SMA length, default = 34
%
% output:
% ao: awesome oscillator vector

if nargin < 3 || isempty(fastLen)
    fastLen = 5;
end
if nargin < 4 || isempty(slowLen)
    slowLen = 34;
end

if length(highpx) ~= length(lowpx)
    error('calcAO:high and low must have the same length.');
end

medianpx = 0.5*(highpx + lowpx);

fastSMA = movmean2014(medianpx,fastLen);
slowSMA = movmean2014(medianpx,slowLen);

ao = fastSMA - slowSMA;

end