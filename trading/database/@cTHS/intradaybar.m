function data = intradaybar(obj,instrument,startdate,enddate,interval,field)
%cTHS function
    %some sanity check first
    data = [];
    if ~obj.isconnect, return;end
    
    if ~(strcmpi(field,'trade') || ...
            strcmpi(field,'bid') || ...
            strcmpi(field,'ask'))
        error(['cTHS:intradaybar:field ',field,' not supported'])
    end

    if ~ischar(startdate), error('cTHS:intradaybar:startdate must be char'); end
    if ~ischar(enddate), error('cTHS:intradaybar:enddate must be char'); end

    if ~isnumeric(interval), error('cTHS:intradaybar:interval must be scalar'); end
    if isempty(interval), interval = 1; end

    if isa(instrument,'cFutures') || isa(instrument,'cStock')
        code_wind = instrument.code_wind;
        
        if ~isempty(strfind(code_wind,'.INE'))
            code_wind = [code_wind(1:end-4),'.SHF'];
        end
        
        category = getfutcategory(instrument);
        
        bds = gendates('fromdate',datenum(startdate,'yyyy-mm-dd'),...
            'todate',datenum(enddate,'yyyy-mm-dd'));
        n = size(bds,1);
        if n == 0
            d = THS_HF(code_wind,'open;high;low;close','Fill:Original',startdate,enddate,'format:table');
            data_raw_ = [datenum(d.time,'yyyy-mm-dd HH:MM'),d.open,d.high,d.low,d.close];
        elseif n == 1
            startdate_ = datestr(bds,'yyyy-mm-dd');
            if category > 4
                enddate_ = [datestr(bds+1,'yyyy-mm-dd'),' ',instrument.break_interval{end,end}];
            else
                enddate_ = [datestr(bds,'yyyy-mm-dd'),' ',instrument.break_interval{end,end}];
            end
            d = THS_HF(code_wind,'open;high;low;close','Fill:Original',startdate_,enddate_,'format:table');
            data_raw_ = [datenum(d.time,'yyyy-mm-dd HH:MM'),d.open,d.high,d.low,d.close];
        else
            startdate_ = datestr(bds(1),'yyyy-mm-dd');
            if category > 4
                enddate_ = [datestr(bds(1)+1,'yyyy-mm-dd'),' ',instrument.break_interval{end,end}];
            else
                enddate_ = [datestr(bds(1),'yyyy-mm-dd'),' ',instrument.break_interval{end,end}];
            end
            d = THS_HF(code_wind,'open;high;low;close','Fill:Original',startdate_,enddate_,'format:table');
            data_raw_ = [datenum(d.time,'yyyy-mm-dd HH:MM'),d.open,d.high,d.low,d.close];
            for i = 2:n
                startdate_ = datestr(bds(i),'yyyy-mm-dd');
                if datenum(startdate_,'yyyy-mm-dd HH:MM:SS') > today, continue;end
                if category > 4
                    enddate_ = [datestr(bds(i)+1,'yyyy-mm-dd'),' ',instrument.break_interval{end,end}];
                else
                    enddate_ = [datestr(bds(i),'yyyy-mm-dd'),' ',instrument.break_interval{end,end}];
                end
                d = THS_HF(code_wind,'open;high;low;close','Fill:Original',startdate_,enddate_,'format:table');
                tmp = data_raw_;
                data_new_ = [datenum(d.time,'yyyy-mm-dd HH:MM'),d.open,d.high,d.low,d.close];
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
        elseif strcmpi(instrument(1),'0') || strcmpi(instrument(1),'1') || strcmpi(instrument(1),'3')
            code_wind = [instrument,'.SZ'];
        elseif strcmpi(instrument(1),'4') || strcmpi(instrument(1),'8') 
            code_wind = [instrument,'.BJ'];
        end
        bds = gendates('fromdate',datenum(startdate,'yyyy-mm-dd'),...
            'todate',datenum(enddate,'yyyy-mm-dd'));
        n = size(bds,1);
        if n == 0
            d = THS_HF(code_wind,'open;high;low;close','Fill:Original',startdate,enddate,'format:table');
            data_raw_ = [datenum(d.time,'yyyy-mm-dd HH:MM'),d.open,d.high,d.low,d.close];
        elseif n == 1
            startdate_ = datestr(bds,'yyyy-mm-dd');            
            enddate_ = [datestr(bds,'yyyy-mm-dd'),' 15:00:00'];
            d = THS_HF(code_wind,'open;high;low;close','Fill:Original',startdate_,enddate_,'format:table');
            data_raw_ = [datenum(d.time,'yyyy-mm-dd HH:MM'),d.open,d.high,d.low,d.close];
        else
            startdate_ = datestr(bds(1),'yyyy-mm-dd');
            enddate_ = [datestr(bds(1),'yyyy-mm-dd'),' 15:00:00'];
            d = THS_HF(code_wind,'open;high;low;close','Fill:Original',startdate_,enddate_,'format:table');
            data_raw_ = [datenum(d.time,'yyyy-mm-dd HH:MM'),d.open,d.high,d.low,d.close];
            for i = 2:n
                startdate_ = datestr(bds(i),'yyyy-mm-dd');
                if bds(i) > today, continue;end
                enddate_ = [datestr(bds(i),'yyyy-mm-dd'),' 15:00:00'];
                d = THS_HF(code_wind,'open;high;low;close','Fill:Original',startdate_,enddate_,'format:table');
                tmp = data_raw_;
                data_new_ = [datenum(d.time,'yyyy-mm-dd HH:MM'),d.open,d.high,d.low,d.close];
                data_raw_ = [tmp;data_new_];
            end
        end
        if ~isnumeric(data_raw_)
            data = [];
            fprintf('cTHS:intradaybar:no data returned...\n');
        else
            idx2use = ~(isnan(data_raw_(:,1)) | isnan(data_raw_(:,2)) | isnan(data_raw_(:,3)) | isnan(data_raw_(:,4)) | isnan(data_raw_(:,5)));
            data = timeseries_compress(data_raw_(idx2use,1:5),...
                'fromdate',startdate,...
                'todate',enddate,...
                'tradinghours','09:30-11:30;13:00-15:00',...
                'tradingbreak','',...
                'frequency',[num2str(interval),'m']);
        end
    else
        classname = class(instrument);
        error(['cTHS:intradaybar:not implemented for class ',...
            classname])
    end

end