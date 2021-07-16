function data = intradaybar(obj,instrument,startdate,enddate,interval,field)
    %some sanity check first
    if ~(strcmpi(field,'trade') || ...
            strcmpi(field,'bid') || ...
            strcmpi(field,'ask'))
        error(['cWind:intradaybar:field ',field,' not supported'])
    end

    if ~ischar(startdate), error('cWind:intradaybar:startdate must be char'); end
    if ~ischar(enddate), error('cWind:intradaybar:enddate must be char'); end

    if ~isnumeric(interval), error('cWind:intradaybar:interval must be scalar'); end
    if isempty(interval), interval = 1; end

    if isa(instrument,'cFutures')
        code_wind = instrument.code_wind;

        category = getfutcategory(instrument);
        
        bds = gendates('fromdate',datenum(startdate,'yyyy-mm-dd'),...
            'todate',datenum(enddate,'yyyy-mm-dd'));
        n = size(bds,1);
        if n == 0
            [wdata,~,~,wtime] = obj.ds_.wsi(code_wind,'open,high,low,close',startdate,enddate,'BarSize=1');
            data_raw_ = [wtime,wdata];
        elseif n == 1
%             startdate_ = [datestr(bds,'yyyymmdd'),' ',instrument.break_interval{1,1}];
            startdate_ = datestr(bds,'yyyymmdd');
            if category > 4
                enddate_ = [datestr(bds+1,'yyyymmdd'),' ',instrument.break_interval{end,end}];
            else
                enddate_ = [datestr(bds,'yyyymmdd'),' ',instrument.break_interval{end,end}];
            end
            [wdata,~,~,wtime] = obj.ds_.wsi(code_wind,'open,high,low,close',startdate_,enddate_,'BarSize=1');
            data_raw_ = [wtime,wdata];
        else
%             startdate_ = [datestr(bds(1),'yyyymmdd'),' ',instrument.break_interval{1,1}];
            startdate_ = datestr(bds(1),'yyyymmdd');
            if category > 4
                enddate_ = [datestr(bds(1)+1,'yyyymmdd'),' ',instrument.break_interval{end,end}];
            else
                enddate_ = [datestr(bds(1),'yyyymmdd'),' ',instrument.break_interval{end,end}];
            end
            [wdata,~,~,wtime] = obj.ds_.wsi(code_wind,'open,high,low,close',startdate_,enddate_,'BarSize=1');
            data_raw_ = [wtime,wdata];
            for i = 2:n
%                 startdate_ = [datestr(bds(i),'yyyymmdd'),' ',instrument.break_interval{1,1}];
                startdate_ = datestr(bds(i),'yyyymmdd');
                if datenum(startdate_,'yyyymmdd HH:MM:SS') > today, continue;end
                if category > 4
                    enddate_ = [datestr(bds(i)+1,'yyyymmdd'),' ',instrument.break_interval{end,end}];
                else
                    enddate_ = [datestr(bds(i),'yyyymmdd'),' ',instrument.break_interval{end,end}];
                end
                [wdata,~,~,wtime] = obj.ds_.wsi(code_wind,'open,high,low,close',startdate_,enddate_,'BarSize=1');
                tmp = data_raw_;
                data_new_ = [wtime,wdata];
                data_raw_ = [tmp;data_new_];
            end
        end
        %the columns in d contain the following:
        %numeric representation of data and time
        %open price
        %high price
        %low price
        %closing price
        %volume of ticks
        %number of ticks
        %total tick value in the bar
        data = timeseries_compress(data_raw_(:,1:5),...
            'fromdate',startdate,...
            'todate',enddate,...
            'tradinghours',instrument.trading_hours,...
            'tradingbreak',instrument.trading_break,...
            'frequency',[num2str(interval),'m']);
    elseif ischar(instrument)
        if strcmpi(instrument(1),'5') || strcmpi(instrument(1),'6')
            code_wind = [instrument,'.SH'];
        else
            code_wind = [instrument,'.SZ'];
        end
        bds = gendates('fromdate',datenum(startdate,'yyyy-mm-dd'),...
            'todate',datenum(enddate,'yyyy-mm-dd'));
        n = size(bds,1);
        if n == 0
            [wdata,~,~,wtime] = obj.ds_.wsi(code_wind,'open,high,low,close',startdate,enddate,'BarSize=1');
            data_raw_ = [wtime,wdata];
        elseif n == 1
            startdate_ = datestr(bds,'yyyymmdd');            
            enddate_ = [datestr(bds,'yyyymmdd'),' 15:00:00'];
            [wdata,~,~,wtime] = obj.ds_.wsi(code_wind,'open,high,low,close',startdate_,enddate_,'BarSize=1');
            data_raw_ = [wtime,wdata];
        else
%             startdate_ = [datestr(bds(1),'yyyymmdd'),' ',instrument.break_interval{1,1}];
            startdate_ = datestr(bds(1),'yyyymmdd');
            enddate_ = [datestr(bds(1),'yyyymmdd'),' 15:00:00'];
            [wdata,~,~,wtime] = obj.ds_.wsi(code_wind,'open,high,low,close',startdate_,enddate_,'BarSize=1');
            data_raw_ = [wtime,wdata];
            for i = 2:n
%                 startdate_ = [datestr(bds(i),'yyyymmdd'),' ',instrument.break_interval{1,1}];
                startdate_ = datestr(bds(i),'yyyymmdd');
                if bds(i) > today, continue;end
                enddate_ = [datestr(bds(i),'yyyymmdd'),' 15:00:00'];
                [wdata,~,~,wtime] = obj.ds_.wsi(code_wind,'open,high,low,close',startdate_,enddate_,'BarSize=1');
                tmp = data_raw_;
                data_new_ = [wtime,wdata];
                data_raw_ = [tmp;data_new_];
            end
        end
        data = timeseries_compress(data_raw_(:,1:5),...
            'fromdate',startdate,...
            'todate',enddate,...
            'tradinghours','09:30-11:30;13:00-15:00',...
            'tradingbreak','',...
            'frequency',[num2str(interval),'m']);
    else
        classname = class(instrument);
        error(['cWind:intradaybar:not implemented for class ',...
            classname])
    end

end