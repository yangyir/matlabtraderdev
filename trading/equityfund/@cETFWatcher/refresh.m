function [] = refresh(obj,varargin)
    daily_index = obj.conn_.ds_.wsq(obj.codes_index_,'rt_date,rt_open,rt_high,rt_low,rt_latest');
    daily_sector = obj.conn_.ds_.wsq(obj.codes_sector_,'rt_date,rt_open,rt_high,rt_low,rt_latest');
    daily_stock = obj.conn_.ds_.wsq(obj.codes_stock_,'rt_date,rt_open,rt_high,rt_low,rt_latest');
    
    n_index = size(obj.codes_index_,1);
    n_sector = size(obj.codes_sector_,1);
    n_stock = size(obj.codes_stock_,1);
    
    nfractal = 2;
    doplot = 0;
    for i = 1:n_index
        data = daily_index(i,:);
        data(1) = datenum(num2str(data(1)),'yyyymmdd');
        if data(1) > obj.dailybarmat_index_{i}(end,1)
            data_new = [obj.dailybarmat_index_{i}(:,1:5);data];    
        elseif data(1) == obj.dailybarmat_index_{i}(end,1)
            data_new = [obj.dailybarmat_index_{i}(1:end-1,1:5);data];
        end
        [obj.dailybarmat_index_{i},obj.dailybarstruct_index_{i}] = tools_technicalplot1(data_new,nfractal,doplot);
        obj.dailybarmat_index_{i}(:,1) = x2mdate(obj.dailybarmat_index_{i}(:,1));
    end
    
    for i = 1:n_sector
        data = daily_sector(i,:);
        data(1) = datenum(num2str(data(1)),'yyyymmdd');
        if data(1) > obj.dailybarmat_sector_{i}(end,1)
            data_new = [obj.dailybarmat_sector_{i}(:,1:5);data];
        elseif data(1) == obj.dailybarmat_sector_{i}(end,1)
            data_new = [obj.dailybarmat_sector_{i}(1:end-1,1:5);data];
        end
        [obj.dailybarmat_sector_{i},obj.dailybarstruct_sector_{i}] = tools_technicalplot1(data_new,nfractal,doplot);
        obj.dailybarmat_sector_{i}(:,1) = x2mdate(obj.dailybarmat_sector_{i}(:,1));
        
    end
    
    for i = 1:n_stock
        data = daily_stock(i,:);
        data(1) = datenum(num2str(data(1)),'yyyymmdd');
        if data(1) > obj.dailybarmat_stock_{i}(end,1)
            data_new = [obj.dailybarmat_stock_{i}(:,1:5);data];
        else
            data_new = [obj.dailybarmat_stock_{i}(1:end-1,1:5);data];
        end
        [obj.dailybarmat_stock_{i},obj.dailybarstruct_stock_{i}] = tools_technicalplot1(data_new,nfractal,doplot);
        obj.dailybarmat_stock_{i}(:,1) = x2mdate(obj.dailybarmat_stock_{i}(:,1));
        
    end
    %
    %
    intraday_index = cell(n_index,1);
    intraday_sector = cell(n_sector,1);
    intraday_stock = cell(n_stock,1);
    
    dtstr = datestr(today,'yyyy-mm-dd');
    
    for i = 1:n_index
        fprintf('cETFWatcher:refresh:update intraday bar of %s...\n',obj.names_index_{i});
        intraday_index{i} = obj.conn_.intradaybar(obj.codes_index_{i}(1:end-3),dtstr,dtstr,30,'trade');
    end
    
    for i = 1:n_sector
        fprintf('cETFWatcher:refresh:update intraday bar of %s...\n',obj.names_sector_{i});
        intraday_sector{i} = obj.conn_.intradaybar(obj.codes_sector_{i}(1:end-3),dtstr,dtstr,30,'trade');
    end
    
    for i = 1:n_stock
        fprintf('cETFWatcher:refresh:update intraday bar of %s...\n',obj.names_stock_{i});
        intraday_stock{i} = obj.conn_.intradaybar(obj.codes_stock_{i}(1:end-3),dtstr,dtstr,30,'trade');
    end
    
    
    nfractalintraday = 4;
    for i = 1:n_index
        if obj.intradaybarmat_index_{i}(end,1) > today
            idx = find(obj.intradaybarmat_index_{i}(:,1) < today,1,'last');
            data_new = [obj.intradaybarmat_index_{i}(1:idx,1:5);intraday_index{i}];
        else
            data_new = [obj.intradaybarmat_index_{i}(:,1:5);intraday_index{i}];
        end
        [obj.intradaybarmat_index_{i},obj.intradaybarstruct_index_{i}] = tools_technicalplot1(data_new,nfractalintraday,doplot);
        obj.intradaybarmat_index_{i}(:,1) = x2mdate(obj.intradaybarmat_index_{i}(:,1));
    end
    
    for i = 1:n_sector
        if obj.intradaybarmat_sector_{i}(end,1) > today
            idx = find(obj.intradaybarmat_sector_{i}(:,1) < today,1,'last');
            data_new = [obj.intradaybarmat_sector_{i}(1:idx,1:5);intraday_sector{i}];
        else
            data_new = [obj.intradaybarmat_sector_{i}(:,1:5);intraday_sector{i}];
        end
        [obj.intradaybarmat_sector_{i},obj.intradaybarstruct_sector_{i}] = tools_technicalplot1(data_new,nfractalintraday,doplot);
        obj.intradaybarmat_sector_{i}(:,1) = x2mdate(obj.intradaybarmat_sector_{i}(:,1));
    end
    
    for i = 1:n_stock
        if obj.intradaybarmat_stock_{i}(end,1) > today
            idx = find(obj.intradaybarmat_stock_{i}(:,1) < today,1,'last');
            data_new = [obj.intradaybarmat_stock_{i}(1:idx,1:5);intraday_stock{i}];
        else
            data_new = [obj.intradaybarmat_stock_{i}(:,1:5);intraday_stock{i}];
        end
        [obj.intradaybarmat_stock_{i},obj.intradaybarstruct_stock_{i}] = tools_technicalplot1(data_new,nfractalintraday,doplot);
        obj.intradaybarmat_stock_{i}(:,1) = x2mdate(obj.intradaybarmat_stock_{i}(:,1));
    end
    
    

end