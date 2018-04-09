function [wrpct,positions,pnl] = backtest_wr(candles,nperiods,varargin)
% NOTE:
% William-R related trading strategy logic
% select nperiods,i.e.high,low,close price
% Entry:
% in case the close price is either EQUAL to or LOWER than the lowest price
% of the previous selected periods, LONG entry with specified lots of
% futures.
% repeat the above untill either a)the maximum number of lots is breached
% or b) a stop-loss is triggered
%
% in case the close price is either EQUAL to or HIGHER than the highest
% price of the previous selected periods, SHORT entry with specified lots
% of futures.
% repeat the above until either a)the maximum number of lots is breached or
% b) a stop-loss is triggered
%
% Exit:
% in case there is a LONG position, unwind the LONG position once the
% William-R indicator falls below -50 from above. o/w, keep the LONG
% position as long as the William-R indicator stays above -50.
%
% in case there is SHORT position, unwind the SHORT position once the
% William-R indicator shots above -50 from below. o/w, keep the SHORT
% position as long as the William-R indicator stays below -50
%
%
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addRequired('Candles',@isnumeric);
p.addRequired('Nperiods',@isnumeric);
p.addParameter('ContractSize',1,@isnumeric);
p.addParameter('MaximumNumofContracts',inf,@isnumeric);
p.addParameter('Stop',-inf,@isnumeric);
p.addParameter('Limit',inf,@isnumeric);

p.parse(candles,nperiods,varargin{:});

candles = p.Results.Candles;
nperiods = p.Results.Nperiods;
contractsize = p.Results.ContractSize;
nmax = p.Results.MaximumNumofContracts;
pnlstop = p.Results.Stop;
pnllimit = p.Results.Limit;
%
% openp = candles(:,2);
highp = candles(:,3);
lowp = candles(:,4);
closep = candles(:,5);
%
% this is a basic version of backtest utility function as only the close
% prices are assumed to be traded. an advanced version can be viewed in
% another M-file
nobs = size(closep,1);
n = nobs - nperiods;
pnl = zeros(n,1);
positions = zeros(n,1);
wrpct = zeros(n,1);

flagui = false;
% flagdo = false;
flagdi = false;
% flaguo = false;
for i = 1:n
    highestp = max(highp(i:i+nperiods-1,:));
    lowestp = min(lowp(i:i+nperiods-1,:));
    cp = closep(i+nperiods,1);
    wrpct(i) = -100*(max(highp(i+1:i+nperiods,:))-cp)/(max(highp(i+1:i+nperiods,:))-min(lowp(i+1:i+nperiods,:)));
    if i == 1
        if cp <= lowestp
            positions(i) = 1;
        elseif cp >= highestp
            positions(i) = -1;
        else
            positions(i) = 0;
        end
        pnl(i) = 0;
    else
        if positions(i-1) == 0
            if cp <= lowestp
                positions(i) = 1;
            elseif cp >= highestp
                positions(i) = -1;
            else
                positions(i) = 0;
            end
        elseif positions(i-1) > 0
            if ~flagui
                % scenario 1:existing LONG position without William-R
                % indicator breaking through -50 from below
                if cp <= lowestp
                    positions(i) = min(positions(i-1) + 1,nmax); 
                else
                    positions(i) = positions(i-1);
                end
                if wrpct(i) >= -50, flagui = true; end
            else
                % scenario 2: existing LONG position with William-R
                % indicator used to break through -50 from below
                if wrpct(i) >= -50, positions(i) = positions(i-1); end
                if wrpct(i) < -50, positions(i) = 0; flagui = false;end
            end
        elseif positions(i-1) < 0
            if ~flagdi
                % scenario 3: existing SHORT position without William-R
                % indicator breaking through -50 from above
                if cp >= highestp
                    positions(i) = max(positions(i-1) - 1,-nmax);
                else
                    positions(i) = positions(i-1);
                end
                if wrpct(i) < -50, flagdi = true; end
            else
                % scenario 4: existing SHORT position with William-R
                % indicator used to break through -50 from above
                if wrpct(i) < -50, positions(i) = positions(i-1);end
                if wrpct(i) >= -50, positions(i) = 0; flagdi = false;end
            end
        end
        pnl(i) = positions(i-1)*(cp-closep(i+nperiods-1,1))*contractsize;
    end 
end

subplot(221)
plot(closep(nperiods+1:end),'b');grid on;title('close');
subplot(222)
bar(positions);grid on;title('position');
subplot(223)
plot(wrpct,'g');grid on;title('william R');
subplot(224)
plot(cumsum(pnl),'r');grid on;title('pnl');
