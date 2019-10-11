path = getenv('DATAPATH');
fn = [path,'corn_daily.txt'];
[ri,oi] = bkfunc_genfutrollinfo('corn');
[cfut,crt,ci] = bkfunc_buildcontinuousfutures(ri,oi);
cDataFileIO.saveDataToTxtFile(fn,ci,{'date';'open';'high';'low';'close'},'w',false);
%% load historical data if bbg is not installed
hd = cDataFileIO.loadDataFromTxtFile(fn);
hd = [hd(:,1),hd(:,5)];
hd = timeseries_window(hd,'fromdate','2016-09-30','todate','2019-10-11');
%% 3m ewma vol
nperiod = 63;
classicalvol = historicalvol(hd,nperiod,'classical');classicalvol = [classicalvol(:,1),sqrt(252)*classicalvol(:,2)];
ewmavol = historicalvol(hd,nperiod,'ewma');ewmavol = [ewmavol(:,1),sqrt(252)*ewmavol(:,2)];
subplot(311);plot(hd(:,2));title('price');grid on;
subplot(312);plot(classicalvol(:,2),'r');title('classicvol');grid on;
subplot(313);plot(ewmavol(:,2),'r');title('ewmavol');grid on;
%%
N = size(hd,1);
straddles = bkcVanillaArray;
count = 1;
for i = nperiod:N
    id = count;
    strike = hd(i,2);
    opendt = hd(i,1);
    try
        expirydt = hd(i+nperiod-1,1);
    catch
        expirydt = dateadd(opendt,[num2str(nperiod),'b']);
    end
    straddle_i = bkcStraddle('id',id,'code','iron ore',...
        'strike',strike,'opendt',opendt,'expirydt',expirydt);
    straddle_i.valuation('Spots',hd,'Vols',ewmavol,'VolMethod','dynamic');
    straddles.push(straddle_i);
    count = count + 1;
end
%%
%% stats and plots without leverage
limit = 1.5;
stop = 0.9;
dayscut = 30;
criterial = 'delta';
finalrets = straddles.unwindinfo('limit',limit,'stop',stop,'dayscut',dayscut,'criterial',criterial);
%%
ret = hd(2:end,2)./hd(1:end-1,2)-1;
variance = ret.^2;
sigmavar = sqrt(quantile(variance,0.95));
marginrate = 0.1;
initialmargin = dayscut*marginrate;
pr = max(1-sigmavar/marginrate,0.75);

[marginaccountvalue,marginused,deltacarry] = straddles.runningpvsynthetic('InitialMargin',initialmargin,...
    'marginrate',marginrate,'participaterate',pr);

figure(3);
subplot(211);
plot(marginused,'r');grid on;title('margin over time');
hold on;plot(marginaccountvalue,'b');hold off;legend('marginused','accountvalue','location','northwest');
subplot(212);plot(deltacarry);title('delta over time');grid on;
fprintf('%2.1f\n',marginaccountvalue(end,1));
