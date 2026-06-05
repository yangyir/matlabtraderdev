function [ret,data] = mt5fut_dataupdate(code)
%MT4FUT_DATAUPDATE Summary of this function goes here
% to update FUTURES data on ONEDRIVE with latest data downloaded from MT5 server
% AD:AUDUSD futures
% EC:EURUSD futures
% BP:GBPUSD futures
% CD:CADUSD futures
% SF:CHFUSD futures
% JY:JPYUSD futures
% NE:NZDUSD futures
% GC:XAUUSD futures
% SI:XAGUSD futures
% NQ:Nasdaq futures
% ES:SPX500 futures
    if strcmpi(code,'AD') || strcmpi(code,'EC') || strcmpi(code,'BP') || ...
        strcmpi(code,'CD') || strcmpi(code,'SF') || strcmpi(code,'JY') || strcmpi(code,'NE') || ...
        strcmpi(code,'GC') || strcmpi(code,'SI') || ...
        strcmpi(code,'NQ') || strcmpi(code,'ES')
        ismt5fute = true;
    else
        ismt5fute = false;
    end

    if ~(ismt5fute)
        ret = 0;
        fprintf('mt5fut_dataupdate:invalid code input\n');
        return
    end
    
    folder = [getenv('onedrive'),'\mt5\futuresfx\'];
    
    code = upper(code);
    nperiod = 4;
    %{'M15';'M30';'H1';'H4'}
    fns = cell(nperiod,1);
    fns{1} = [code,'__MAIN_M15.csv'];    %15min
    fns{2} = [code,'__MAIN_M30.csv'];    %30min
    fns{3} = [code,'__MAIN_H1.csv'];     %1 hour
    fns{4} = [code,'__MAIN_H4.csv'];     %4 hour
        
    fns_out = cell(nperiod,1);
    fns_out{1} = [code,'_MT5_M15.mat'];
    fns_out{2} = [code,'_MT5_M30.mat'];
    fns_out{3} = [code,'_MT5_H1.mat'];
    fns_out{4} = [code,'_MT5_H4.mat'];
    
    for i = 1:nperiod
        try
            data = load([folder,fns_out{i}]);
            datamat_existing = data.data;
        catch
            datamat_existing = [];
        end
            
        table_i = readtable([folder,fns{i}],'readvariablenames',0,'delimiter','tab');
        n_i = size(table_i,1);
        table_i = table_i(2:n_i,:);
        datamat_new = zeros(n_i-1,6);
        datamat_new(:,1) = datenum(table_i.Var1,'yyyy.mm.dd');
        datamat_new(:,2) = str2double(table_i.Var3);
        datamat_new(:,3) = str2double(table_i.Var4);
        datamat_new(:,4) = str2double(table_i.Var5);
        datamat_new(:,5) = str2double(table_i.Var6);
        datamat_new(:,6) = str2double(table_i.Var7);
        
        for j = 1:size(table_i,1)
            intradaydtstr = table_i.Var2{j};
            datamat_new(j,1) = datamat_new(j,1) +(str2double(intradaydtstr(1:2))*60+str2double(intradaydtstr(end-1:end)))/1440;
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

