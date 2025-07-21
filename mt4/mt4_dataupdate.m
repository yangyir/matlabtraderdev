function [ret] = mt4_dataupdate(code)
%MT4_DATAUPDATE Summary of this function goes here
% to update data on ONEDRIVE with latest data downloaded from MT4 server
    if strcmpi(code,'UK100') || strcmpi(code,'AUS200') || strcmpi(code,'J225') || ...
        strcmpi(code,'GER30m') || strcmpi(code,'SPX500m') || strcmpi(code,'HK50')
        ismt4eqcfd = true;
    else
        ismt4eqcfd = false;
    end

    if ~(isfx(code) || ismt4eqcfd)
        ret = 0;
        fprintf('mt4_dataupdate:invalid fx code input\n');
        return
    end
    
    folder = [getenv('onedrive'),'\Documents\fx_mt4\'];
    if isfx(code)
        code = upper(code);
        nperiod = 6;
        fns = cell(nperiod,1);
        fns{1} = [code,'.lmx5.csv'];       %5min
        fns{2} = [code,'.lmx15.csv'];      %15min
        fns{3} = [code,'.lmx30.csv'];      %30min
        fns{4} = [code,'.lmx60.csv'];      %1H
        fns{5} = [code,'.lmx240.csv'];     %4H
        fns{6} = [code,'.lmx1440.csv'];    %DAILY
    
        fns_out = cell(nperiod,1);
        fns_out{1} = [code,'_MT4_M5.mat'];
        fns_out{2} = [code,'_MT4_M15.mat'];
        fns_out{3} = [code,'_MT4_M30.mat'];
        fns_out{4} = [code,'_MT4_H1.mat'];
        fns_out{5} = [code,'_MT4_H4.mat'];
        fns_out{6} = [code,'_MT4_D1.mat'];
    elseif ismt4eqcfd
        code = upper(code);
        nperiod = 3;
        fns = cell(nperiod,1);
        fns{1} = [code,'.lmx60.csv'];      %1H
        fns{2} = [code,'.lmx240.csv'];     %4H
        fns{3} = [code,'.lmx1440.csv'];    %DAILY
    
        fns_out = cell(nperiod,1);
        fns_out{1} = [code,'_MT4_H1.mat'];
        fns_out{2} = [code,'_MT4_H4.mat'];
        fns_out{3} = [code,'_MT4_D1.mat'];
    end
    
    for i = 1:nperiod
        try
            data = load([folder,fns_out{i}]);
            datamat_existing = data.data;
        catch
            datamat_existing = [];
        end
        
        
        table_i = readtable([folder,fns{i}],'readvariablenames',0);
        n_i = size(table_i,1);
        datamat_new = zeros(n_i,6);
        datamat_new(:,1) = datenum(table_i.Var1,'yyyy.mm.dd');
        datamat_new(:,2) = table_i.Var3;
        datamat_new(:,3) = table_i.Var4;
        datamat_new(:,4) = table_i.Var5;
        datamat_new(:,5) = table_i.Var6;
        datamat_new(:,6) = table_i.Var7;
        if i ~= 6
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
            fprintf('%20s:last bar time:%s\n',fns_out{i},datestr(lastdt,'yyyy-mm-dd HH:MM'));
            idxadded = datamat_new(:,1) >= lastdt;
            datamat_added = datamat_new(idxadded,:);
            if isempty(datamat_added)
                data = datamat_existing;
            else
                %the last bar might not be completed upon downloading
                if i ~= nperiod
                    data = [datamat_existing(1:end-1,:);datamat_added];
                else
                    data = [datamat_existing(1:end-1,1:5);datamat_added(:,1:5)];
                end
            end
        else
            data = datamat_new;
        end
        save([folder,fns_out{i}],'data');
    end
        
    
    ret = 1;
    
    
end

