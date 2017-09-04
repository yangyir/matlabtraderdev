function [ output_args ] = tu_basictechnical(eoddata,assetname)
%basic technical analysis of daily close prices, trading volume and open
%interest
ncols = size(eoddata,2);
if ncols < 2
    error('tu_basictechnical:input data shall have at least 2 columns')
end

has_volume = false;
has_open_int = false;

if ncols <= 4
    has_volume = true;
end

if ncols == 4 && ~isnan(sum(eoddata(:,4)))
    has_open_int = true;
end

%print last observation date
fprintf('\nlast dt of %s:%s\n',assetname,datestr(eoddata(end,1)));
%print last trade price
fprintf('last px of %s:%4.2f\n',assetname,eoddata(end,2));
%print last price change
dailyret = log(eoddata(2:end,2))-log(eoddata(1:end-1,2));
fprintf('last cg of %s:%4.2f%%\n',assetname,dailyret(end,1)*100);

close all;
% figure
% subplot(2,2,1);autocorr(dailyret);
% subplot(2,2,2);parcorr(dailyret);
% subplot(2,2,3);autocorr(dailyret.^2);
% subplot(2,2,4);parcorr(dailyret.^2);

nplots = 2;

if has_volume
    nplots = nplots+1;
end

if has_open_int
    nplots = nplots+1;
end

figure
%moving average
number1 = 20;number2 = 200;
[pma1,pma2] = movavg(eoddata(:,2),number1,number2,'e');
subplot(nplots,1,1);plot(eoddata(:,2),'b');hold on;plot(pma1,'r');plot(pma2,'g');
title(['time series of ',assetname]);legend('last',['ma',num2str(number1)],['ma',num2str(number2)]);hold off;
%macd
[macdvec, nineperma] = macd(eoddata(:,2));
subplot(nplots,1,2);plot(macdvec,'b');hold on;plot(nineperma,'r');bar(macdvec-nineperma,'g');legend('macdline','nineperma');title('macd');
%volume
if has_volume
    [~,vma] = movavg(eoddata(:,3),1,number1,'e');
    subplot(nplots,1,3);bar(eoddata(:,3),'g');hold on;plot(vma,'b-');legend('volume',['ma',num2str(number1)]);title('volume');
end
%rsi
rsi = rsindex(eoddata(:,2),14);

%print technical numbers
fprintf('technical numbers:\n');
fprintf('\t %d-day price ma:%4.2f\n',number1,pma1(end));
fprintf('\t%d-day price ma:%4.2f\n',number2,pma2(end));
fprintf('\tprice macd:%4.2f\t\t9-period price ema:%4.2f\n',macdvec(end),nineperma(end));
fprintf('\t14-day price rsi:%4.2f\n',rsi(end));
    




end

