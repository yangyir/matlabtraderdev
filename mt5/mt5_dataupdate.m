function [ret] = mt5_dataupdate(code,freq)
% to update data on ONEDRIVE with latest data downloaded from MT5 sever
    
    foldername2 = [getenv('ONEDRIVE'),'\Documents\fx_mt5\'];

    foldername = [getenv('appdata'),'\MetaQuotes\Terminal\Common\Files\'];

    csvfilename = [upper(code),'.lmx_PERIOD_',freq,'_History'];
    if ~contains(freq,'.csv')
        csvfilename = [csvfilename,'.csv'];
    end

    if strcmpi(freq,'H1')
        matfilename = [upper(code),'_MT5_H1.mat'];
    elseif strcmpi(freq,'H4')
        matfilename = [upper(code),'_MT5_H4.mat'];
    elseif strcmpi(freq,'M5')
        matfilename = [upper(code),'_MT5_M5.mat'];
    elseif strcmpi(freq,'M15')
        matfilename = [upper(code),'_MT5_M15.mat'];
    elseif strcmpi(freq,'M30')
        matfilename = [upper(code),'_MT5_M30.mat'];
    elseif strcmpi(freq,'D1')
        matfilename = [upper(code),'_MT5_D1.mat'];
    else
        ret = 0;
        return;
    end

    try
        csvtable = readtable([foldername,csvfilename],'ReadVariableNames',false);
        nnew = size(csvtable,1);
        matdatanew = zeros(nnew,6);
        
        if contains(upper(freq),'D1')
            matdatanew(:,1) = datenum(csvtable.Var1,'yyyy.mm.dd');
            matdatanew(:,2) = csvtable.Var2;
            matdatanew(:,3) = csvtable.Var3;
            matdatanew(:,4) = csvtable.Var4;
            matdatanew(:,5) = csvtable.Var5;
            matdatanew(:,6) = csvtable.Var6;
        else
            matdatanew(:,1) = datenum(csvtable.Var1,'yyyy.mm.dd HH:MM:SS');
            matdatanew(:,2) = csvtable.Var2;
            matdatanew(:,3) = csvtable.Var3;
            matdatanew(:,4) = csvtable.Var4;
            matdatanew(:,5) = csvtable.Var5;
            matdatanew(:,6) = csvtable.Var6;
%             for i = 1:nnew
%                 intradaydtstr = char(csvtable.Var2(i));
%                 hhstr = intradaydtstr(1:2);
%                 mmstr = intradaydtstr(4:5);
%                 matdatanew(i,1) = matdatanew(i,1) +(str2double(hhstr)*60+str2double(mmstr))/1440;
%             end
        end
    catch
        matdatanew = [];
    end

    try
        data = load([foldername2,matfilename]);
        if strcmpi(freq,'H1')
            matdataexisting = data.datamath1;
        elseif strcmpi(freq,'H4')
            matdataexisting = data.datamath4;
        elseif strcmpi(freq,'M5')
            matdataexisting = data.datamatm5;
        elseif strcmpi(freq,'M15')
            matdataexisting = data.datamatm15;
        elseif strcmpi(freq,'M30')
            matdataexisting = data.datamatm30;
        elseif strcmpi(freq,'D1')
            matdataexisting = data.datamatd1;
        end
    catch
        matdataexisting = [];
    end
    %
    if ~isempty(matdataexisting)
        lastdt = matdataexisting(end,1);
        fprintf('%20s:last bar time:%s\n',matfilename,datestr(lastdt,'yyyy-mm-dd HH:MM'));
        idxadded = matdatanew(:,1) >= lastdt;

        datamat_added = matdatanew(idxadded,:);
        if isempty(datamat_added)
            data = matdataexisting;
        else
            %the last bar might not be completed upon downloading
            data = [matdataexisting(1:end-1,:);datamat_added];
        end
    else
        data = matdatanew;
    end

    if strcmpi(freq,'H1')
        datamath1 = data;
        save([foldername2,matfilename],"datamath1");
        ret = 1;
    elseif strcmpi(freq,'H4')
        datamath4 = data;
        save([foldername2,matfilename],"datamath4");
        ret = 1;
    elseif strcmpi(freq,'M5')
        datamatm5 = data;
        save([foldername2,matfilename],"datamatm5");
        ret = 1;
    elseif strcmpi(freq,'M15')
        datamatm15 = data;
        save([foldername2,matfilename],"datamatm15");
        ret = 1;    
    elseif strcmpi(freq,'M30')
        datamatm30 = data;
        save([foldername2,matfilename],"datamatm30");
        ret = 1;
    elseif strcmpi(freq,'D1')
        datamatd1 = data;
        save([foldername2,matfilename],"datamatd1");
        ret = 1;
    end

end