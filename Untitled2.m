%%
d = candle_5m{1};
nperiod = 144;
nobs = size(d,1);
highp = d(:,3);
lowp = d(:,4);
closep = d(:,5);
nrecord = nobs-nperiod;
%%
record_upper = zeros(nrecord,1);
record_lower = zeros(nrecord,1);
nh = 0;
nl = 0;
for i = 1:nrecord
    highestp = max(highp(i:i+nperiod-1));
    lowestp = min(lowp(i:i+nperiod-1));
    p = closep(i+nperiod);
    if p >= highestp
        %find out how many buckets of time period later the highest price
        %is updated
        nh = nh+1;
        for j = i+nperiod+1:nobs
            if closep(j) > p
                record_upper(nh,1) = j-i-nperiod;
                break
            end
        end
    elseif p <= lowestp
        %find out how many buckets of time period later the lowest price is
        %updated
        nl = nl + 1;
        for j = i+nperiod+1:nobs
            if closep(j) < p
                record_lower(nl,1) = j-i-nperiod;
                break
            end
        end
    else
        
    end
end
record_upper = record_upper(1:nh,:);
record_lower = record_lower(1:nl,:);
subplot(211);
hist(record_upper,40);title('upper');
subplot(212);
hist(record_lower,40);title('lower');
%%
%risk control
maxposition = inf;
maxdrawdown = inf;
%
trades_long = zeros(nrecord,1);
trades_sell = zeros(nrecord,1);
positions = zeros(nrecord,1);
costs = zeros(nrecord,1);
pnl = zeros(nrecord,1);
wrindicators = zeros(nrecord,1);
%
for i = 1:nrecord
    highestp = max(highp(i:i+nperiod-1));
    lowestp = min(lowp(i:i+nperiod-1));
    p = closep(i+nperiod);
    if p >= highestp
        wrindicators(i) = 0;
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
%             if wrindicators(i) > wrindicators(i-1)
%                 positions(i) = positions(i-1);
%             else
                positions(i) = -1;
%             end
        end
        %
    elseif p <= lowestp
        wrindicators(i) = -100;
        %in case the close price is lower than the lowest of the previous
        %selected period, it is taken as a over-sold signal
        if i == 1, positions(i) = 1; end
        if i > 1 && positions(i-1) == 0, positions(i) = 1;end
        if i > 1 && positions(i-1) > 0
%             positions(i) = min(maxposition,2*positions(i-1));
            positions(i) = min(maxposition,positions(i-1)+1);
        end
        if i > 1 && positions(i-1) < 0
            if wrindicators(i) < wrindicators(i-1)
%                 positions(i) = positions(i-1);
%             else
                positions(i) = 1;
            end
        end
    else
        wrindicators(i) = (p-lowestp)/(highestp-lowestp)*-100;
        if i > 1, positions(i) = positions(i-1);end
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
plot(closep(nperiod+1:end),'b');grid on;title('close');
subplot(222)
bar(positions);grid on;title('position');
subplot(223)
plot(wrindicators,'g');grid on;title('william R');
subplot(224)
plot(pnl,'r');grid on;title('pnl');




