function results = bbgupdate(assetname)
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addRequired('AssetName',@ischar);
p.parse(assetname);
assetname = p.Results.AssetName;

asset = cAsset('AssetName',assetname);
cl = asset.ContractList;
freqs = {'1d';'1m';'tick'};
    
fprintf(['now update time series of "',assetname,'"........\n']);

lastbd = businessdate(today,-1);

for i = 1:size(cl,1)
    expiry = cl{i,3};
    if expiry >= lastbd
        %only update the time series file if the contract not expired yet
        windcode = cl{i,2};
        tenor = windcode(1:end-4);
        for k = 1:length(tenor)
            if ~isnan(str2double(tenor(k)))
                break
            end
        end
        tenor = tenor(k:end);
        futures = cContract('AssetName',asset.AssetName,'Tenor',tenor);
        for j = 1:size(freqs,1)
            try
                tsobj = futures.getTimeSeriesObj('Connection','Bloomberg',...
                    'Frequency',freqs{j});
                
                lastentry = datenum(tsobj.getLastDateEntry);
                
                if lastentry < lastbd
                    fprintf(['updating ',windcode,' ',freqs{j},' data......\n']);
                    tsobjs = futures.updateTimeSeries(...
                        'Connection','Bloomberg',...
                        'Frequency',freqs{j});
                    
                    fprintf(['before the last date entry of ',windcode,' ',freqs{j},' data is: ',...
                        datestr(lastentry),' and it is ',tsobjs{1}.getLastDateEntry,...
                        ' after updating\n']);
                else
                    fprintf([windcode,' ',freqs{j},' data is up to date!\n']);
                end
            catch
                %in case it is the first time to init the time series of
                %the futures
                futures.initTimeSeries('Connection','Bloomberg',...
                    'Frequency',freqs{j},...
                    'DataSource','internet');
                
                tsobj = futures.getTimeSeriesObj('Connection','Bloomberg',...
                    'Frequency',freqs{j});
                
                fprintf(['after initiating the last date entry of ',windcode,' ',freqs{j},' data is: ',...
                    tsobj.getLastDateEntry,'\n']);
            end
            
        end
    end
    
end

results = 1;

end