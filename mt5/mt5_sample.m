symbolsmt5 = {'AUDUSD';'EURUSD';'GBPUSD';'USDCAD';'USDCHF';'USDJPY';'XAUUSD';'XAGUSD';...
    'EUR50';'HK50';'J225';'SPX500m';'UK100';};

foldername = 'C:\Users\Charlotte\Documents\MT5\';

nsymbols = size(symbolsmt5,1);

for i = 1:nsymbols

    filenameh1 = [symbolsmt5{i},'.lmx_H1_20180509_20260220.csv'];

    filenameh4 = [symbolsmt5{i},'.lmx_H4_20180509_20260220.csv'];

    fileouth1 = [symbolsmt5{i},'_MT5_H1.mat'];

    fileouth4 = [symbolsmt5{i},'_MT5_H4.mat'];

    tableh1 = readtable([foldername,filenameh1],'ReadVariableNames',false);
    tableh4 = readtable([foldername,filenameh4],'ReadVariableNames',false);
    
    %
    nh1 = size(tableh1,1);
    datamath1 = zeros(nh1,6);
    datamath1(:,1) = datenum(tableh1.Var1,'yyyy.mm.dd');
    datamath1(:,2) = tableh1.Var3;
    datamath1(:,3) = tableh1.Var4;
    datamath1(:,4) = tableh1.Var5;
    datamath1(:,5) = tableh1.Var6;
    datamath1(:,6) = tableh1.Var7;
    for j = 1:nh1
        intradaydtstr = char(tableh1.Var2(j));
        datamath1(i,1) = datamath1(i,1) +(str2double(intradaydtstr(1:2))*60+str2double(intradaydtstr(end-1:end)))/1440;
    end
    %
    nh4 = size(tableh4,1);
    datamath4 = zeros(nh4,6);
    datamath4(:,1) = datenum(tableh4.Var1,'yyyy.mm.dd');
    datamath4(:,2) = tableh4.Var3;
    datamath4(:,3) = tableh4.Var4;
    datamath4(:,4) = tableh4.Var5;
    datamath4(:,5) = tableh4.Var6;
    datamath4(:,6) = tableh4.Var7;
    for j = 1:nh4
        intradaydtstr = char(tableh4.Var2(j));
        datamath4(j,1) = datamath4(j,1) +(str2double(intradaydtstr(1:2))*60+str2double(intradaydtstr(end-1:end)))/1440;
    end
    
    save([foldername,fileouth1],"datamath1");
    save([foldername,fileouth4],"datamath4");

    fprintf('done with %s\n',symbolsmt5{i});

end

%%
% compare the MT5 with the existing MT4
foldermt4 = [getenv('onedrive'),'\Documents\fx_mt4\'];

for i = 1:nsymbols

    filemt4h1 = [symbolsmt5{i},'_MT4_H1.mat'];
    filemt4h4 = [symbolsmt5{i},'_MT4_H4.mat'];
    
    datamt4h1 = load([foldermt4,filemt4h1]);datamt4h1 = datamt4h1.data;
    datamt4h4 = load([foldermt4,filemt4h4]);datamt4h4 = datamt4h4.data;

    filemt5h1 = [symbolsmt5{i},'_MT5_H1.mat'];
    filemt5h4 = [symbolsmt5{i},'_MT5_H4.mat'];

    datamt5h1 = load([foldername,filemt5h1]);datamt5h1 = datamt5h1.datamath1;
    datamt5h4 = load([foldername,filemt5h4]);datamt5h4 = datamt5h4.datamath4;


    [~,idxmt4h1,idxmt5h1] = intersect(datamt4h1(:,1),datamt5h1(:,1));
    sum(datamt4h1(idxmt4h1,5) - datamt5h1(idxmt5h1,5))


end






