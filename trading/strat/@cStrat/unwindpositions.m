function [] = unwindpositions(strategy,instrument,varargin)
    p = inputParser;
    p.CaseSensitive = false;
    p.KeepUnmatched = true;
    p.addParameter('closestr','',@ischar);
    p.parse(varargin{:});
    closestr = p.Results.closestr;

    if ischar(instrument)
        instrument = code2instrument(instrument);
    end
    
    isshfe = strcmpi(instrument.exchange,'.SHF');
    
    %check whether the instrument has been registered with the
    %strategy
    flag = strategy.hasinstrument(instrument);
    isstratopt = isa(strategy,'cStratOptMultiFractal');
    if ~flag
        if isstratopt && ~isoptchar(instrument.code_ctp)
            %do nothing
        else
        
            return; 
        end
    end

    %check whether the instrument has been traded already
%     [flag,idxp] = strategy.helper_.book_.hasposition(instrument);
    flag = strategy.helper_.book_.hasposition(instrument);
    if ~flag, return; end

    %withdraw all pending entrusts associated with this instrument
    strategy.withdrawentrusts(instrument);
    
    %note:as all risk/pnl is managed on trade level, we shall unwind all
    %trades associated with the instrument given
    try
        ntrades = strategy.helper_.trades_.latest_;
    catch
        ntrades = 0;
    end
    for itrade = 1:ntrades
        trade_i = strategy.helper_.trades_.node_(itrade);
        if strcmpi(trade_i.code_,instrument.code_ctp) && ...
                ~strcmpi(trade_i.status_,'closed')
            strategy.unwindtrade(trade_i);
            if ~isempty(closestr)
                trade_i.riskmanager_.closestr_ = closestr;
            end
        else
            if isstratopt && isa(trade_i.instrument_,'cOption')
                if strcmpi(trade_i.instrument_.code_ctp_underlier,instrument.code_ctp) && ...
                        ~strcmpi(trade_i.status_,'closed')
                    strategy.unwindtrade(trade_i);
                    if ~isempty(closestr)
                        trade_i.riskmanager_.closestr_ = closestr;
                    end 
                end
            end
        end
    end
    
%     volume_total = strategy.helper_.book_.positions_{idxp}.position_total_;
%     volume_today = strategy.helper_.book_.positions_{idxp}.position_today_;
%     direction = strategy.helper_.book_.positions_{idxp}.direction_;
%     
%     if isshfe
%         if volume_today > 0
%             if direction == 1
%                 [ret1] = strategy.shortclose(instrument.code_ctp,volume_today,1);
%             elseif direction == -1
%                 [ret1] = strategy.longclose(instrument.code_ctp,volume_today,1);
%             end
%         else
%             ret1 = 1;
%         end
%         volume_before = volume_total - volume_today;
%         if volume_before > 0
%             if direction == 1
%                 [ret2] = strategy.shortclose(instrument.code_ctp,volume_before);
%             elseif direction == -1
%                 [ret2] = strategy.longclose(instreument.code_ctp,volume_before);
%             end
%         else
%             ret2 = 1;
%         end
%         if volume_total > 0 && ret1 && ret2
%             fprintf('%s:positions of %s are unwinded...\n',strategy.name_,instrument.code_ctp);
%         end
%     else
%         if direction == 1 && volume_total > 0
%             [ret] = strategy.shortclose(instrument,volume_total);
%         elseif direction == -1 && volume_total > 0
%             [ret] = strategy.longclose(instrument,volume_total);
%         end
%         if ret
%             fprintf('%s:positions of %s are unwinded...\n',strategy.name_,instrument.code_ctp);
%         end
%     end
    
end
%end of unwindpositions