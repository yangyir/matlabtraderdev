function [ratio,W,winavgpnl,lossavgpnl] = kellyratio(tradesin)
wincount = 0;
losscount = 0;
wintotalpnl = 0;
losstotalpnl = 0;
for itrade = 1:tradesin.latest_
    if ~isempty(tradesin.node_(itrade).closepnl_)
        pnl_i = tradesin.node_(itrade).closepnl_;
    else
        pnl_i = tradesin.node_(itrade).runningpnl_;
    end
    
    if pnl_i > 0
        wincount = wincount + 1;
        wintotalpnl = wintotalpnl + pnl_i;
    else
        losscount = losscount + 1;
        losstotalpnl = losstotalpnl + pnl_i;
        
    end
end
W = wincount / (wincount + losscount);
winavgpnl = wintotalpnl/wincount;
lossavgpnl = losstotalpnl/losscount;
R = abs(winavgpnl/lossavgpnl);
if W == 1
    ratio = 1;
    lossavgpnl = NaN;
else
    ratio = W-(1-W)/R;
end

end