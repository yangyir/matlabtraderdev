function [ maxsharp,optimallead,optimallag ] = tu_optimize_ma( eoddata )
%
%function to optimize the lead/lag parameter for moving average
%
nLead = 50;
nLag = 200;

sharps = zeros(nLead,nLag);

nt = size(eoddata,1);

for i = 1:nLead
    for j = 1:nLag
        if i < j
            [lead,lag] = movavg(eoddata(:,2),i,j,'e');
            pos = zeros(nt,1);
            for k = 1:nt
                if lead(k) > lag(k)
                    pos(k) = 1;
                elseif lead(k) < lag(k)
                    pos(k) = -1;
                else
                    pos(k) = 0;
                end
            end
            pnl = pos(1:nt-1).*(eoddata(2:end,2)-eoddata(1:end-1,2));
            sharps(i,j) = mean(pnl)/std(pnl)*sqrt(252);
        end
    end
end

maxsharp = max(max(sharps));

for i = 1:nLead
    for j = 1:nLag
        if i < j && sharps(i,j) == maxsharp
            optimallead = i;
            optimallag = j;
            break
        end
    end
end

[lead,lag] = movavg(eoddata(:,2),optimallead,optimallag,'e');
if lead(end) > lag(end)
    signal = 'buy';
elseif lead(end) < lag(end)
    signal = 'sell';
else
    signal = 'neutral';
end

fprintf('optimal lead:%d; lag:%d; max sharp:%4.2f; signal:%s\n',...
    optimallead,optimallag,maxsharp,signal);


end

