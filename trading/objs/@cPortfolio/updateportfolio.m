function pnl = updateportfolio(cport,transaction)
    %pnl is the close pnl returned
    %todo:transaction fees shall be added later
    if ~isa(transaction,'cTransaction')
        error('cPortfolio:updateportfolio:invalid transaction input')
    end
    instrument = transaction.instrument_;
    px = transaction.price_;
    volume = transaction.volume_*transaction.direction_;
    offset = transaction.offset_;
    datetime1_ = transaction.datetime1_;
    if offset == -1 && transaction.closetodayflag_
        closetodayflag_ = 1;
    else
        closetodayflag_ = 0;
    end

    [bool,idx] = cport.hasinstrument(instrument);

    if ~bool && offset == -1
        error('cPortfolio:updateportfolio:cannot unwind unexisted positions ')
    end

    if ~bool
        cport.addinstrument(instrument,px,volume,datetime1_);
        pnl = 0;
    else
        avgcost_ = cport.instrument_avgcost(idx,1);
        volume_ = cport.instrument_volume(idx,1);
        voume_today_ = cport.instrument_volume_today(idx,1);

        if offset == -1 && abs(volume_) < transaction.volume_
            error('cPortfolio:updateportfolio:unwind transaction size exceed existing size')
        end

        if closetodayflag_ && abs(voume_today_) < transaction.volume_
            error('cPortfolio:updateportfolio:unwind transaction size exceed existing size of today')
        end

%                 obj.instrument_volume(idx,1) = volume_+volume;
%                 obj.instrument_volume_today(idx,1) = voume_today_ + volume_today;
        cport.addinstrument(instrument,px,volume,datetime1_);
        if cport.instrument_volume(idx,1) == 0
            %the position is now completely unwind
            tick_value = instrument.tick_value;
            tick_size = instrument.tick_size;
            pnl = (px-avgcost_)*volume_*tick_value/tick_size;
            cport.instrument_avgcost(idx,1) = 0;
        else
            cport.instrument_avgcost(idx,1) = (avgcost_*volume_ + px*volume)/(volume_+volume);
            pnl = 0;
        end
    end

end
%end of updateportfolio