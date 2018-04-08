function data = realtime(obj,instruments,fields)
    %note:the realtime function in cLocal is for REPLY the market
    %data process and the fields input shall be given as particular
    %date and time, e.g.yyyy-mm-dd HH:MM:SS
    if isa(instruments,'cInstrument')
        n = 1;
        list_ctp = cell(1,1);
        list_ctp{1} = instruments.code_ctp;
    elseif iscell(instruments)
        n = length(instruments);
        list_ctp = cell(n,1);
        for i = 1:n
            if ischar(instruments{i})
                list_ctp{i} = instruments{i};
            elseif isa(instruments{i},'cInstrument')
                list_ctp{i} = instruments{i}.code_ctp;
            else
                error('cLocal:realtime:invalid input')
            end
        end
    else
        list_ctp = instruments;
    end             

    last_update_dt = zeros(n,1);
    time_ = zeros(n,1);
    last_trade = zeros(n,1);
    bid = zeros(n,1);
    ask = zeros(n,1);
    dstr = datestr(fields,'yyyymmdd'); %date
    dtnum = datenum(fields);
    for i = 1:n
        try
            fn_ = [list_ctp{i},'_',dstr,'_1m.txt'];
            fullfn_ = [obj.ds_,'intradaybar\',list_ctp{i},'\',fn_];
            data_raw_ = cDataFileIO.loadDataFromTxtFile(fullfn_);
            idx = data_raw_(:,1) == dtnum;
            d = data_raw_(idx,:);
            if isempty(d)
                %in case the datestr cannot be found in data_raw_ we
                %choose the latest one which happens before the input
                %datestr
                idx = find(data_raw_(:,1) <= dtnum);
                idx = idx(end);
                d = data_raw_(idx,:);
            end
            last_update_dt(i) = floor(d(1));
            time_(i) = d(1);
            last_trade(i) = d(end);
            bid(i) = last_trade(i);
            ask(i) = last_trade(i);

            data = struct('last_update_dt',last_update_dt,...
                'time',time_,...
                'last_trade',last_trade,...
                'bid',bid,'ask',ask);
        catch e
            error(['cLocal:realtime:',e.message])
        end
    end

end
%end of realtime

