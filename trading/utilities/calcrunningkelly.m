function [winp_running,R_running,kelly_running] = calcrunningkelly(pnl2check)
%calculate running win prob, R and kelly criterion
    nn = size(pnl2check,1);
    winflag = zeros(nn,3);
    nwintrade = 0;
    wintotalpnl = 0;
    losstotalpnl = 0;
    winavgpnl_running = zeros(nn,1);
    lossavgpnl_running = zeros(nn,1);
    for j = 1:nn
        if pnl2check(j) >= 0
            winflag(j,1) = 1;
            nwintrade = nwintrade + 1;
            wintotalpnl = wintotalpnl + pnl2check(j);
        else
            winflag(j,1) = 0;
            losstotalpnl = losstotalpnl + pnl2check(j);
        end
        winflag(j,2) = j;
        winflag(j,3) = nwintrade;
        if nwintrade == 0
            winavgpnl_running(j) = 0;
        else
            winavgpnl_running(j) = wintotalpnl/nwintrade;
        end
        if nwintrade == j
            lossavgpnl_running(j) = 0;
        else
            lossavgpnl_running(j) = losstotalpnl/(j-nwintrade);
        end
    end
    winp_running = winflag(:,3)./winflag(:,2);
    R_running = abs(winavgpnl_running./lossavgpnl_running);
    kelly_running = winp_running - (1-winp_running)./R_running;
end

