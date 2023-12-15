function data = tickdata(obj,instrument,startdate,enddate)
%cTHS function
%some sanity check first
    data = [];
    if ~obj.isconnect,return;end
    if ~ischar(startdate), error('cTHS:tickdata:startdate must be char'); end
    if ~ischar(enddate), error('cTHS:tickdata:enddate must be char'); end
    
    if isa(instrument,'cInstrument')
        code_wind = instrument.code_wind;
    elseif ischar(instrument)
        instr = code2instrument(instrument);
        code_wind = instr.code_wind;
    end
        
    if strcmpi(code_wind(1:2),'SC')
        code_wind = [code_wind(1:end-3),'SHF'];
    end
    category = getfutcategory(instrument);
    
    bds = gendates('fromdate',datenum(startdate,'yyyy-mm-dd'),...
        'todate',datenum(enddate,'yyyy-mm-dd'));
    n = size(bds,1);
    if n == 0
        fprintf('cTHS:tickdata:no business dates found between input startdate and enddate\n');
        data = [];
        return
    elseif n == 1
        startdate_ = [datestr(bds,'yyyymmdd'),' ',instrument.break_interval{1,1}];
        if category > 4
            enddate_ = [datestr(bds+1,'yyyymmdd'),' ',instrument.break_interval{end,end}];
        else
            enddate_ = [datestr(bds,'yyyymmdd'),' ',instrument.break_interval{end,end}];
        end
        thsdata = THS_SS(code_wind,'latest;vol','',startdate_,enddate_,'format:table');
        try
            %THS returns spot trading volume
            d = [datenum(thsdata.time),thsdata.latest,thsdata.vol];
            idx = d(:,end) ~= 0;
            data = d(idx,:);
        catch e
            fprintf('cTHS:tickdata:on %s:%s\n',datestr(bds,'yyyy-mm-dd'),e.message);
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
            thsdata = THS_SS(code_wind,'latest;vol','',startdate_,enddate_,'format:table');
            try
                d = [datenum(thsdata.time),thsdata.latest,thsdata.vol];
                idx = d(:,end) ~= 0;
                data_{i,1} = d(idx,:);
            catch e
                data_{i,1} = [];
                fprintf('cTHS:tickdata:on %s:%s\n',datestr(bds(i),'yyyy-mm-dd'),e.message);
            end
        end
        data = cell2mat(data_);
    end
        

end
%end of tickdata
