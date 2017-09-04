%script to download time series of previous metals traded in Shanghai
%futures exchange
clc;
lastbd = businessdate(today,-1);
fprintf(['the last business date is ',datestr(lastbd),'.\n']);

assetlist = {'gold';'silver';'deformed bar';'iron ore';'copper'};

for idx = 1:size(assetlist,1)
    asset = cAsset('AssetName',assetlist{idx});
    cl = asset.ContractList;
%     freqs = {'1d';'1m';'tick'};
    
    fprintf(['now update time series of "',assetlist{idx},'"........\n']);
    
    
    
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
            timeseries_update(futures);
%             for j = 1:size(freqs,1)
%                 try
%                     tsobj = futures.getTimeSeriesObj('Connection','Bloomberg','Frequency',freqs{j});
%                     lastentry = datenum(tsobj.getLastDateEntry);
%                     if lastentry < lastbd
%                         fprintf(['updating ',windcode,' ',freqs{j},' data......\n']);
%                         tsobjs = futures.updateTimeSeries('Connection','Bloomberg','Frequency',freqs{j});
%                         fprintf(['before the last date entry of ',windcode,' ',freqs{j},' data is: ',...
%                             datestr(lastentry),' and it is ',tsobjs{1}.getLastDateEntry,...
%                             ' after updating\n']);
%                     else
%                         fprintf([windcode,' ',freqs{j},' data is up to date!\n']);
%                     end
%                 catch
%                     futures.initTimeSeries('Connection','Bloomberg','Frequency',freqs{j},'DataSource','internet');
%                     tsobj = futures.getTimeSeriesObj('Connection','Bloomberg','Frequency',freqs{j});
%                     fprintf(['after initiating the last date entry of ',windcode,' ',freqs{j},' data is: ',...
%                         tsobj.getLastDateEntry,'\n']);
%                 end
%                 
%             end
        end
        
    end
end
clear cl i j idx tsobj lastentry tenor windcode
fprintf('done!\n');