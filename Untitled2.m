%%
d = candle_15m{1};
nperiods = 144;
nobs = size(d,1);
openp = d(:,2);
highp = d(:,3);
lowp = d(:,4);
closep = d(:,5);
nrecords = nobs-nperiods;

%%
%risk control
maxposition = inf;
maxdrawdown = inf;
%level down and out
leveldo = -50;
%level up and out
leveluo = -50;
%
trades_long = zeros(nrecords,1);
trades_sell = zeros(nrecords,1);
positions = zeros(nrecords,1);
costs = zeros(nrecords,1);
pnl = zeros(nrecords,1);
wrindicators = zeros(nrecords,1);
%
upperhit = false;
lowerhit = false;
for i = 1:nrecords
    highestp = max(highp(i:i+nperiods-1));
    lowestp = min(lowp(i:i+nperiods-1));
    p = closep(i+nperiods);
    wr = willpctr(highp(i:i+nperiods),lowp(i:i+nperiods),closep(i:i+nperiods),nperiods);
    wrindicators(i) = wr(end);
    if p >= highestp
        %in case the close price is higher than the highest of the previous
        %selected period, it is taken as a over-bought signal
        if i == 1, positions(i) = -1;end
        if i > 1 && positions(i-1) == 0, positions(i) = -1;end
        if i > 1 && positions(i-1) < 0 
%             positions(i) = max(-maxposition,2*positions(i-1));
            positions(i) = max(-maxposition,positions(i-1)-1);
        end
        %in case a new high is breached, the trend momentum might still
        %last for a couple of time period and we shall unwind the existing
        %long position once the wr indicator breaches -50 from the top
        if i > 1 && positions(i-1) > 0
            upperhit = true;
            positions(i) = positions(i-1);
        end
        %
    elseif p <= lowestp
        %in case the close price is lower than the lowest of the previous
        %selected period, it is taken as a over-sold signal
        if i == 1, positions(i) = 1; end
        if i > 1 && positions(i-1) == 0, positions(i) = 1;end
        if i > 1 && positions(i-1) > 0
%             positions(i) = min(maxposition,2*positions(i-1));
            positions(i) = min(maxposition,positions(i-1)+1);
        end
        if i > 1 && positions(i-1) < 0
            lowerhit = true;
            positions(i) = positions(i-1);
        end
    else
        if i > 1 
            if upperhit && wrindicators(i) < leveldo
                positions(i) = 0;
                upperhit = false;
            elseif lowerhit && wrindicators(i) > leveluo
                positions(i) = 0;
            else
                positions(i) = positions(i-1);
            end
        end
    end
    %
    if i == 1 && positions(i) == 0, costs(i) = 0; end
    if i > 1 && positions(i) == 0, costs(i) = 0; end
    if i > 1 && positions(i) ~= 0, costs(i) = (costs(i-1)*positions(i-1) + p*(positions(i)-positions(i-1)))/positions(i);end
    if i > 1, pnl(i) = (p-costs(i-1))*positions(i-1);end
    
    if i > 1 && pnl(i) - pnl(i-1) <= -maxdrawdown
        positions(i) = 0;
    end
end
subplot(221)
plot(closep(nperiods+1:end),'b');grid on;title('close');
subplot(222)
bar(positions);grid on;title('position');
subplot(223)
plot(wrindicators,'g');grid on;title('william R');
subplot(224)
plot(pnl,'r');grid on;title('pnl');




