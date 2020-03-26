function [nbelowlips1,nbelowteeth1,nbelowlips2,nbelowteeth2,n,teethjawcrossed,teethlipscrossed ] = fractal_counts(p,idxLL,nfractal,lips,teeth,jaw)
%nabovelips1:No.of consecutive candles below lips since last ll
%naboveteeth1:No. of consecutive candles below teeth since last ll
%nabovelips2:No.of consecutive candles below lips before last candle
%naboveteeth2:No.of consecutive candles below teeth before last candle

np = size(p,1);
idx_lastll = find(idxLL(1:np,:) == -1,1,'last');

n = np - idx_lastll+nfractal+1;

nbelowlips1 = 0;
nbelowteeth1 = 0;
for i = idx_lastll-nfractal:np
    if p(i,5) < lips(i)
        nbelowlips1 = nbelowlips1+1;
    else
        break
    end
end
%
for i = idx_lastll-nfractal:np
    if p(i,5) < teeth(i)
        nbelowteeth1 = nbelowteeth1+1;
    else
        break
    end
end
%
%
nbelowlips2 = 0;
nbelowteeth2 = 0;
for i = np:-1:idx_lastll-nfractal
    if p(i,5) < lips(i)
        nbelowlips2 = nbelowlips2+1;
    else
        break
    end
end
%
for i = np:-1:idx_lastll-nfractal
    if p(i,5) < teeth(i)
        nbelowteeth2 = nbelowteeth2+1;
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

