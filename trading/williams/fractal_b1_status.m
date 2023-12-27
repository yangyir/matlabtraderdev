function [res] = fractal_b1_status(nfractal,extrainfo,ticksize)

if nargin < 3
    ticksize = 0;
end

px = extrainfo.px;
ss = extrainfo.ss;
bs = extrainfo.bs;
sc = extrainfo.sc;
bc = extrainfo.bc;
lvlup = extrainfo.lvlup;
lvldn = extrainfo.lvldn;
idxHH = extrainfo.idxhh;
HH = extrainfo.hh;
LL = extrainfo.ll;
lips = extrainfo.lips;
teeth = extrainfo.teeth;
jaw = extrainfo.jaw;
% wad = extrainfo.wad;

if HH(end) - teeth(end) > -ticksize
    if teeth(end) > jaw(end)
        b1type = 3;
    elseif teeth(end) <= jaw(end) 
        b1type = 2;
    end
else
    b1type = 1;
end

%islvlupbreach
%islvlupbreach = 1 indicates that the breach happens on the latest candle
%islvlupbreach = 2 indicates that the latest candle closes above lvlup with
%its low is beneath lvlup;
%islvlupbreach = 3 indicates that the latest TDST sell sequential has
%breached up lvlup;
islvlupbreach = 0;
if px(end,5)> lvlup(end) && px(end-1,5)<=lvlup(end)+ticksize
    islvlupbreach = 1;
elseif px(end,5)==lvlup(end) && px(end-1,5)<lvlup(end)
    islvlupbreach = 1;
end
% 20230517:case 2 and case 3 may be removed
% if ~islvlupbreach && (px(end,5)>=lvlup(end) && px(end,4)<lvlup(end))
%     islvlupbreach = 2;
% end
% if ~islvlupbreach && ss(end) <= 9 && px(end,5) >= lvlup(end)
%     idx1 = find(px(end-ss(end):end,5)>lvlup(end),1,'first');
%     if ~isempty(idx1)
%         idx2 = find(px(end-ss(end):end-ss(end)+idx1-1,5)<lvlup(end),1,'first');
%         if ~isempty(idx2), islvlupbreach = 3;end        
%     end    
% end

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
retlast = px(end,5)-px(end-1,5);
isvolblowup2 = retlast>0 & (retlast-mean(barsizerest))/std(barsizerest)>norminv(0.99);

%
lastss9 = find(ss==9,1,'last');
if isempty(lastss9)
    nkfromss = NaN;
    lastss = [];
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

%
lastbs9 = find(bs==9,1,'last');
if isempty(lastbs9)
    lastbs = [];
else
    lastbs = lastbs9;
    for i = lastbs9+1:size(bs,1)
        if bs(i) ~= 0
            lastbs = i;
        else
            break
        end
    end
end

%does it breach-up high of a previous sell sequential
issshighbreach = 0;
if size(ss,1)-lastss+1<=nkfromhh
%case1:the lastest sell sequential finished within the fractal
    lastssval = ss(lastss);
    issshighbreach = px(end,5) > max(px(lastss-lastssval+1:min(lastss,size(px,1)-1),3));
end
if ~issshighbreach && ss(end) > 9
    issshighbreach = px(end,5) > max(px(end-ss(end):end-1,3));
end

%does it firstly breach-up hh after the latest buy sequential without any
%breachup of hh or breachdn of ll in between
if ~isempty(lastbs)
    isfirstbreachsincelastbs = isempty(find(px(lastbs+1:end-1,5)-HH(lastbs+1:end-1)-ticksize+1e-6>0,1,'first'));
    if isfirstbreachsincelastbs
        if px(lastbs,5)-LL(lastbs)+ticksize<1e-6
            %case 1:the buy sequential has been below LL already
            idx = find(px(lastbs+1:end,5)-LL(lastbs+1:end)-ticksize+1e-6>0,1,'first');
            if ~isempty(idx)
                isfirstbreachsincelastbs =  isempty(find(px(lastbs+idx:end-1,5)-LL(lastbs+idx:end-1)+ticksize-1e-6<0,1,'first'));            
            end
        else
            isfirstbreachsincelastbs =  isempty(find(px(lastbs+1:end-1,5)-LL(lastbs+1:end-1)+ticksize-1e-6<0,1,'first'));
        end
    end
