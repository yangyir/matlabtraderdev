function [res] = fractal_s1_status(nfractal,extrainfo,ticksize)

if nargin < 3
    ticksize = 0;
end

px = extrainfo.px;
bs = extrainfo.bs;
bc = extrainfo.bc;
lvlup = extrainfo.lvlup;
lvldn = extrainfo.lvldn;
idxLL = extrainfo.idxll;
% HH = extrainfo.hh;
LL = extrainfo.ll;
lips = extrainfo.lips;
teeth = extrainfo.teeth;
jaw = extrainfo.jaw;
% wad = extrainfo.wad;

% if LL(end-1) > teeth(end-1)
%     s1type = 1;
if LL(end-1) - teeth(end-1) < ticksize
    if teeth(end-1) < jaw(end-1)
        s1type = 3;
    elseif teeth(end-1) > jaw(end-1)
        s1type = 2;
    end
else
    s1type = 1;
end


%islvldnbreach
islvldnbreach = 0;
if px(end,5)<lvldn(end) && px(end-1,5)>lvldn(end)
    islvldnbreach = 1;
end
if ~islvldnbreach && (px(end,5)<lvldn(end) && px(end,3)>lvldn(end))
    islvldnbreach = 2;
end
if ~islvldnbreach && bs(end) <= 9
    idx1 = find(px(end-bs(end):end,5)<lvldn(end),1,'first');
    if ~isempty(idx1)
        idx2 = find(px(end-bs(end):end-bs(end)+idx1-1,5)>lvldn(end),1,'first');
        if ~isempty(idx2),islvldnbreach = 3;end
    end
end
%isclose2lvldn
isclose2lvldn = ~isnan(lvlup(end)) && ~isnan(lvldn(end)) && ...
    lvlup(end)>lvldn(end) && ...
    px(end,5)>lvldn(end) && ...
    (lvlup(end)-px(end,5))/(lvlup(end)-lvldn(end))>0.9;
%
[~,~,nkbelowlips,nkbelowteeth,nkfromll,isteethjawcrossed,isteethlipscrossed] = fractal_counts(px,idxLL,nfractal,lips,teeth,jaw,ticksize);
%isvolblowup
barsizelast = px(end,3)-px(end,4);
barsizerest = px(end-nkfromll+1:end-1,3)-px(end-nkfromll+1:end-1,4);
isvolblowup = (barsizelast-mean(barsizerest))/std(barsizerest)>norminv(0.99);
%isvolblowup2
retlast = abs(px(end,5)-px(end-1,5));
isvolblowup2 = (retlast-mean(barsizerest))/std(barsizerest)>norminv(0.99);
%
lastbs9 = find(bs==9,1,'last');
if isempty(lastbs9)
    nkfrombs = NaN;
else
    lastbs = lastbs9;
    for i = lastbs9+1:size(bs,1)
        if bs(i) ~= 0
            lastbs = i;
        else
            break
        end
    end
    nkfrombs = size(bs,1)-lastbs;
end

%does it breach-dn low of a previous buy sequential
isbslowbreach = 0;
if size(bs,1)-lastbs9+1<=nkfromll
    lastbsval = bs(lastbs);
    isbslowbreach = px(end,5) < min(px(lastbs-lastbsval+1:lastbs,4));
end
if ~isbslowbreach && bs(end) > 9
    isbslowbreach = px(end,5) < min(px(end-bs(end):end-1,4));
end
%
%does it stand beyond a buy sequential with lowest low and close price
isbshighvalue = bs(end)>=9 && px(end,5) <= min(px(end-bs(end)+1:end,5)) && px(end,4) <= min(px(end-bs(end)+1:end,4));
%
%does it breach-dn ll after bc13
lastbc13 = find(bc(1:end-1)==13,1,'last');
if isempty(lastbc13)
    nkfrombc13 = NaN;
    isbclowbreach = false;
else
    nkfrombc13 = size(px,1)-lastbc13;
    isbclowbreach = px(end,5)<min(px(lastbc13:end-1,4)) & nkfrombc13 < 12;
end
%all the special case above passed
%and to check whether there are 2*nfractal+1 candles stay below teeth
%before it breach the fractal ll
istrendconfirmed = nkbelowteeth>=2*nfractal+1;
if ~istrendconfirmed
    %1.in case all candles are below teeth since ll formed but there are
    %less than 2*nfractal+1 candles since then, we include candles before
    %the ll formed and double check
    if nkbelowteeth == nkfromll
        istrendconfirmed = isempty(find(px(end-2*nfractal:end,5)>teeth(end-2*nfractal:end),1,'first'));
    end
end

%check alligator's lips,teeth,jaw relationship
if jaw(end)<teeth(end) && teeth(end)<lips(end)
    alligatorstatus = 'jaw<teeth<lips';
elseif jaw(end)<lips(end) && lips(end)<teeth(end)
    alligatorstatus = 'jaw<lips<teeth';
elseif lips(end)<teeth(end) && teeth(end)<jaw(end)
    alligatorstatus = 'lips<teeth<jaw';
elseif lips(end)<jaw(end) && jaw(end)<teeth(end)
    alligatorstatus = 'lips<jaw<teeth';
elseif teeth(end)<jaw(end) && jaw(end)<lips(end)
    alligatorstatus = 'teeth<jaw<lips';
elseif teeth(end)<lips(end) && lips(end)<jaw(end)
    alligatorstatus = 'teeth<lips<jaw';
end
%
% rsi = rsindex(px(:,5));
ao = smma(px(:,1:5),min(size(px,1),5))-smma(px(:,1:5),min(size(px,1),34));

%
res = struct('s1type',s1type,...
    'islvldnbreach',islvldnbreach,...
    'isclose2lvldn',isclose2lvldn,...
    'isvolblowup',isvolblowup,...
    'isvolblowup2',isvolblowup2,...
    'isteethjawcrossed',isteethjawcrossed,...
    'isteethlipscrossed',isteethlipscrossed,...
    'alligatorstatus',alligatorstatus,...
    'bs',bs(end),...
    'nkfrombs',nkfrombs,...
    'isbshighvalue',isbshighvalue,...
    'isbslowbreach',isbslowbreach,...
    'bc',bc(end),...
    'nkfrombc13',nkfrombc13,...
    'isbclowbreach',isbclowbreach,...
    'istrendconfirmed',istrendconfirmed,...
    'ao',ao(end));
% disp(res);

end