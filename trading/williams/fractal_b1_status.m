function [res] = fractal_b1_status(nfractal,extrainfo,ticksize)

if nargin < 3
    ticksize = 0;
end

px = extrainfo.px;
ss = extrainfo.ss;
sc = extrainfo.sc;
lvlup = extrainfo.lvlup;
lvldn = extrainfo.lvldn;
idxHH = extrainfo.idxhh;
HH = extrainfo.hh;
% LL = extrainfo.ll;
lips = extrainfo.lips;
teeth = extrainfo.teeth;
jaw = extrainfo.jaw;
% wad = extrainfo.wad;

if HH(end-1) < teeth(end-1)
    b1type = 1;
elseif HH(end-1) > teeth(end-1)
    if teeth(end-1) > jaw(end-1)
        b1type = 3;
    elseif teeth(end-1) < jaw(end-1)
        b1type = 2;
    end
end

%islvlupbreach
islvlupbreach = 0;
if px(end,5)>lvlup(end) && px(end-1,5)<lvlup(end)
    islvlupbreach = 1;
end
if ~islvlupbreach && (px(end,5)>lvlup(end) && px(end,4)<lvlup(end))
    islvlupbreach = 2;
end
if ~islvlupbreach && ss(end) <= 9
    idx1 = find(px(end-ss(end):end,5)>lvlup(end),1,'first');
    if ~isempty(idx1)
        idx2 = find(px(end-ss(end):end-ss(end)+idx1-1,5)<lvlup(end),1,'first');
        if ~isempty(idx2), islvlupbreach = 3;end        
    end    
end
%isclose2lvlup
isclose2lvlup = ~isnan(lvlup(end)) && ~isnan(lvldn(end)) && ...
    lvlup(end)>lvldn(end) && ...
    px(end,5)<lvlup(end) && ...
    (lvlup(end)-px(end,5))/(lvlup(end)-lvldn(end))<0.1;
%
[~,~,nkabovelips,nkaboveteeth,nkfromhh,isteethjawcrossed,isteethlipscrossed] = fractal_countb(px,idxHH,nfractal,lips,teeth,jaw,ticksize);
%isvolblowup
barsizelast = px(end,3)-px(end,4);
barsizerest = px(end-nkfromhh+1:end-1,3)-px(end-nkfromhh+1:end-1,4);
isvolblowup = (barsizelast-mean(barsizerest))/std(barsizerest)>norminv(0.99);
%isvolblowup2
retlast = log(px(end,5)/px(end-1,5));
retrest = log(px(end-nkfromhh+1:end-1,5)./px(end-nkfromhh:end-2,5));
isvolblowup2 = abs(retlast-mean(retrest))/std(retrest)>norminv(0.99);
%
lastss9 = find(ss==9,1,'last');
if isempty(lastss9)
    nkfromss = NaN;
else
    lastss = lastss9;
    for i = lastss9+1:size(ss,1)
        if ss(i) ~= 0
            lastss = i;
        else
            break
        end
    end
    nkfromss = size(ss,1)-lastss;
end

%does it breach-up high of a previous sell sequential
issshighbreach = 0;
if size(ss,1)-lastss9+1<=nkfromhh
    lastssval = ss(lastss);
    issshighbreach = px(end,5) > max(px(lastss-lastssval+1:lastss,3));
end
%does it stand beyond a sell sequential with highest high and close price
issshighvalue = ss(end)>= 9 && px(end,5)>=max(px(end-ss(end)+1:end,5)) && px(end,3)>=max(px(end-ss(end)+1:end,3));
%
%does it breach-up hh after sc13
lastsc13 = find(sc(1:end-1)==13,1,'last');
if isempty(lastsc13)
    nkfromsc13 = NaN;
    isschighbreach = 0;
else
    nkfromsc13 = size(px,1)-lastsc13;
    isschighbreach = px(end,5)>max(px(lastsc13:end-1,3));
end
%
%all the special case above passed
%and to check whether there are 2*nfractal+1 candles stay above teeth
%before it breach the fractal hh
istrendconfirmed = nkaboveteeth>=2*nfractal+1;
if ~istrendconfirmed
    %1.in case all candles are above teeth since hh formed but there are
    %less than 2*nfractal+1 candles since then, we include candles before
    %the hh formed and double check
    if nkaboveteeth == nkfromhh
        istrendconfirmed = isempty(find(px(end-2*nfractal:end,5)<teeth(end-2*nfractal:end),1,'first'));
    end
end
%
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
ao = smma(px(:,1:5),5)-smma(px(:,1:5),min(34,size(px,1)));
%
res = struct('b1type',b1type,...
    'islvlupbreach',islvlupbreach,...
    'isclose2lvlup',isclose2lvlup,...
    'isvolblowup',isvolblowup,...
    'isvolblowup2',isvolblowup2,...
    'isteethjawcrossed',isteethjawcrossed,...
    'isteethlipscrossed',isteethlipscrossed,...
    'alligatorstatus',alligatorstatus,...
    'ss',ss(end),...
    'nkfromss',nkfromss,...
    'issshighvalue',issshighvalue,...
    'issshighbreach',issshighbreach,...
    'sc',sc(end),...
    'nkfromsc13',nkfromsc13,...
    'isschighbreach',isschighbreach,...
    'istrendconfirmed',istrendconfirmed,...
    'ao',ao(end));
% disp(res);