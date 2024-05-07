function [res] = fractal_s1_status(nfractal,extrainfo,ticksize)

if nargin < 3
    ticksize = 0;
end
try
    px = extrainfo.px;
catch
    px = extrainfo.p;
end
ss = extrainfo.ss;
bs = extrainfo.bs;
sc = extrainfo.sc;
bc = extrainfo.bc;
lvlup = extrainfo.lvlup;
lvldn = extrainfo.lvldn;
idxLL = extrainfo.idxll;
HH = extrainfo.hh;
LL = extrainfo.ll;
lips = extrainfo.lips;
teeth = extrainfo.teeth;
jaw = extrainfo.jaw;
% wad = extrainfo.wad;

if LL(end) - teeth(end) < ticksize
    if teeth(end) < jaw(end)
        s1type = 3;
    elseif teeth(end) >= jaw(end)
        s1type = 2;
    end
else
    s1type = 1;
end

%islvldnbreach
%islvldnbreach = 1 indicates that the breach happens on the latest candle
%islvldnbreach = 2 indicates that the latest candle closes below lvldn with
%its high is above lvldn
%islvldnbreach = 3 indicates that the latest TDST buy sequential has
%beached dn lvldn
islvldnbreach = 0;
if px(end,5)<=lvldn(end) && px(end-1,5)>lvldn(end)
    islvldnbreach = 1;
end
% 20230517:case 2 and case 3 may be removed
% if ~islvldnbreach && (px(end,5)<=lvldn(end) && px(end,3)>lvldn(end))
%     islvldnbreach = 2;
% end
% if ~islvldnbreach && bs(end) <= 9 && px(end,5)<=lvldn(end)
%     idx1 = find(px(end-bs(end):end,5)<lvldn(end),1,'first');
%     if ~isempty(idx1)
%         idx2 = find(px(end-bs(end):end-bs(end)+idx1-1,5)>lvldn(end),1,'first');
%         if ~isempty(idx2),islvldnbreach = 3;end
%     end
% end

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
retlast = px(end,5)-px(end-1,5);
isvolblowup2 = retlast<0 & (abs(retlast)-mean(barsizerest))/std(barsizerest)>norminv(0.99);

%
lastbs9 = find(bs==9,1,'last');
if isempty(lastbs9)
    nkfrombs = NaN;
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
    nkfrombs = size(bs,1)-lastbs;
end

%
lastss9 = find(ss==9,1,'last');
if isempty(lastss9)
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
end

%does it breach-dn low of a previous buy sequential
isbslowbreach = 0;
if size(bs,1)-lastbs+1<=nkfromll
%case1:the latest buy sequential finished within the fractal
    lastbsval = bs(lastbs);
    isbslowbreach = px(end,5) < min(px(lastbs-lastbsval+1:min(lastbs,size(px,1)-1),4));
end
if ~isbslowbreach && bs(end) > 9
    isbslowbreach = px(end,5) < min(px(end-bs(end):end-1,4));
end

%does it firstly breach-dn ll after the latest sell sequential without any
%breachdn of ll or breachup of hh in between
if ~isempty(lastss)
    isfirstbreachsincelastss = isempty(find(px(lastss+1:end-1,5)-LL(lastss+1:end-1)+ticksize-1e-6<0,1,'first'));
    if isfirstbreachsincelastss
        if px(lastss,5)-HH(lastss)-ticksize>-1e-6
            %case 1:the sell sequential has been above HH already
            idx = find(px(lastss+1:end,5)-HH(lastss+1:end)-ticksize-1e-6<0,1,'first');
            if ~isempty(idx)
                isfirstbreachsincelastss =  isempty(find(px(lastss+idx:end-1,5)-HH(lastss+idx:end-1)-ticksize+1e-6>0,1,'first'));            
            end
        else
            isfirstbreachsincelastss =  isempty(find(px(lastss+1:end-1,5)-HH(lastss+1:end-1)-ticksize+1e-6>0,1,'first'));
        end
    end
else
    isfirstbreachsincelastss = false;
end

%
%does it stand beyond a buy sequential with lowest low and close price
isbshighvalue = bs(end)>=9 && px(end,5)<=min(px(end-bs(end)+1:end,5)) && px(end,4)<=min(px(end-bs(end)+1:end,4));

%
%does it breach-dn ll after bc13
lastbc13 = find(bc(1:end-1)==13,1,'last');
if isempty(lastbc13)
    nkfrombc13 = NaN;
    isbclowbreach = false;
