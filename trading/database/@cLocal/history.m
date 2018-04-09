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
        else
            data = [];
            %todo
        end
    catch e
        error(['cLocal:history:',e.message])
    end

end
%end of history

