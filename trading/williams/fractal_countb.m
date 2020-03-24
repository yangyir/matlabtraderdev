function [nabovelips1,naboveteeth1,nabovelips2,naboveteeth2,n,teethjawcrossed,teethlipscrossed ] = fractal_countb(p,idxHH,nfractal,lips,teeth,jaw)
%nabovelips1:No.of consecutive candles above lips since last hh
%naboveteeth1:No. of consecutive candles above teeth since last hh
%nabovelips2:No.of consecutive candles above lips before last candle
%naboveteeth2:No.of consecutive candles above teeth before last candle

np = size(p,1);
idx_lasthh = find(idxHH(1:np,:) == 1,1,'last');

n = np - idx_lasthh+nfractal+1;

nabovelips1 = 0;
naboveteeth1 = 0;
for i = idx_lasthh-nfractal:np
    if p(i,5) > lips(i)
        nabovelips1 = nabovelips1+1;
    else
        break
    end
end
%
for i = idx_lasthh-nfractal:np
    if p(i,5) > teeth(i)
        naboveteeth1 = naboveteeth1+1;
    else
        break
    end
end
%
%
nabovelips2 = 0;
naboveteeth2 = 0;
for i = np:-1:idx_lasthh-nfractal
    if p(i,5) > lips(i)
        nabovelips2 = nabovelips2+1;
    else
        break
    end
end
%
for i = np:-1:idx_lasthh-nfractal
    if p(i,5) > teeth(i)
        naboveteeth2 = naboveteeth2+1;
    else
        break
    end
end

diff = teeth(np-n+1:np)-jaw(np-n+1:np);
if (~isempty(find(diff>0,1,'first')) && ~isempty(find(diff<0,1,'first')))
    teethjawcrossed = true;
else
    teethjawcrossed = false;
end
%
diff2 = lips(np-n+1:np)-teeth(np-n+1:np);
if (~isempty(find(diff2>0,1,'first')) && ~isempty(find(diff2<0,1,'first')))
    teethlipscrossed = true;
else
    teethlipscrossed = false;
end

end

