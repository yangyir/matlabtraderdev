function [idxHH,idxLL,HH,LL] = fractal(p,nperiod)
%william's fractal
%param: default value of nperiod is 2, i.e. 5 period of time fractal 
if nargin < 2
    nperiod = 2;
end

n = length(p);

if n < 2*nperiod+1
    error('fractal:input p is not long enough for nperiod')
end

% idx = zeros(n,1);
idxHH = zeros(n,1);
idxLL = zeros(n,1);
for i = 1:n
    if i < 2*nperiod+1,continue;end
    if p(i-nperiod,3) >= max(p(i-2*nperiod:i,3))
%         idx(i) = 1;
        idxHH(i) = 1;
    end
    if p(i-nperiod,4) <= min(p(i-2*nperiod:i,4))
%         idx(i) = -1;
        idxLL(i) = -1;
    end
end
%TODO:how about fractal low and high appears on the same time
HH = nan(n,1);
firstHH = find(idxHH == 1,1,'first');
HH(firstHH) = p(firstHH-nperiod,3);
for i = firstHH+1:n
    if idxHH(i) == 1
        HH(i) = p(i-nperiod,3);
    else
        HH(i) = HH(i-1);
    end
end

LL = nan(n,1);
firstLL = find(idxLL==-1,1,'first');
LL(firstLL) = p(firstLL-nperiod,4);
for i = firstLL+1:n
    if idxLL(i) == -1
        LL(i) = p(i-nperiod,4);
    else
        LL(i) = LL(i-1);
    end
end 




end