[rollinfo,pxoidata] = bkfunc_genfutrollinfo('sugar');
%
[cfut,cret,cindex] = bkfunc_buildcontinuousfutures(rollinfo,pxoidata);
%
[res] = bkfunc_hvcalib(cret(:,end),'forecastperiod',21,'printresults',true,'scalefactor',sqrt(252));
%%
bucket = 100;
activefut = rollinfo{end,5};
hp = cDataFileIO.loadDataFromTxtFile([activefut,'_daily.txt']);
cobdate = getlastbusinessdate;
predate = businessdate(cobdate,-1);
lastprice = hp(hp(:,1) == cobdate,5);
lastprice2 = hp(hp(:,1) == predate,5);
k1 = floor(lastprice/bucket)*bucket;
k2 = ceil(lastprice/bucket)*bucket;

%%
clc;
fprintf('%8s:%s\n','code',activefut);
fprintf('%8s:%s\n','cobdate',datestr(cobdate,'yyyymmdd'));
fprintf('%8s:%.2f\n','histv',res.HistoricalVol*100);
fprintf('%8s:%.2f\n','ewmav',res.EWMAVol*100);
fprintf('%8s:%.2f\n','projectv',res.ForecastedVol*100);
fprintf('%8s:%4s(%3s/%3.1f%%)\n','last',num2str(lastprice),num2str(lastprice-lastprice2),100*(lastprice/lastprice2-1));
pnlbreakck1 = pnlriskbreakdown1([activefut,'C',num2str(k1)],cobdate);
pnlbreakck2 = pnlriskbreakdown1([activefut,'C',num2str(k2)],cobdate);
pnlbreakpk1 = pnlriskbreakdown1([activefut,'P',num2str(k1)],cobdate);
pnlbreakpk2 = pnlriskbreakdown1([activefut,'P',num2str(k2)],cobdate);

cv = interp1([k1,k2],[pnlbreakck1.iv2,pnlbreakck2.iv2],lastprice);
pv = interp1([k1,k2],[pnlbreakpk1.iv2,pnlbreakpk2.iv2],lastprice);
cv2 = interp1([k1,k2],[pnlbreakck1.iv1,pnlbreakck2.iv1],lastprice2);
pv2 = interp1([k1,k2],[pnlbreakpk1.iv1,pnlbreakpk2.iv1],lastprice2);

fprintf('%8s:%s;ivc:%4.2f(%2.2f);ivp:%4.2f(%2.2f)\n','lowerK',num2str(k1),...
    pnlbreakck1.iv2*100,(pnlbreakck1.iv2-pnlbreakck1.iv1)*100,...
    pnlbreakpk1.iv2*100,(pnlbreakpk1.iv2-pnlbreakpk1.iv1)*100);
%
fprintf('%8s:%s;ivc:%4.2f(%2.2f);ivp:%4.2f(%2.2f)\n','upperK',num2str(k2),...
    pnlbreakck2.iv2*100,(pnlbreakck2.iv2-pnlbreakck2.iv1)*100,...
    pnlbreakpk2.iv2*100,(pnlbreakpk2.iv2-pnlbreakpk2.iv1)*100);
%
fprintf('%8s:%s;ivc:%4.2f(%2.2f);ivp:%4.2f(%2.2f)\n','atmK',num2str(lastprice),...
    cv*100,(cv-cv2)*100,...
    pv*100,(pv-pv2)*100);