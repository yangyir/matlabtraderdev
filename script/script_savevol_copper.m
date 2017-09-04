
%%
vol_path = [getenv('home'),'objs\vol\'];
asset = 'copper';
vols = [0.25,0.25];
strikes = [37000,39000];
cu1701 = cContract('AssetName',asset,'Tenor','1701');
cu1702 = cContract('AssetName',asset,'Tenor','1702');

futures = {cu1701;cu1702};

assetnames = {'CU1701';'CU1702'};

bdates = gendates('FromDate','2016-11-04','ToDate',businessdate(today,-1));
for i = 1:size(futures,1)
    try
        data = futures{i}.getTimeSeries('connection','bloomberg','fields',{'close','volume'},...
            'fromdate',bdates(1),'todate',bdates(end),'frequency','1d');
    catch
        futures{i}.initTimeSeries('connection','bloomberg','frequency','1d','datasource','internet');
    end
end

for i = 1:size(bdates,1)
    for j = 1:size(futures,1)
        data = futures{j}.getTimeSeries('connection','bloomberg','fields',{'close','volume'},...
            'fromdate',bdates(i),'todate',bdates(i),'frequency','1d');
        filename = ['marketvol_',lower(assetnames{j}),'_',datestr(data(1,1),'yyyymmdd')];
        
        
        volinfo = struct('AssetName',assetnames{j},...
            'ReferenceSpot',data(1,2),'Strikes',strikes,'Expiries',data(1,1)+365,'Vols',vols);
        save([vol_path,filename],'volinfo');
    end
end






