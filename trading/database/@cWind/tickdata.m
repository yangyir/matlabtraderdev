function data = tickdata(obj,instrument,startdate,enddate)
%some sanity check first
    if ~ischar(startdate), error('cWind:tickdata:startdate must be char'); end
    if ~ischar(enddate), error('cWind:tickdata:enddate must be char'); end
    
    if isa(instrument,'cFutures')
        code_wind = instrument.code_wind;
        category = getfutcategory(instrument);

        bds = gendates('fromdate',datenum(startdate,'yyyy-mm-dd'),...
            'todate',datenum(enddate,'yyyy-mm-dd'));
        n = size(bds,1);
        if n == 0
            fprintf('cWind:tickdata:no business dates found between input startdate and enddate\n');
            data = [];
            return
        elseif n == 1
            startdate_ = [datestr(bds,'yyyymmdd'),' ',instrument.break_interval{1,1}];
            if category > 4
                enddate_ = [datestr(bds+1,'yyyymmdd'),' ',instrument.break_interval{end,end}];
            else
                enddate_ = [datestr(bds,'yyyymmdd'),' ',instrument.break_interval{end,end}];
            end
            [wdata,~,~,wtime] = obj.ds_.wst(code_wind,'last,volume',startdate_,enddate_);
            %wind returns accumulated trading volume
            if isnumeric(wdata)
                d = [wtime,wdata(:,1),[wdata(1,2);wdata(2:end,2)-wdata(1:end-1,2)]];
                idx = d(:,end) ~= 0;
                data = d(idx,:);
            else
                data = [];
            end
        else
            data_ = cell(n,1);
            for i = 1:n
                startdate_ = [datestr(bds(i),'yyyymmdd'),' ',instrument.break_interval{1,1}];
                if category > 4
                    enddate_ = [datestr(bds(i)+1,'yyyymmdd'),' ',instrument.break_interval{end,end}];
                else
                    enddate_ = [datestr(bds(i),'yyyymmdd'),' ',instrument.break_interval{end,end}];
                end
                [wdata,~,~,wtime] = obj.ds_.wst(code_wind,'last,volume',startdate_,enddate_);
                d =  [wtime,wdata(:,1),[wdata(1,2);wdata(2:end,2)-wdata(1:end-1,2)]];
                idx = d(:,end) ~= 0;
                data_{i,1} = d(idx,:);
            end
            data = cell2mat(data_);
        end
    else
        classname = class(instrument);
        error(['cWind:tickdata:not implemented for class ',...
            classname])
    end


end
%end of tickdata
