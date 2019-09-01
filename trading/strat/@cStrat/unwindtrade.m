function [ret,e,msg] = unwindtrade(strategy,tradein,varargin)
%cStrat
    if ~isa(tradein,'cTradeOpen')
        ret = 0;
        e = [];
        fprintf('%s:unwindtrade:invalid trade input...\n',class(strategy));
        return
    end
    
    instrument = tradein.instrument_;
    direction = tradein.opendirection_;
    code = instrument.code_ctp;
    volume = tradein.openvolume_;
    lasttick = strategy.mde_fut_.getlasttick(instrument);
    if isempty(lasttick)
        ret = 0;
        e = [];
        fprintf('%s:unwindtrade:no tick returns...\n',class(strategy));
        return
    end
    tradeid = tradein.id_;
    
    %we need to unwind the trade
    if strcmpi(strategy.mode_,'replay')
        closetodayFlag = 0;
    else
        if strcmpi(instrument.exchange,'.SHF')
            closetodayFlag = isclosetoday(tradein.opendatetime1_,lasttick(1));
        else
            closetodayFlag = 0;
        end
    end
    e = [];
    if direction == 1
%         while ~strcmpi(tradein.status_,'closed')
%             if ~isempty(e)
%                 strategy.helper_.refresh
%                 ret = strategy.withdrawentrusts(tradein.code_,'tradeid',tradeid);
%                 if ret == -1; break;end
%             end
            bidclosespread = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bidclosespread');
            overridepx = lasttick(2) + bidclosespread*instrument.tick_size;
%             if strcmpi(tradein.status_,'closed'),break;end
            [ret,e,msg] = strategy.shortclose(code,...
                volume,...
                closetodayFlag,...
                'time',lasttick(1),...
                'overrideprice',overridepx,...
                'tradeid',tradeid);
            if ~ret
                warning('on');
                warning('WARNING:unwind entrust failed to be placed:%s !!!\n',msg);
                warning('off');
%                 break
            else
%                 for iloop = 1:3
%                     if ~strcmpi(tradein.status_,'closed'), strategy.helper_.refresh;end
%                 end
            end
%         end            
    elseif direction == -1
%         while ~strcmpi(tradein.status_,'closed')
%             if ~isempty(e)
%                 strategy.helper_.refresh
%                 strategy.withdrawentrusts(tradein.code_,'tradeid',tradeid);
%                 if ret == -1; break;end
%             end
            askclosespread = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','askclosespread');
            overridepx = lasttick(3) - askclosespread*instrument.tick_size;
%             if strcmpi(tradein.status_,'closed'),break;end
            [ret,e,msg] = strategy.longclose(code,...
                volume,...
                closetodayFlag,...
                'time',lasttick(1),...
                'overrideprice',overridepx,...
                'tradeid',tradeid);
            if ~ret
                warning('on');
                warning('WARNING:unwind entrust failed to be placed:%s !!!\n',msg);
                warning('off');
%                 break
            else
%                 for iloop = 1:3
%                     if ~strcmpi(tradein.status_,'closed'), strategy.helper_.refresh;end
%                 end
            end
%         end
    end    
    
end