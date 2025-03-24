function [ret] = mt4_dataupdate(code)
%MT4_DATAUPDATE Summary of this function goes here
% to update data on ONEDRIVE with latest data downloaded from MT4 server
    
    if ~isfx(code)
        ret = 0;
        fprintf('mt4_dataupdate:invalid fx code input\n');
        return
    end
    
    folder = [getenv('onedrive'),'\Documents\fx_mt4\'];
    code = upper(code);
    fns = cell(5,1);
    fns{1} = [code,'.lmx5.csv'];       %5min
    fns{2} = [code,'.lmx15.csv'];      %15min
    fns{3} = [code,'.lmx30.csv'];      %30min
    fns{4} = [code,'.lmx60.csv'];      %1H
    fns{5} = [code,'.lmx1440.csv'];    %DAILY
    
    fns_out = cell(5,1);
    fns_out{1} = [code,'_MT4_5m.mat'];
    fns_out{2} = [code,'_MT4_15m.mat'];
    fns_out{3} = [code,'_MT4_30m.mat'];
    fns_out{4} = [code,'_MT4_60m.mat'];
    fns_out{5} = [code,'_MT4_daily.mat'];
    
    for i = 1:5
        try
            data = load([folder,fns_out{i}]);
            datamat_existing = data.datamat;
        catch
            datamat_existing = [];
        end
        
        
        table_i = readtable([folder,fns{i}]);
        n_i = size(table_i,1);
        datamat_new = zeros(n_i,6);
        datamat_new(:,1) = datenum(table_i.Var1,'yyyy.mm.dd');
        datamat_new(:,2) = table_i.Var3;
        datamat_new(:,3) = table_i.Var4;
        datamat_new(:,4) = table_i.Var5;
        datamat_new(:,5) = table_i.Var6;
        datamat_new(:,6) = table_i.Var7;
        if i ~= 5
            for j = 1:n_i
                intradaydtstr = table_i.Var2{j};
                datamat_new(j,1) = datamat_new(j,1) +(str2double(intradaydtstr(1:2))*60+str2double(intradaydtstr(end-1:end)))/1440;
            end
        else
            %daily and do nothing
        end
        %
        if ~isempty(datamat_existing)
            lastdt = datamat_existing(end,1);
            idxadded = datamat_new(:,1) > lastdt;
            datamat_added = datamat_new(idxadded,:);
            if isempty(datamat_added)
                data = datamat_existing;
            else
                data = [datamat_existing;datamat_added];
            end
        else
            data = datamat_new;
        end
        save([folder,fns_out{i}],'data');
    end
        
    
    ret = 1;
    
    
end

