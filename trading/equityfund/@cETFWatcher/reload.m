function [] = reload(obj,varargin)
%cETFWatcher
    n_index = size(obj.codes_index_,1);
    n_sector = size(obj.codes_sector_,1);
    n_stock = size(obj.codes_stock_,1);
    
    obj.dailybarmat_index_ = cell(n_index,1);
    obj.dailybarmat_sector_ = cell(n_sector,1);
    obj.dailybarmat_stock_ = cell(n_stock,1);
    obj.dailybarstruct_index_ = cell(n_index,1);
    obj.dailybarstruct_sector_ = cell(n_sector,1);
    obj.dailybarstruct_stock_ = cell(n_stock,1);
    
    nfractal = 2;
    doplot = 0;
    for i = 1:n_index
        fn_i = [obj.codes_index_{i}(1:end-3),'_daily.txt'];
        dailybar_i = cDataFileIO.loadDataFromTxtFile(fn_i);
        [obj.dailybarmat_index_{i},obj.dailybarstruct_index_{i}] = tools_technicalplot1(dailybar_i,nfractal,doplot);
        obj.dailybarmat_index_{i}(:,1) = x2mdate(obj.dailybarmat_index_{i}(:,1));
    end
    fprintf('cETFWatcher:init:daily bar of index:technical indicators calculated......\n');
    for i = 1:n_sector
        fn_i = [obj.codes_sector_{i}(1:end-3),'_daily.txt'];
        dailybar_i = cDataFileIO.loadDataFromTxtFile(fn_i);
        [obj.dailybarmat_sector_{i},obj.dailybarstruct_sector_{i}] = tools_technicalplot1(dailybar_i,nfractal,doplot);
        obj.dailybarmat_sector_{i}(:,1) = x2mdate(obj.dailybarmat_sector_{i}(:,1));
    end
    fprintf('cETFWatcher:init:daily bar of sector:technical indicators calculated......\n');
    for i = 1:n_stock
        fn_i = [obj.codes_stock_{i}(1:end-3),'_daily.txt'];
        dailybar_i = cDataFileIO.loadDataFromTxtFile(fn_i);
        [obj.dailybarmat_stock_{i},obj.dailybarstruct_stock_{i}] = tools_technicalplot1(dailybar_i,nfractal,doplot);
        obj.dailybarmat_stock_{i}(:,1) = x2mdate(obj.dailybarmat_stock_{i}(:,1));
    end
    fprintf('cETFWatcher:init:daily bar of sector:technical indicators calculated......\n');
    %
    %
    obj.intradaybarmat_index_ = cell(n_index,1);
    obj.intradaybarmat_sector_ = cell(n_sector,1);
    obj.intradaybarmat_stock_ = cell(n_stock,1);
    obj.intradaybarstruct_index_ = cell(n_index,1);
    obj.intradaybarstruct_sector_ = cell(n_sector,1);
    obj.intradaybarstruct_stock_ = cell(n_stock,1);
    
    nfractalintraday = 4;
    for i = 1:n_index
        fn_i = [getenv('ONEDRIVE'),'\matlabdev\equity\',obj.codes_index_{i}(1:end-3),'\',obj.codes_index_{i}(1:end-3),'.mat'];
        data = load(fn_i);
        [obj.intradaybarmat_index_{i},obj.intradaybarstruct_index_{i}] = tools_technicalplot1(data.data,nfractalintraday,doplot);
        obj.intradaybarmat_index_{i}(:,1) = x2mdate(obj.intradaybarmat_index_{i}(:,1));
    end
    fprintf('cETFWatcher:init:intraday bar of index:technical indicators calculated......\n');
    for i = 1:n_sector
        fn_i = [getenv('ONEDRIVE'),'\matlabdev\equity\',obj.codes_sector_{i}(1:end-3),'\',obj.codes_sector_{i}(1:end-3),'.mat'];
        data = load(fn_i);
        [obj.intradaybarmat_sector_{i},obj.intradaybarstruct_sector_{i}] = tools_technicalplot1(data.data,nfractalintraday,doplot);
        obj.intradaybarmat_sector_{i}(:,1) = x2mdate(obj.intradaybarmat_sector_{i}(:,1));
    end
    fprintf('cETFWatcher:init:intraday bar of sector:technical indicators calculated......\n');
    for i = 1:n_stock
        fn_i = [getenv('ONEDRIVE'),'\matlabdev\equity\',obj.codes_stock_{i}(1:end-3),'\',obj.codes_stock_{i}(1:end-3),'.mat'];
        data = load(fn_i);
        [obj.intradaybarmat_stock_{i},obj.intradaybarstruct_stock_{i}] = tools_technicalplot1(data.data,nfractalintraday,doplot);
        obj.intradaybarmat_stock_{i}(:,1) = x2mdate(obj.intradaybarmat_stock_{i}(:,1));
    end
    fprintf('cETFWatcher:init:intraday bar of stock:technical indicators calculated......\n');
    %
end