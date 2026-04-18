function [ret] = mt5_dataupdate(code,fileappendix)
% to update data on ONEDRIVE with latest data downloaded from MT5 sever
    
    foldername = [getenv('ONEDRIVE'),'\Documents\fx_mt5\'];

    if contains(fileappendix,'.csv')
        csvfilename = [upper(code),fileappendix];
    else
        csvfilename = [upper(code),fileappendix,'.csv'];
    end

    if contains(upper(fileappendix),'H1')
        matfilename = [upper(code),'_MT5_H1.mat'];
    elseif contains(upper(fileappendix),'H4')
        matfilename = [upper(code),'_MT5_H4.mat'];
    elseif contains(upper(fileappendix),'M5')
        matfilename = [upper(code),'_MT5_M5.mat'];
    elseif contains(upper(fileappendix),'M15')
        matfilename = [upper(code),'_MT5_M15.mat'];
    elseif contains(upper(fileappendix),'M30')
        matfilename = [upper(code),'_MT5_M30.mat'];    
    else
        ret = 0;
        return;
    end

    try
        csvtable = readtable([foldername,csvfilename],'ReadVariableNames',false);
        nnew = size(csvtable,1);
        matdatanew = zeros(nnew,6);
        matdatanew(:,1) = datenum(csvtable.Var1,'yyyy.mm.dd');
        matdatanew(:,2) = csvtable.Var3;
        matdatanew(:,3) = csvtable.Var4;
        matdatanew(:,4) = csvtable.Var5;
        matdatanew(:,5) = csvtable.Var6;
        matdatanew(:,6) = csvtable.Var7;
        for i = 1:nnew
            intradaydtstr = char(csvtable.Var2(i));
            hhstr = intradaydtstr(1:2);
            mmstr = intradaydtstr(4:5);
            matdatanew(i,1) = matdatanew(i,1) +(str2double(hhstr)*60+str2double(mmstr))/1440;
        end

    catch
        matdatanew = [];
    end

    try
        data = load([foldername,matfilename]);
        if contains(upper(fileappendix),'H1')
            matdataexisting = data.datamath1;
        elseif contains(upper(fileappendix),'H4')
            matdataexisting = data.datamath4;
        elseif contains(upper(fileappendix),'M5')
            matdataexisting = data.datamatm5;
        elseif contains(upper(fileappendix),'M15')
            matdataexisting = data.datamatm15;
        elseif contains(upper(fileappendix),'M30')
            matdataexisting = data.datamatm30;
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

    if contains(upper(fileappendix),'H1')
        datamath1 = data;
        save([foldername,matfilename],"datamath1");
        ret = 1;
    elseif contains(upper(fileappendix),'H4')
        datamath4 = data;
        save([foldername,matfilename],"datamath4");
        ret = 1;
    elseif contains(upper(fileappendix),'M5')
        datamatm5 = data;
        save([foldername,matfilename],"datamatm5");
        ret = 1;
    elseif contains(upper(fileappendix),'M15')
        datamatm15 = data;
        save([foldername,matfilename],"datamatm15");
        ret = 1;    
    elseif contains(upper(fileappendix),'M30')
        datamatm30 = data;
        save([foldername,matfilename],"datamatm30");
        ret = 1;
    end

end