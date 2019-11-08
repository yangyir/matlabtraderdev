function [ outputs ] = macdenhanced( currenti,p,diffvec )

if nargin < 3
    [macdvec,sigvec] = macd(p(:,5));
    diffvec = macdvec - sigvec;
end
temp = diffvec(2:end).*diffvec(1:end-1);
idxchg = find(temp<0)+1;

idxchgbefore = find(idxchg <= currenti,3,'last');
if isempty(idxchgbefore)
elseif length(idxchgbefore) == 1
    i1 = idxchg(idxchgbefore(1));
    lasti = i1;
elseif length(idxchgbefore) == 2
    i1 = idxchg(idxchgbefore(1));
    i2 = idxchg(idxchgbefore(2));
    i3 = [];
    lasti = i2;
else
    i1 = idxchg(idxchgbefore(1));
    i2 = idxchg(idxchgbefore(2));
    i3 = idxchg(idxchgbefore(3));
    lasti = i3;
end


range1max = max(p(i1:i2-1,3));
range1min = min(p(i1:i2-1,4));
range2max = max(p(i2:i3-1,3));
range2min = min(p(i2:i3-1,4));
x1max = find(p(i1:i2-1,3)==range1max,1,'last')+i1-1;
x1min = find(p(i1:i2-1,4)==range1min,1,'last')+i1-1;
x2max = find(p(i2:i3-1,3)==range2max,1,'last')+i2-1;
x2min = find(p(i2:i3-1,4)==range2min,1,'last')+i2-1;
range1maxbarsize = range1max - p(x1max,4);
range1minbarsize = p(x1min,3) - range1min;
range2maxbarsize = range2max - p(x2max,4);
range2minbarsize = p(x2min,3) - range2min;
x1max = x1max-i1+1;
x1min = x1min-i1+1;
x2max = x2max-i1+1;
x2min = x2min-i1+1;
%


k1 = (range2max-range1max)/(x2max-x1max);
y1 = range1max - k1*x1max;

k2 = (range2min-range1min)/(x2min-x1min);
y2 = range1min - k2*x1min;

if lasti < currenti
    i4 = currenti-1;
    range3max = max(p(lasti:i4,3));
    range3min = min(p(lasti:i4,4));
    x3max = find(p(lasti:i4,3)==range3max,1,'last')+lasti-1;
    x3min = find(p(lasti:i4,4)==range3min,1,'last')+lasti-1;
    range3maxbarsize = range3max - p(x3max,4);
    range3minbarsize = p(x3min,3) - range3min;
    x3max = x3max-i1+1;
    x3min = x3min-i1+1;
    
    if length(idxchgbefore) == 3
        k3 = (range3max-range2max)/(x3max-x2max);
        y3 = range3max - k3*x3max;
        k4 = (range3min-range2min)/(x3min-x2min);
        y4 = range3min - k4*x3min;
    elseif length(idxchgbefore) == 2
        k3 = (range3max-range1max)/(x3max-x1max);
        y3 = range3max - k3*x3max;
        k4 = (range3min-range1min)/(x3min-x1min);
        y4 = range3min - k4*x3min;
    end
else
    range3max = [];
    range3min = [];
    range3maxbarsize = [];
    range3minbarsize = [];
    k3 = [];y3 = [];
    k4 = [];y4 = [];
end

x = i1:currenti;
xreal = x;
x = x-i1+1;

outputs = struct('k1',k1,'y1',y1,...
    'k2',k2,'y2',y2,...
    'k3',k3,'y3',y3,...
    'k4',k4,'y4',y4,...
    'range1max',range1max,'range1min',range1min,...
    'range1maxbarsize',range1maxbarsize,'range1minbarsize',range1minbarsize,...
    'range2max',range2max,'range2min',range2min,...
    'range2maxbarsize',range2maxbarsize,'range2minbarsize',range2minbarsize,...
    'range3max',range3max,'range3min',range3min,...
    'range3maxbarsize',range3maxbarsize,'range3minbarsize',range3minbarsize,...
    'x',x,...
    'xreal',xreal);

end

