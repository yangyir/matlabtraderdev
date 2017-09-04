% modelinfo = struct('ModelName','CCBSMC',...
%     'CalcIntrinsic',0,...
%     'ExtraResults',0);

% model_path = [getenv('home'),'objs\model\'];

% model_filename = 'model_ccbsmc';
% save([model_path,model_filename],'modelinfo');

%%
vol_path = [getenv('home'),'objs\vol\'];
asset = 'deformed bar';
otmK = 2800;
vols = [0.4,0.3];
rb1601 = cContract('AssetName',asset,'Tenor','1601');
rb1605 = cContract('AssetName',asset,'Tenor','1605');
rb1610 = cContract('AssetName',asset,'Tenor','1610');
rb1701 = cContract('AssetName',asset,'Tenor','1701');
rb1705 = cContract('AssetName',asset,'Tenor','1705');

futures = {rb1601;rb1605;rb1610;rb1701;rb1705};

assetnames = {'RB1601';'RB1605';'RB1610';'RB1701';'RB1705'};

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
            strikes = [data(1,2),otmK];
            volinfo = struct('AssetName',assetnames{j},...
                'ReferenceSpot',data(1,2),'Strikes',strikes,'Expiries',data(1,1)+365,'Vols',vols);
            save([vol_path,filename],'volinfo')
        end
    end
end






