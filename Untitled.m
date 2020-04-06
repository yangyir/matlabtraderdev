p = cDataFileIO.loadDataFromTxtFile('510050_daily.txt');
%%
op = tools_technicalplot1(p,2,0,'volatilityperiod',0,'tolerance',0.002);

bs = op(:,12);
%%
[wad,trh,trl] = williamsad(p);
%%
idxbs9 = find(bs==9);
%%
idxstart = idxbs9(7)-9;
idxend = min(idxbs9(7)+25,size(p,1));
tools_technicalplot2(op(idxstart:idxend,:));
figure(2);
x = idxstart:idxend;
x = x-idxstart+1;
plotyy(x,trl(idxstart:idxend),x,wad(idxstart:idxend));hold off;grid on;


%%
plotyy([1:1:length(wad)],p(:,5),[1:1:length(wad)],wad)
grid on;
%%
figure(2);
plot(trh,'r');hold on;
plot(trl,'g');hold off;