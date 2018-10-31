function [ret,e] = unwindtrade(obj,tradein)
%cStrat
    if ~isa(tradein,'cTradeOpen')
        ret = 0;
        e = [];
        fprintf('cStrat:unwindtrade:invalid trade input...\n');
        return
    end
    
    instrument = tradein.instrument_;
    direction = tradein.opendirection_;
    code = instrument.code_ctp;
    volume = tradein.openvolume_;
    lasttick = obj.mde_fut_.getlasttick(instrument);
    tradeid = tradein.id_;
    
    %we need to unwind the trade
    if strcmpi(obj.mode_,'replay')
        closetodayFlag = 0;
    else
        closetodayFlag = isclosetoday(tradein.opendatetime1_,lasttick(1));
    end
    if direction == 1
        bidclosespread = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bidclosespread');
        overridepx = lasttick(2) + bidclosespread*instrument.tick_size;
        [ret,e] = obj.shortclose(code,...
            volume,...
            closetodayFlag,...
            'time',lasttick(1),...
            'overrideprice',overridepx,...
            'tradeid',tradeid);
    elseif direction == -1
        askclosespread = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','askclosespread');
        overridepx = lasttick(3) - askclosespread*instrument.tick_size;
        [ret,e] = obj.longclose(code,...
            volume,...
            closetodayFlag,...
            'time',lasttick(1),...
            'overrideprice',overridepx,...
            'tradeid',tradeid);
    end
end