else
    nkfrombc13 = size(px,1)-lastbc13;
    idxlllast = find(idxLL == -1,1,'last');
    if idxlllast - 2*nfractal <= lastbc13 && lastbc13 <= idxlllast
        %bc13 happens within the latest fractal
        bclow = LL(end);
    elseif lastbc13 > idxlllast
        %bc13 happens after the latest fractal
        bclow = min(px(lastbc13:end-1,4));
    elseif lastbc13 < idxlllast - 2*nfractal
        %bc13 happens before the latest fractal
        bclow = min(px(lastbc13:idxlllast,4));
    end
    isbclowbreach = px(end,5)<bclow & nkfrombc13 < 13;
end

%does it firstly breach-dn ll after sc13 without any breachdn of ll or
%breachup of hh in between
lastsc13 = find(sc(1:end-1)==13,1,'last');
if isempty(lastsc13)
    isfirstbreachsincelastsc13 = false;
else
    isfirstbreachsincelastsc13 = isempty(find(px(lastsc13+1:end-1,5)-LL(lastsc13+1:end-1)+ticksize-1e-6<0,1,'first'));
    if isfirstbreachsincelastsc13
        if px(lastsc13,5)-HH(lastsc13)-ticksize+1e-6>0
            %case 1:the sell countdown 13 has been above HH already
            idx = find(px(lastsc13+1:end,5)-HH(lastsc13+1:end)+ticksize-1e-6<0,1,'first');
            if ~isempty(idx)
                isfirstbreachsincelastsc13 =  isempty(find(px(lastsc13+idx:end-1,5)-HH(lastsc13+idx:end-1)-ticksize+1e-6>0,1,'first'));
            end
        else
            isfirstbreachsincelastsc13 =  isempty(find(px(lastsc13+1:end-1,5)-HH(lastsc13+1:end-1)-ticksize+1e-6>0,1,'first'));
        end
    end
end

%
%all the special case above passed
%and to check whether there are 2*nfractal+1 candles stay below teeth
%before it breach the fractal ll
istrendconfirmed = nkbelowteeth>=2*nfractal+1;
if ~istrendconfirmed
    %1.in case all candles are below teeth since ll formed but there are
    %less than 2*nfractal+1 candles since then, we include candles before
    %the ll formed and double check with candle's high
    if nkbelowteeth == nkfromll
        istrendconfirmed = isempty(find(px(end-2*nfractal:end-1,3)-teeth(end-2*nfractal:end-1)>2*ticksize,1,'first')) ||...
            isempty(find(px(end-2*nfractal:end-1,5)-min(lips(end-2*nfractal:end-1),teeth(end-2*nfractal:end-1))>2*ticksize,1,'first'));
        if ~istrendconfirmed
            %in case not all candle's high are below teeth, check:
            %1.close are below;
            %2.lips,teeth and jaws are not crossed
            %3.fractal ll moves downward
            flag1 = isempty(find(px(end-2*nfractal:end-1,5)-teeth(end-2*nfractal:end-1)>2*ticksize,1,'first'));
            flag2 = ~isteethjawcrossed & ~isteethlipscrossed;
            last2llidx = find(idxLL==-1,2,'last');
            if ~isempty(last2llidx)
                flag3 = LL(last2llidx(end))-LL(last2llidx(1))<=2*ticksize;
            else
                flag3 = false;
            end
            istrendconfirmed = flag1 & flag2 & flag3;
            if ~istrendconfirmed
                lipsbelowteeth = isempty(find(lips(end-2*nfractal+1:end)-teeth(end-2*nfractal+1:end)>0,1,'first'));
                teethbelowjaws = isempty(find(teeth(end-2*nfractal+1:end)-jaw(end-2*nfractal+1:end)>0,1,'first'));
                exceptionflag = flag3 | (~isteethjawcrossed & lipsbelowteeth & teethbelowjaws);
                istrendconfirmed = flag1 & ~isteethlipscrossed & exceptionflag;
            end
        end
        istrendconfirmed = istrendconfirmed & px(end,5)-teeth(end) <= 2*ticksize;
    end
end
%to be in line with the trading code
istrendconfirmed = istrendconfirmed & px(end-1,5) < teeth(end-1);

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
    'isfirstbreachsincelastss',isfirstbreachsincelastss,...
    'isfirstbreachsincelastsc13',isfirstbreachsincelastsc13,...
    'ao',ao(end));
% disp(res);

end