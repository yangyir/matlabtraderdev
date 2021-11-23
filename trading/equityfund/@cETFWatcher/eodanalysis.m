function [] = eodanalysis(obj,varargin)
%cETFWatcher
    n_index = size(obj.codes_index_,1);
    n_sector = size(obj.codes_sector_,1);
    n_stock = size(obj.codes_stock_,1);
    
    %1st column is the latest EWMA vol
    %2nd column is the previous EWMA vol 
    
    fprintf('%12s %12s %12s\n','ewmav(t)','ewmav(t-1)','name');
    
    vol_index = zeros(n_index,2);    
    for i = 1:n_index
        idx = find(obj.dailybarstruct_index_{i}.px(:,1) >= getlastbusinessdate-3*365,1,'first');
        px = obj.dailybarstruct_index_{i}.px(idx:end,1:5);
        if size(px,1) >= 243
            hv = historicalvol(px,243,'ewma','Parameters',0.94);
        else
            hv = historicalvol(px,size(px,1),'ewma','Parameters',0.94);
        end
        vol_index(i,1) = hv(end,2);
        vol_index(i,2) = hv(end-1,2);
        fprintf('%11.2f%% %11.2f%% %12s\n',vol_index(i,1)*100,vol_index(i,2)*100,obj.names_index_{i});
    end
    fprintf('\n');
    vol_sector = zeros(n_sector,2);
    for i = 1:n_sector
        idx = find(obj.dailybarstruct_sector_{i}.px(:,1) >= getlastbusinessdate-3*365,1,'first');
        px = obj.dailybarstruct_sector_{i}.px(idx:end,1:5);
        if size(px,1) >= 243
            hv = historicalvol(px,243,'ewma','Parameters',0.94);
        else
            hv = historicalvol(px,size(px,1),'ewma','Parameters',0.94);
        end
        vol_sector(i,1) = hv(end,2);
        vol_sector(i,2) = hv(end-1,2);
        fprintf('%11.2f%% %11.2f%% %12s\n',vol_sector(i,1)*100,vol_sector(i,2)*100,obj.names_sector_{i});
    end
       
%     vol_stock = zeros(n_stock,2);

end