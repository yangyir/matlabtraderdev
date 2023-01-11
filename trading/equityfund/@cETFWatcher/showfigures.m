function [dailystruct,intradaystruct] = showfigures(obj,varargin)
%cETFWatcher
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Code','',@ischar);
    p.addParameter('Print',false,@islogical);
    p.parse(varargin{:});
    code2plot = p.Results.Code;
    printflag = p.Results.Print;
    
    n_index = size(obj.codes_index_,1);
    n_sector = size(obj.codes_sector_,1);
    n_stock = size(obj.codes_stock_,1);
    
    foundflag = false;
    for i = 1:n_index
        if strcmpi(code2plot,obj.codes_index_{i}(1:end-3)) || strcmpi(code2plot,obj.codes_index_{i})
            foundflag = true;
            dailybarmat_ = obj.dailybarmat_index_{i};
            idx1 = find(dailybarmat_(:,1)>=datenum(dateadd(dailybarmat_(end,1),'-6m')),1,'first');
            tools_technicalplot2(dailybarmat_(idx1:end,:),2,[obj.codes_index_{i},'-',obj.names_index_{i},'-日线'],true,0.002);    
            idx2 = find(obj.intradaybarmat_index_{i}(:,1)>=today-14,1,'first');
            tools_technicalplot2(obj.intradaybarmat_index_{i}(idx2:end,:),3,[obj.codes_index_{i},'-',obj.names_index_{i},'-30分钟线'],true,0.002);
            if printflag
                fractal_printmarket(obj.codes_index_{i}(1:6),obj.dailybarstruct_index_{i},obj.intradaybarstruct_index_{i});
            end
            dailystruct = obj.dailybarstruct_index_{i};
            intradaystruct = obj.intradaybarstruct_index_{i};
            break
        end
    end
    %
    if ~foundflag
        for i = 1:n_sector
            if strcmpi(code2plot,obj.codes_sector_{i}(1:end-3)) || strcmpi(code2plot,obj.codes_sector_{i})
                foundflag = true;
                dailybarmat_ = obj.dailybarmat_sector_{i};
                idx1 = find(dailybarmat_(:,1)>=datenum(dateadd(dailybarmat_(end,1),'-6m')),1,'first');
                tools_technicalplot2(dailybarmat_(idx1:end,:),2,[obj.codes_sector_{i},'-',obj.names_sector_{i},'-日线'],true,0.002);    
                idx2 = find(obj.intradaybarmat_sector_{i}(:,1)>=today-14,1,'first');
                tools_technicalplot2(obj.intradaybarmat_sector_{i}(idx2:end,:),3,[obj.codes_sector_{i},'-',obj.names_sector_{i},'-30分钟线'],true,0.002);
                if printflag
                    fractal_printmarket(obj.codes_sector_{i}(1:6),obj.dailybarstruct_sector_{i},obj.intradaybarstruct_sector_{i});
                end
                dailystruct = obj.dailybarstruct_sector_{i};
                intradaystruct = obj.intradaybarstruct_sector_{i};
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
                idx1 = find(dailybarmat_(:,1)>=datenum(dateadd(dailybarmat_(end,1),'-6m')),1,'first');
                tools_technicalplot2(dailybarmat_(idx1:end,:),2,[obj.codes_stock_{i},'-',obj.names_stock_{i},'-日线'],true,0.02);
                %yangyir:20230109
                %update is called here rather than refresh methods
                dtstr = datestr(today,'yyyy-mm-dd');
                intraday_stock = obj.conn_.intradaybar(obj.codes_stock_{i}(1:end-3),dtstr,dtstr,30,'trade');
                if obj.intradaybarmat_stock_{i}(end,1) > today
                    idx = find(obj.intradaybarmat_stock_{i}(:,1) < today,1,'last');
                    data_new = [obj.intradaybarmat_stock_{i}(1:idx,1:5);intraday_stock];
                else
                    data_new = [obj.intradaybarmat_stock_{i}(:,1:5);intraday_stock];
                end
                [obj.intradaybarmat_stock_{i},obj.intradaybarstruct_stock_{i}] = tools_technicalplot1(data_new,4,false);
                obj.intradaybarmat_stock_{i}(:,1) = x2mdate(obj.intradaybarmat_stock_{i}(:,1));
                
                idx2 = find(obj.intradaybarmat_stock_{i}(:,1)>=today-14,1,'first');
                tools_technicalplot2(obj.intradaybarmat_stock_{i}(idx2:end,:),3,[obj.codes_stock_{i},'-',obj.names_stock_{i},'-30分钟线'],true,0.02);
                if printflag
                    fractal_printmarket(obj.codes_stock_{i}(1:6),obj.dailybarstruct_stock_{i},obj.intradaybarstruct_stock_{i});
                end
                dailystruct = obj.dailybarstruct_stock_{i};
                intradaystruct = obj.intradaybarstruct_stock_{i};
                break
            end
        end
    end
    %
    if ~foundflag
        warning('cETFWatcher:showfigure:code not registed with etf watcher');
        dailystruct = {};
        intradaystruct = {};
    end
    
end