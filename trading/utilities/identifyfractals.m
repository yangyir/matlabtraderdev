function [topF, botF] = identifyfractals(highpx,lowpx,nperiod)
% identify swing high/low

n = length(highpx);
if n ~= length(lowpx)
    error('identifyfractals:input of highpx and lowpx shall be with the same length')
end

topF = zeros(n,1);
botF = zeros(n,1);

for i = nperiod+1:n-nperiod
    % top fractal
    if highpx(i) >= max(highpx(i-nperiod:i+nperiod))
        topF(i) = 1;
    end
    % bottom fractal
    if lowpx(i) <= min(lowpx(i-nperiod:i+nperiod))
        botF(i) = 1;
    end
end


end