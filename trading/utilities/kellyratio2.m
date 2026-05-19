function [output] = kellyratio2(pnl)
    
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
    else
        pnllossavg = 0;
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
        'n',ntotal,...
        'maxdrawdown',min(pnldrawdown));




end