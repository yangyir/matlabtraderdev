function [output] = kellyratio2(pnl)
    
    ntotal = size(pnl,1);
    if ntotal == 0
        output = [];
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

    output = struct('w',winprop,...
        'r',r,...
        'k',k,...
        'winavg',pnlwinavg,...
        'lossavg',pnllossavg,...
        'n',ntotal);




end