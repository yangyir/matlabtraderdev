dir_ = [getenv('DATAPATH'),'realtimetrading\'];
counter = 'ccbly';
book = 'ccblybookwlpr-flash';
cob = '20190108';
fn = [dir_,counter,'\',book,'\',book,'_trades_',cob,'.txt'];
alltrades = cTradeOpenArray;
alltrades.fromtxt(fn);
livetrades = alltrades.filterby('status','live');
%
clc;
for i = 1:livetrades.latest_
    fprintf('%8s%4d%8s%4d%8s\n',...
        livetrades.node_(i).code_,...
        livetrades.node_(i).opendirection_,...
        num2str(livetrades.node_(i).openprice_),...
        livetrades.node_(i).openvolume_,...
        num2str(livetrades.node_(i).runningpnl_));
end
%%
activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
filename = ['activefutures_',datestr(getlastbusinessdate,'yyyymmdd'),'.txt'];
activefutures = cDataFileIO.loadDataFromTxtFile([activefuturesdir,filename]);
%%
mde = cMDEFut;
mde.qms_.setdatasource('ctp');
for i = 1:size(activefutures,1)
    dailyfile = [activefutures{i},'_daily.txt'];
    try
        cDataFileIO.loadDataFromTxtFile(dailyfile);
    catch
        continue;
    end
    
    mde.registerinstrument(activefutures{i});
end
%%
mde.login('connection','ctp','countername','ccb_ly_fut');
%%
mde.start


