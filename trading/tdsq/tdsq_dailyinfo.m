function [ outputs ] = tdsq_dailyinfo(assetname)
    [rollinfo,pxoidata] = bkfunc_genfutrollinfo(assetname);
    [continuousfutures,continuousret,continuousindex] = bkfunc_buildcontinuousfutures(rollinfo,pxoidata);
    fprintf('\nlast observation date:%s\n',datestr(continuousfutures(end,1)));
    if continuousfutures(end,1) > rollinfo{end,1}
        fprintf('last active contract:%s\n',rollinfo{end,5});
    elseif continuousfutures(end,1) == rollinfo{end,1}
        fprintf('last active contract:%s\n',rollinfo{end,4});
    else
        error('unknown error\n');
    end
    fprintf('last price:%s\tlast index:%s\n',num2str(continuousfutures(end,5)),num2str(continuousindex(end,5)));
    [bs_daily,ss_daily,lvlup_daily,lvldn_daily,bc_daily,sc_daily] = tdsq(continuousindex);
    lastidx_bs9_daily = find(bs_daily == 9,1,'last');
    lastidx_ss9_daily = find(ss_daily == 9,1,'last');
    fprintf('last B setup from %s to %s\n',datestr(continuousindex(lastidx_bs9_daily-8,1)),datestr(continuousindex(lastidx_bs9_daily,1)));
    fprintf('last S setup from %s to %s\n',datestr(continuousindex(lastidx_ss9_daily-8,1)),datestr(continuousindex(lastidx_ss9_daily,1)));
    lastlvlup_daily = lvlup_daily(end)/continuousindex(end)*continuousfutures(end,5);
    lastlvldn_daily = lvldn_daily(end)/continuousindex(end)*continuousfutures(end,5);
    fprintf('last lvlup-price:%s\tlast lvlup-index:%s\n',num2str(lastlvlup_daily),num2str(lvlup_daily(end)));
    fprintf('last lvldn-price:%s\tlast lvldn-index:%s\n',num2str(lastlvldn_daily),num2str(lvldn_daily(end)));
    
    %
    [lead_daily,lag_daily] = movavg(continuousindex(:,5),12,26,'e');
    macdvec_daily = lead_daily-lag_daily;
    [~,sigvec_daily] = movavg(macdvec_daily,1,9,'e');
    wr_daily = willpctr(continuousindex(:,3),continuousindex(:,4),continuousindex(:,5),144);

    outputs = struct('rollinfo',{rollinfo},...
        'pxoidata',{pxoidata},...
        'continuousfutures',{continuousfutures},...
        'continuousret',{continuousret},...
        'continuousindex',{continuousindex},...
        'bs_daily',{bs_daily},...
        'ss_daily',{ss_daily},...
        'lvlup_daily',{lvlup_daily},...
        'lvldn_daily',{lvldn_daily},...
        'bc_daily',{bc_daily},...
        'sc_daily',{sc_daily},...
        'macdvec_daily',{macdvec_daily},...
        'sigvec_daily',{sigvec_daily},...
        'wr_daily',{wr_daily});
        

end

