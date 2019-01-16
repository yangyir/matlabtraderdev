function data = history(obj,instrument,fields,fromdate,todate)
    %to be implemented
    if isa(instrument,'cInstrument')
        instrument = instrument.code_ctp;
    end

    try
        fn_ = [instrument,'_daily.txt'];
        fullfn_ = [obj.ds_,'dailybar\',fn_];
        data = cDataFileIO.loadDataFromTxtFile(fullfn_);
        fromdatenum = datenum(fromdate);
        todate = datenum(todate);
        idx = data(:,1)>=fromdatenum & data(:,1)<=todate;
        if strcmpi(fields,'last_trade')
            data = [data(idx,1),data(idx,5)];
        elseif strcmpi(fields,'open')
            data = [data(idx,1),data(idx,2)];
        elseif strcmpi(fields,'high')
            data = [data(idx,1),data(idx,3)];
        elseif strcmpi(fields,'low')
            data = [data(idx,1),data(idx,4)];
        elseif strcmpi(fields,'volume')
            data = [data(idx,1),data(idx,6)];
        elseif strcmpi(fields,'open_int')
            data = [data(idx,1),data(idx,7)];
        elseif strcmpi(fields,'all')
            data = data(idx,:);
        else
            data = [];
            %todo
        end
    catch e
        error(['cLocal:history:',e.message])
    end

end
%end of history

