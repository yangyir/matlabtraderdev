 function data = intradaybar(obj,instrument,startdate,enddate,interval,field)
    %some sanity check first
    if ~(strcmpi(field,'trade') || ...
            strcmpi(field,'bid') || ...
            strcmpi(field,'ask'))
        error(['cBloomberg:intradaybar:field ',field,' not supported'])
    end

    if ~ischar(startdate), error('cBloomberg:intradaybar:startdate must be char'); end
    if ~ischar(enddate), error('cBloomberg:intradaybar:enddate must be char'); end

    if ~isnumeric(interval), error('cBloomberg:intradaybar:interval must be scalar'); end
    if isempty(interval), interval = 1; end

    if isa(instrument,'cFutures')
        code_bbg = instrument.code_bbg;

        bds = gendates('fromdate',datenum(startdate,'yyyy-mm-dd'),...
            'todate',datenum(enddate,'yyyy-mm-dd'));
        n = size(bds,1);
        if n == 0
            data_raw_ = obj.ds_.timeseries(code_bbg,{startdate,enddate},...
                1,field);
        elseif n == 1
            enddate_ = datestr(businessdate(startdate,1),'yyyy-mm-dd');
            data_raw_ = obj.ds_.timeseries(code_bbg,{startdate,enddate_},...
                1,field);
        else
            startdate_ = datestr(bds(1),'yyyy-mm-dd');
            enddate_ = datestr(bds(2),'yyyy-mm-dd');
            data_raw_ = obj.ds_.timeseries(code_bbg,{startdate_,enddate_},...
                1,field);
            for i = 2:n
                startdate_ = datestr(bds(i),'yyyy-mm-dd');
                if i < n
                    enddate_ = datestr(bds(i+1),'yyyy-mm-dd');
                else
                    enddate_ = datestr(businessdate(startdate_,1),'yyyy-mm-dd');
                end
                data_new_ = obj.ds_.timeseries(code_bbg,{startdate_,enddate_},...
                    1,field);
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
        error(['cBloomberg:intradaybar:not implemented for class ',...
            classname])
    end
end
%end of intradaybar

