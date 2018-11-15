%%
activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
filename = ['activefutures_',datestr(getlastbusinessdate,'yyyymmdd'),'.txt'];
activefutures = cDataFileIO.loadDataFromTxtFile([activefuturesdir,filename]);
%%
mde = cMDEFut;
param = struct('name','WilliamR','values',{{'numofperiods',144}});
for i = 1:size(activefutures,1)
    mde.registerinstrument(activefutures{i});
    mde.setcandlefreq(15,activefutures{i});
    mde.settechnicalindicator(activefutures{i},param);
end
%
for i = 1:size(activefutures,1)
    mde.initcandles(activefutures{i});
end
%%
mde.login('connection','ctp','countername','ccb_ly_fut');
%%
mde.start;
%%
fprintf('\nWilliam R:\n')
if size(activefutures,1) > 1
    fprintf('%11s%11s%11s%11s%11s\n','code','wlpr','highest','lowest','last');
end
for i = 1:size(activefutures,1)
    ti = mde.calc_technical_indicators(activefutures{i});
    wr = ti{1};
    fprintf('%11s%11.1f%11s%11s%11s\n',activefutures{i},wr(1),num2str(wr(2)),num2str(wr(3)),num2str(wr(4)));
end
