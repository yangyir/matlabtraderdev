function p = subportfolio(obj,instruments)
   %create a sub-portfolio with only provided instruments in it
   n = obj.count;
    if n == 0
        p = {};
        return
    end

    p = cPortfolio;
    if nargin < 2
        %here we shall create another copy of the portfolio rather
        %than a copy of the pointer
        p.instrument_list = obj.instrument_list;
        p.instrument_avgcost = obj.instrument_avgcost;
        p.instrument_volume = obj.instrument_volume;
        p.instrument_volume_today = obj.instrument_volume_today;
        p.pos_list_ = obj.pos_list_;
        return
    end


    if isa(instruments,'cInstrument')
        [flag,idx] = portfolio.hasinstrument(instruments);
        if ~flag
            error(['cPortfolio:subportfolio:invalid instrument input,missing information of ',instruments.code_ctp]);
        end 
        avgcost = portfolio.instrument_avgcost(idx);
        volume = portfolio.instrument_volume(idx);
        volume_today = portfolio.instrument_volume_today(idx);

        p.addinstrument(instruments,avgcost,volume);
        p.instrument_volume_today = volume_today;

        return
    end

    if isa(instruments,'cInstrumentArray')
        instruments_ = instruments.getinstrument;
    elseif iscell(instruments)
        instruments_ = instruments;
    else
        error('cPortfolio:calcpnl:invalid instrument inputs')
    end

    for i = 1:length(instruments_)
        instrument = instruments_{i};
        [flag,idx] = obj.hasinstrument(instrument);
        if ~flag
            error(['cPortfolio:calcpnl:invalid instrument input,missing information of ',instrument.code_ctp]);
        end
        avgcost = obj.instrument_avgcost(idx);
        volume = obj.instrument_volume(idx);
        p.addinstrument(instrument,avgcost,volume);
        volume_today = obj.instrument_volume_today(idx);
        p.instrument_volume_today(i) = volume_today;
    end

end
%end of subportfolio