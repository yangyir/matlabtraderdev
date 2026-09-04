function [output] = kellyratio2(pnl,doplot)

    if nargin < 2
        doplot = 0;
    end

    ntotal = size(pnl,1);
    if ntotal == 0
        output = struct('w',0,...
            'r',0,...
            'k',0,...
            'winavg',0,...
            'lossavg',0,...
            'n',0,...
            'maxdrawdown',0);
        return
    end

    nwin = 0;
    pnlwin = 0;
    pnlloss = 0;
    for i = 1:size(pnl,1)
        if pnl(i) >= 0
            nwin = nwin + 1;
            pnlwin = pnlwin + pnl(i);
        else
            pnlloss = pnlloss + pnl(i);
        end
    end

    winprop = nwin / ntotal;
    if nwin > 0
        pnlwinavg = pnlwin / nwin;
    else
        pnlwinavg = 0;
    end

    if ntotal - nwin > 0
        pnllossavg = pnlloss / (ntotal-nwin);
        pnllossvec = pnl(pnl<0);
        pnl95quantile = quantile(pnllossvec,0.05);
    else
        pnllossavg = 0;
        pnl95quantile = 0;
    end

    r = abs(pnlwinavg/pnllossavg);

    if pnllossavg == 0
        k = winprop;
    else
        k = winprop - (1-winprop) / r;
    end

    pnlcum = cumsum(pnl);
    pnlmax = pnlcum;
    for i = 1:length(pnl)
        pnlmax(i) = max(pnlcum(1:i));

        if pnlmax(i) < 0, pnlmax(i) = 0;end
    end
    pnldrawdown = pnlcum - pnlmax;

    output = struct('w',winprop,...
        'r',r,...
        'k',k,...
        'winavg',pnlwinavg,...
        'lossavg',pnllossavg,...
        'loss95',pnl95quantile,...
        'n',ntotal,...
        'maxdrawdown',min(pnldrawdown),...
        'totalpl',sum(pnl),...
        'calmar',abs(sum(pnl)/min(pnldrawdown)),...
        'sharp',mean(pnl)/std(pnl));

    if doplot
        nTrials = 50;
        rng(100);
        if ntotal > 50
            nSample = max(ceil(ntotal/3),30);
        else
            nSample = ceil(nRecords/2);
        end
        wTrials = zeros(nTrials,1);
        rTrials = zeros(nTrials,1);
    
        for i = 1:nTrials
            idxRand = randperm(ntotal,nSample);
            temp = pnl(idxRand);
            [w,r,~] = calcrunningkelly(temp);
            wTrials(i) = w(end);
            rTrials(i) = r(end);    
        end
    
        try
            wH = kstest((wTrials-mean(wTrials))/std(wTrials));
        catch
            wH = 1;
        end
        [wMu,wSigma] = normfit(wTrials,0.05);
        try
            rH = kstest((rTrials-mean(rTrials))/std(rTrials));
        catch
            rH = 1;
        end
        [rMu,rSigma] = normfit(rTrials,0.05);
    

        close all;
        set(0,'defaultfigurewindowstyle','docked');
        [winp_running,R_running,~] = calcrunningkelly(pnl);
        figure(1);
        subplot(211);plot(winp_running,'r');title('win ratio');ylabel('ratio');xlabel('sample size');grid on;
        hold on;
        yline(wMu+wSigma,'r--','upper range', 'LineWidth', 1.5);
        yline(wMu-wSigma,'r--','lower range', 'LineWidth', 1.5);
        hold off;
        %
        subplot(212);plot(R_running,'b');title('profit/loss ratio');ylabel('ratio');xlabel('sample size');grid on;
        hold on;
        yline(rMu+rSigma,'b--','upper range', 'LineWidth', 1.5);
        yline(rMu-rSigma,'b--','lower range', 'LineWidth', 1.5);
        hold off;


%         subplot(313);plot(kelly_running,'g');xlabel('number of trades');ylabel('kelly criteria');grid on;
    end

end