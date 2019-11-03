currenti = 164;
idxchgbefore = find(idxchg(:,1) <= currenti,3,'last');
if idxchg(idxchgbefore(end)) ~= currenti
    previouschg1 = idxchg(idxchgbefore(end-1));
    lastchgi = idxchg(idxchgbefore(end));
else
    previouschg1 = idxchg(idxchgbefore(end-2));
    lastchgi = idxchg(idxchgbefore(end-1));
end

range1max = max(p(previouschg1:lastchgi-1,3));
range1min = min(p(previouschg1:lastchgi-1,4));
x1max = find(p(previouschg1:lastchgi-1,3)==range1max,1,'last')+previouschg1-1;
x1min = find(p(previouschg1:lastchgi-1,4)==range1min,1,'last')+previouschg1-1;
range1maxbarsize = range1max - p(x1max,4);
range1minbarsize = p(x1min,3) - range1min;
x1max = x1max-previouschg1+1;
x1min = x1min-previouschg1+1;

%compute use previous index
previousi = currenti-1;
range2max = max(p(lastchgi:previousi,3));
range2min = min(p(lastchgi:previousi,4));
x2max = find(p(lastchgi:previousi,3)==range2max,1,'last')+lastchgi-1;
x2min = find(p(lastchgi:previousi,4)==range2min,1,'last')+lastchgi-1;
range2maxbarsize = range2max - p(x2max,4);
range2minbarsize = p(x2min,3) - range2min;
x2max = x2max-previouschg1+1;
x2min = x2min-previouschg1+1;

kupper = (range2max-range1max)/(x2max-x1max);
yupper = range2max - kupper*x2max;
klower = (range2min-range1min)/(x2min-x1min);
ylower = range2min - klower*x2min;

pxupper = kupper*(currenti-previouschg1+1)+yupper;
pxlower = klower*(currenti-previouschg1+1)+ylower;
    
fprintf('upper px:%4.3f\tlower px:%4.3f\n',pxupper,pxlower);
    
