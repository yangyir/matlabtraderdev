%%
c = bbgconnect;
%%
% download historical price
baseMetals = {'copper';'aluminum';'zinc';'lead'};
periodEnd = businessdate(today,-1);
periodStart = dateadd(periodEnd,'-5y');
nBaseMetals = size(baseMetals,1);
histPrice = cell(nBaseMetals,1);
for i = 1:nBaseMetals
    info = getassetinfo(baseMetals{i});
    bbgcode = info.BloombergCode;
    sec = [bbgcode,'1',' Comdty'];
    data = history(c,sec,{'px_high','px_low','px_open','px_last','volume'},periodStart,periodEnd);
    histPrice{i} = fints(data(:,1),data(:,2:end),{'high','low','open','close','volume'},'daily');
end

%%
% Calculate and plot the RSI for copper futures along with the price range using these commands:
i = 4;
part_asset = fillts(histPrice{i}('01-Jan-2016::09-Dec-2016'));
rsi_asset = rsindex(part_asset);
close all;
subplot(3, 1, 1);
plot(rsi_asset);
title(['RSI of ',baseMetals{i},' futures, Jan16-Dec16']);
datetick('x', 'mm/dd/yy');
hold on;
wpctr_asset = willpctr(part_asset);
plot(rsi_asset.dates, 30*ones(1, length(wpctr_asset)),...
'color', [0.5 0 0], 'linewidth', 2)
plot(rsi_asset.dates, 70*ones(1, length(wpctr_asset)),...
'color',[0 0.5 0], 'linewidth', 2)
subplot(3, 1, 2);
candle(part_asset);
title([baseMetals{i},' futures prices, Jan16-Dec16']);
datetick('x', 'mm/dd/yy');
% calculate the MACD, which when plotted produces two lines; the first line
% is the MACD line itself and the second is the nine-period moving average
% line:
macd_asset = macd(part_asset);
subplot(3, 1, 3);
plot(macd_asset);
title(['MACD of ',baseMetals{i},' futures, Jan16-Dec16']);

