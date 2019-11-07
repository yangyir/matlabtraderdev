function [ outputs ] = tools_dailyreport( assetname )
[ri,oi] = bkfunc_genfutrollinfo(assetname);
[cf,crt,ci] = bkfunc_buildcontinuousfutures(ri,oi);
[res] = bkfunc_hvcalib(crt,'forecastperiod',21,...
    'printresults',false,...
    'plotconditonalvariance',false,...
    'scalefactor',sqrt(252));

rdvec = cell2mat(ri(:,1));
avgrollperiod = floor(mean(diff(rdvec)));
lastbd = ci(end,1);
ndayssincelastroll = lastbd - rdvec(end);

[bs,ss,lvlup,lvldn,bc,sc] = tdsq(ci);
[macdvec,sigvec] = macd(ci(:,5));
diffvec = macdvec-sigvec;

wrperiod = 14;
wpctr = willpctr(ci(:,3), ci(:,4), ci(:,5), wrperiod);
wpctrmat = [wpctr(wrperiod:end-1),ci(wrperiod+1:end,5)-ci(wrperiod:end-1,5)];
wpctrmatsorted = sortrows(wpctrmat);
plot(wpctrmatsorted(:,1),cumsum(wpctrmatsorted(:,2)));

if macdvec(end) < 0
    maind = 'bearish';
else
    maind = 'bullish';
end

if diffvec(end) < 0
    macdind = 'bearish';
else
    macdind = 'bullish';
end

flast = cf(end,5);
ilast = ci(end,5);
flvlup = lvlup(end)/ilast*flast;
flvldn = lvldn(end)/ilast*flast;

outputs = struct('LastContract',ri{end,5},...
    'AverageRollPeriod',avgrollperiod,...
    'ReportDate',datestr(ci(end,1)),...
    'LastRollDate',ri{end,end},...
    'DaysSinceLastRoll',ndayssincelastroll,...
    'LongTermVol',res.LongTermVol,...
    'PeriodInDays',21,...
    'HistoricalVol',res.HistoricalVol,...
    'EWMAVol',res.EWMAVol,...
    'ForecastedVol',res.ForecastedVol,...
    'LastBuySetup',bs(end),...
    'LastSellSetup',ss(end),...
    'LastBuyCountdown',bc(end),...
    'LastSellCountdown',sc(end),...
    'LvlUp',flvlup,...
    'LvlDn',flvldn,...
    'LastPx',flast,...
    'MAIndicator',maind,...
    'MACDIndicator',macdind,...
    'WR',wpctr(end));

end
