function [] = refresh(obj,varargin)
%cAShareWindIndustries
    daily_index = obj.conn_.ds_.wsq(obj.codes_index_,'rt_date,rt_open,rt_high,rt_low,rt_latest');
       
    n_index = size(obj.codes_index_,1);
    
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

end