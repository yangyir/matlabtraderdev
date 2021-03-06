function [ outputs,ci,ri ] = tools_dailyreport( assetname,figureidx )
if nargin < 2, figureidx = 0;end
[ri,oi] = bkfunc_genfutrollinfo(assetname);
[cf,crt,ci] = bkfunc_buildcontinuousfutures(ri,oi);
%all period
[res] = bkfunc_hvcalib(crt,'forecastperiod',21,'scalefactor',sqrt(252));
%recent 1y
try
    [res_1y] = bkfunc_hvcalib(crt(end-251:end,:),'forecastperiod',21,'scalefactor',sqrt(252));
catch
    res_1y = struct('LongTermVol',NaN);
end
%recent 2y
try
    [res_2y] = bkfunc_hvcalib(crt(end-503:end,:),'forecastperiod',21,'scalefactor',sqrt(252));
catch
    res_2y = struct('LongTermVol',NaN);
end
%recent 3y
try
    [res_3y] = bkfunc_hvcalib(crt(end-755:end,:),'forecastperiod',21,'scalefactor',sqrt(252));
catch
    res_3y = struct('LongTermVol',NaN);
end
%recent 5y
try
    [res_5y] = bkfunc_hvcalib(crt(end-1259:end,:),'forecastperiod',21,'scalefactor',sqrt(252));
catch
    res_5y = struct('LongTermVol',NaN);
end

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

if figureidx > 0 
    figure(figureidx);
    plot(wpctrmatsorted(:,1),cumsum(wpctrmatsorted(:,2)));
    xlabel('william R%');ylabel('cumulative return');title(assetname);
end

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
    'LongTermVol1',res_1y.LongTermVol,...
    'LongTermVol2',res_2y.LongTermVol,...
    'LongTermVol3',res_3y.LongTermVol,...
    'LongTermVol5',res_5y.LongTermVol,...
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

