function [] = showfigures(obj,varargin)
%cETFWatcher
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Code','',@ischar);
    p.parse(varargin{:});
    code2plot = p.Results.Code;
    
    n_index = size(obj.codes_index_,1);
    n_sector = size(obj.codes_sector_,1);
    n_stock = size(obj.codes_stock_,1);
    
    foundflag = false;
    for i = 1:n_index
        if strcmpi(code2plot,obj.codes_index_{i}(1:end-3)) || strcmpi(code2plot,obj.codes_index_{i})
            foundflag = true;
            dailybarmat_ = obj.dailybarmat_index_{i};
            idx1 = find(dailybarmat_(:,1)>=datenum('2021-07-01'),1,'first');
            tools_technicalplot2(dailybarmat_(idx1:end,:),2,[obj.codes_index_{i},'-',obj.names_index_{i},'-日线'],true,0.002);    
            idx2 = find(obj.intradaybarmat_index_{i}(:,1)>=today-14,1,'first');
            tools_technicalplot2(obj.intradaybarmat_index_{i}(idx2:end,:),3,[obj.codes_index_{i},'-',obj.names_index_{i},'-30分钟线'],true,0.002);
            break
        end
    end
    %
    if ~foundflag
        for i = 1:n_sector
            if strcmpi(code2plot,obj.codes_sector_{i}(1:end-3)) || strcmpi(code2plot,obj.codes_sector_{i})
                foundflag = true;
                dailybarmat_ = obj.dailybarmat_sector_{i};
                idx1 = find(dailybarmat_(:,1)>=datenum('2021-07-01'),1,'first');
                tools_technicalplot2(dailybarmat_(idx1:end,:),2,[obj.codes_sector_{i},'-',obj.names_sector_{i},'-日线'],true,0.002);    
                idx2 = find(obj.intradaybarmat_sector_{i}(:,1)>=today-14,1,'first');
                tools_technicalplot2(obj.intradaybarmat_sector_{i}(idx2:end,:),3,[obj.codes_sector_{i},'-',obj.names_sector_{i},'-30分钟线'],true,0.002);
                break
            end
        end
    end
    %
    if ~foundflag
        for i = 1:n_stock
            if strcmpi(code2plot,obj.codes_stock_{i}(1:end-3)) || strcmpi(code2plot,obj.codes_stock_{i})
                foundflag = true;
                dailybarmat_ = obj.dailybarmat_stock_{i};
                idx1 = find(dailybarmat_(:,1)>=datenum('2021-07-01'),1,'first');
                tools_technicalplot2(dailybarmat_(idx1:end,:),2,[obj.codes_stock_{i},'-',obj.names_stock_{i},'-日线'],true,0.02);    
                idx2 = find(obj.intradaybarmat_stock_{i}(:,1)>=today-14,1,'first');
                tools_technicalplot2(obj.intradaybarmat_stock_{i}(idx2:end,:),3,[obj.codes_stock_{i},'-',obj.names_stock_{i},'-30分钟线'],true,0.02);
                break
            end
        end
    end
    %
    if ~foundflag
        warning('cETFWatcher:showfigure:code not registed with etf watcher');
    end
    
end