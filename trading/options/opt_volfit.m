% inputs
code_underlier = 'SR001';
bucketsize = 100;
cobdate = datenum('2019-11-21','yyyy-mm-dd');
optexpiry = datenum('2019-12-04','yyyy-mm-dd');
%% compute vol-slice
calendar_tau = (optexpiry-cobdate)/365;
hd_underlier = cDataFileIO.loadDataFromTxtFile([code_underlier,'_daily.txt']);
spot = hd_underlier(hd_underlier(:,1) == cobdate,5);
k_dn = floor(spot/bucketsize)*bucketsize;
k_up = ceil(spot/bucketsize)*bucketsize;
strikes = k_dn-3*bucketsize:bucketsize:k_up+3*bucketsize;
nstrikes = length(strikes);
vols = zeros(nstrikes,1);
m = log(strikes./spot)/sqrt(calendar_tau);m=m';
for i = 1:nstrikes
    ci = [code_underlier,'C',num2str(strikes(i))];
    dataci = cDataFileIO.loadDataFromTxtFile([ci,'_daily.txt']);
    premiumci = dataci(dataci(:,1)==cobdate,5);
    %
    pi = [code_underlier,'P',num2str(strikes(i))];
    datapi = cDataFileIO.loadDataFromTxtFile([pi,'_daily.txt']);
    premiumpi = datapi(datapi(:,1)==cobdate,5);
    
    fwdi = premiumci-premiumpi+strikes(i);
    if ~isnan(fwdi)
        if strikes(i) < spot
            vols(i) = bjsimpv(fwdi,strikes(i),0.035,cobdate,optexpiry,premiumpi,[],0.035,[],'put');
        else
            vols(i) = bjsimpv(fwdi,strikes(i),0.035,cobdate,optexpiry,premiumci,[],0.035,[],'call');
        end
    else
        if isnan(premiumci)
            vols(i) = bjsimpv(spot,strikes(i),0.035,cobdate,optexpiry,premiumpi,[],0.035,[],'put');
        else
            vols(i) = bjsimpv(spot,strikes(i),0.035,cobdate,optexpiry,premiumci,[],0.035,[],'call');
        end
    end
end
%% compute atm vol
i_dn = find(strikes==k_dn);i_up = i_dn+1;
vol_atm = vols(i_up)-(vols(i_up)-vols(i_dn))/(m(i_up)-m(i_dn))*m(i_up);
plot(m,vols/vol_atm,'*');
%%
% vega weighted
vega = zeros(nstrikes,1);
for i = 1:nstrikes
    vega(i) = blsvega(spot,strikes(i),0.035,calendar_tau,vols(i),0.035);
end
weights = vega/sum(vega);
quadraticfit = fit(m,vols/vol_atm,'poly2');
coeffs = coeffvalues(quadraticfit);
[estimates, model] = opt_piv_ny4fit(m, vols/vol_atm,weights,[coeffs(2),coeffs(1),1]);
%%
skew = estimates(1);
smile = estimates(2);
power = estimates(3);
mplot = m(1)-0.02:0.02:m(end)+0.02;
volfitted = (1 + skew .* mplot + smile.*mplot.^2).^power;
plot(m,vols,'*');hold on;
plot(mplot,volfitted.*vol_atm,'r');hold off;