else
    isfirstbreachsincelastbs = false;
end

%does it stand beyond a sell sequential with highest high and close price
issshighvalue = ss(end)>= 9 && px(end,5)>=max(px(end-ss(end)+1:end,5)) && px(end,3)>=max(px(end-ss(end)+1:end,3));

%
%does it breach-up hh after sc13
lastsc13 = find(sc(1:end-1)==13,1,'last');
if isempty(lastsc13)
    nkfromsc13 = NaN;
    isschighbreach = false;
else
    nkfromsc13 = size(px,1)-lastsc13;
    idxhhlast = find(idxHH == 1,1,'last');
    if idxhhlast - 2*nfractal <= lastsc13 && lastsc13 <= idxhhlast
        %sc13 happens within the latest fractal
        schigh = HH(end);
    elseif lastsc13 > idxhhlast
        %sc13 happens after the latest fractal
        schigh = max(px(lastsc13:end-1,3));
    elseif lastsc13 < idxhhlast - 2*nfractal
        %sc13 happens before the latest fractal
        schigh = max(px(lastsc13:idxhhlast,3));
    end
    isschighbreach = px(end,5)>=schigh & nkfromsc13 < 13;
end

%
%does it firstly breach-up hh after bc13 without any breachup of hh or 
%breachdn of ll in between
lastbc13 = find(bc(1:end-1)==13,1,'last');
if isempty(lastbc13)
    isfirstbreachsincelastbc13 = false;
else
    isfirstbreachsincelastbc13 = isempty(find(px(lastbc13+1:end-1,5)-HH(lastbc13+1:end-1)-ticksize+1e-6>0,1,'first'));
    if isfirstbreachsincelastbc13
        if px(lastbc13,5)-LL(lastbc13)+ticksize<1e-6
            %case 1:the buy countdown 13 has been below LL already
            idx = find(px(lastbc13+1:end,5)-LL(lastbc13+1:end)-ticksize+1e-6>0,1,'first');
            if ~isempty(idx)
                isfirstbreachsincelastbc13 =  isempty(find(px(lastbc13+idx:end-1,5)-LL(lastbc13+idx:end-1)+ticksize-1e-6<0,1,'first')); 
            end
        else
            isfirstbreachsincelastbc13 =  isempty(find(px(lastbc13+1:end-1,5)-LL(lastbc13+1:end-1)+ticksize-1e-6<0,1,'first'));
        end
    end
end

%
%all the special case above passed
%and to check whether there are 2*nfractal+1 candles stay above teeth
%before it breach the fractal hh
istrendconfirmed = nkaboveteeth>=2*nfractal+1;
if ~istrendconfirmed
    %1.in case all candles are above teeth since hh formed but there are
    %less than 2*nfractal+1 candles since then, we include candles before
    %the hh formed and double check with candles' low
    if nkaboveteeth == nkfromhh
        istrendconfirmed = isempty(find(px(end-2*nfractal:end-1,4)-teeth(end-2*nfractal:end-1)<-2*ticksize,1,'first')) || ...
            isempty(find(px(end-2*nfractal:end-1,5)-max(lips(end-2*nfractal:end-1),teeth(end-2*nfractal:end-1))<-2*ticksize,1,'first'));
        if ~istrendconfirmed
            %in case not all candles' low are above teeth, check
            %1.close are above;
            %2.lips,teeth and jaws are not crossed
            %3.fractal hh moves upward
            flag1 = isempty(find(px(end-2*nfractal:end-1,5)-teeth(end-2*nfractal:end-1)<-2*ticksize,1,'first'));
            flag2 = ~isteethjawcrossed & ~isteethlipscrossed;
            last2hhidx = find(idxHH==1,2,'last');
            if ~isempty(last2hhidx)
                flag3 = HH(last2hhidx(end))-HH(last2hhidx(1))>=-2*ticksize;
            else
                flag3 = false;
            end
            istrendconfirmed = flag1 & flag2 & flag3;
        end
        istrendconfirmed = istrendconfirmed & px(end,5) - teeth(end) >= -2*ticksize;
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
    'isfirstbreachsincelastbs',isfirstbreachsincelastbs,...
    'isfirstbreachsincelastbc13',isfirstbreachsincelastbc13,...
    'ao',ao(end));
% disp(res);