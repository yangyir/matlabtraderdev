function [] = initdata4debug(obj,instrument,dtstart,dtend)
    if ~isa(instrument,'cInstrument')
        error('cStrat:initdata4debug:invalid instrument input')
    end
    c = bbgconnect;
    dcell = c.timeseries(instrument.code_bbg,{datestr(dtstart),datestr(dtend)},[],'trade');
    dnum = cell2mat(dcell(:,2:3));
    obj.timevec4debug_ = dnum(:,1);
    obj.dtstart4debug_ = datenum(dtstart);
    obj.dtend4debug_ = datenum(dtend);
    obj.dtcount4debug_ = 0;
    c.close;
    clear c

    obj.mode_ = 'debug';
    obj.mde_fut_.mode_ = 'debug';

    obj.mde_fut_.debug_start_dt1_ = obj.dtstart4debug_;
    obj.mde_fut_.debug_start_dt2_ = datestr(obj.dtstart4debug_);
    obj.mde_fut_.debug_end_dt1_ = obj.dtend4debug_;
    obj.mde_fut_.debug_end_dt2_ = datestr(obj.dtend4debug_);
    obj.mde_fut_.debug_count_ = 0;
    obj.mde_fut_.debug_ticks_ = dnum;
    obj.mde_fut_.replay_date1_ = floor(obj.dtstart4debug_);
    
end