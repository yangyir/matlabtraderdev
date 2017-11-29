function position = loadpositionfromcounter(counter,instrument)
    if ~isa(counter,'CounterCTP')
        error('loadpositionfromcounter:invalid counter input')
    end

    if ischar(instrument)
        codestr = instrument;
        isopt = isoptchar(codestr);
        if isopt
            instrument = cOption(codestr);
        else
            instrument = cFutures(codestr);
        end
        instrument.loadinfo([codestr,'_info.txt']);
    elseif isa(instrument,'cInstrument')
        codestr = instrument.code_ctp;
    else
        error('loadpositionfromcounter:invalid instrument input')
    end
    
    bd = getlastbusinessdate;
    pos = counter.queryPositions(codestr);
    sizep = size(pos,2);
    if sizep == 0
        position.instrument = instrument;
        position.volume = 0;
        position.opencost = 0;
        position.carrycost = 0;
        position.cumulativepnl = 0;
        position.carrydate1 = bd;
        position.carrydate2 = datestr(bd,'yyyy-mm-dd');
    else
        isbond = ~isempty(strfind(instrument.code_bbg,'TFT')) || ~isempty(strfind(instrument.code_bbg,'TFC'));
        multiplier = instrument.contract_size;
        if isbond, multiplier = multiplier/100;end
        
        qms = cQMS;qms.setdatasource('local');
        data = qms.watcher_.ds.history(instrument,'last_trade',datestr(bd),datestr(bd));
        closep = data(2);
        
        volume = 0;
        opencost = 0;
        for i = 1:sizep
            volume = volume + pos(i).direction*pos(i).total_position;
            opencost = opencost+pos(i).direction*pos(i).face_cost;
        end
        if volume ~= 0
            opencost = opencost/volume/multiplier;
            carrycost = closep;
            cumulativepnl = (closep-opencost)*volume*multiplier;
        else
            cumulativepnl = opencost;
            opencost = 0;
            carrycost = 0;
        end
        
        position.instrument = instrument;
        position.volume = volume;
        position.opencost = opencost;
        position.carrycost = carrycost;
        position.cumulativepnl = cumulativepnl;
        position.carrydate1 = bd;
        position.carrydate2 = datestr(bd,'yyyy-mm-dd');
    end
    
end