function [ret,e] = unwindtrade(obj,tradein,varargin)
%cStrat
    if ~isa(tradein,'cTradeOpen')
        ret = 0;
        e = [];
        fprintf('%s:unwindtrade:invalid trade input...\n',class(obj));
        return
    end
    
    instrument = tradein.instrument_;
    direction = tradein.opendirection_;
    code = instrument.code_ctp;
    volume = tradein.openvolume_;
    lasttick = obj.mde_fut_.getlasttick(instrument);
    if isempty(lasttick)
        ret = 0;
        e = [];
        fprintf('%s:unwindtrade:no tick returns...\n',class(obj));
        return
    end
    tradeid = tradein.id_;
    
    %we need to unwind the trade
    if strcmpi(obj.mode_,'replay')
        closetodayFlag = 0;
    else
        if strcmpi(instrument.exchange,'.SHF')
            closetodayFlag = isclosetoday(tradein.opendatetime1_,lasttick(1));
        else
            closetodayFlag = 0;
        end
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