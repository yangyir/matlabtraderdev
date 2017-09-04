
%%
vol_path = [getenv('home'),'objs\vol\'];
asset = 'gold';
vols = 0.16;
au1606 = cContract('AssetName',asset,'Tenor','1606');
au1612 = cContract('AssetName',asset,'Tenor','1612');
au1706 = cContract('AssetName',asset,'Tenor','1706');

futures = {au1606;au1612;au1706};

assetnames = {'AU1606';'AU1612';'AU1706'};

bdates = gendates('FromDate','2016-01-04','ToDate',businessdate(today,-1));
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
        if ~isfile([vol_path,filename])
            strikes = data(1,2);
            volinfo = struct('AssetName',assetnames{j},...
                'ReferenceSpot',data(1,2),'Strikes',strikes,'Expiries',data(1,1)+365,'Vols',vols);
            save([vol_path,filename],'volinfo')
        end
    end
end






