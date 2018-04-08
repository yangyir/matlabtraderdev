function data = intradaybar(obj,instrument,startdate,enddate,interval,field)
    %some sanity check first
    if ~(strcmpi(field,'trade') || ...
            strcmpi(field,'bid') || ...
            strcmpi(field,'ask'))
        error(['cLocal:intradaybar:field ',field,' not supported'])
    end

    if ~ischar(startdate), error('cLocal:intradaybar:startdate must be char'); end
    if ~ischar(enddate), error('cLocal:intradaybar:enddate must be char'); end

    if ~isnumeric(interval), error('cLocal:intradaybar:interval must be scalar'); end
    if isempty(interval), interval = 1; end

    if isa(instrument,'cFutures')
        code_ctp = instrument.code_ctp;
        bds = gendates('fromdate',datenum(startdate,'yyyy-mm-dd'),...
            'todate',datenum(enddate,'yyyy-mm-dd'));
        n = size(bds,1);

        if n == 1
            fn_ = [code_ctp,'_',datestr(bds,'yyyymmdd'),'_1m.txt'];
            fullfn_ = [obj.ds_,'intradaybar\',code_ctp,'\',fn_];
            data_raw_ = cDataFileIO.loadDataFromTxtFile(fullfn_);
        else
            fn_ = [code_ctp,'_',datestr(bds(1),'yyyymmdd'),'_1m.txt'];
            fullfn_ = [obj.ds_,'intradaybar\',code_ctp,'\',fn_];
            data_raw_ = cDataFileIO.loadDataFromTxtFile(fullfn_);
            for i = 2:n
                fn_ = [code_ctp,'_',datestr(bds(i),'yyyymmdd'),'_1m.txt'];
                fullfn_ = [obj.ds_,'intradaybar\',code_ctp,'\',fn_];
                data_new_ = cDataFileIO.loadDataFromTxtFile(fullfn_);
                tmp = data_raw_;
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
    else
        classname = class(instrument);
        error(['cLocal:intradaybar:not implemented for class ',...
            classname])
    end


end
%end of intradaybar

