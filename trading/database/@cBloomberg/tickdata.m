function data = tickdata(obj,instrument,startdate,enddate)
%some sanity check first
    if ~ischar(startdate), error('cBloomberg:tickdata:startdate must be char'); end
    if ~ischar(enddate), error('cBloomberg:tickdata:enddate must be char'); end
    
    if isa(instrument,'cFutures')
        code_bbg = instrument.code_bbg;
        category = getfutcategory(instrument);

        bds = gendates('fromdate',datenum(startdate,'yyyy-mm-dd'),...
            'todate',datenum(enddate,'yyyy-mm-dd'));
        n = size(bds,1);
        if n == 0
            fprintf('cBloomberg:tickdata:no business dates found between input startdate and enddate\n');
            data = [];
            return
        elseif n == 1
            startdate_ = [datestr(bds),' ',instrument.break_interval{1,1}];
            if category > 4
                enddate_ = [datestr(bds+1),' ',instrument.break_interval{end,end}];
            else
                enddate_ = [datestr(bds),' ',instrument.break_interval{end,end}];
            end
            ticks = obj.ds_.timeseries(code_bbg,{startdate_,enddate_},...
                [],'trade');
            data = cell2mat(ticks(:,2:end));
        else
            data_ = cell(n,1);
            for i = 1:n
                startdate_ = [datestr(bds(i)),' ',instrument.break_interval{1,1}];
                if category > 4
                    enddate_ = [datestr(bds(i)+1),' ',instrument.break_interval{end,end}];
                else
                    enddate_ = [datestr(bds(i)),' ',instrument.break_interval{end,end}];
                end
                ticks = obj.ds_.timeseries(code_bbg,{startdate_,enddate_},...
                    [],'trade');
                data_{i,1} = cell2mat(ticks(:,2:end));    
            end
            data = cell2mat(data_);
        end
    else
        classname = class(instrument);
        error(['cBloomberg:tickdata:not implemented for class ',...
            classname])
    end


end
%end of tickdata
