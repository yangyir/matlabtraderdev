function [] = unwindpositions(strategy,instrument,varargin)
    if ischar(instrument)
        instrument = code2instrument(instrument);
    end
    
    isshfe = strcmpi(instrument.exchange,'.SHF');
    
    %check whether the instrument has been registered with the
    %strategy
    flag = strategy.hasinstrument(instrument);
    if ~flag, return; end

    %check whether the instrument has been traded already
    [flag,idxp] = strategy.helper_.book_.hasposition(instrument);
    if ~flag, return; end

    %withdraw all pending entrusts associated with this instrument
    strategy.withdrawentrusts(instrument);
    
    volume_total = strategy.helper_.book_.positions_{idxp}.position_total_;
    volume_today = strategy.helper_.book_.positions_{idxp}.position_today_;
    direction = strategy.helper_.book_.positions_{idxp}.direction_;
    
    if isshfe
        if volume_today > 0
            if direction == 1
                [ret1] = strategy.shortclose(instrument,volume_today,1);
            elseif direction == -1
                [ret1] = strategy.longclose(instrument,volume_today,1);
            end
        else
            ret1 = 1;
        end
        volume_before = volume_total - volume_today;
        if volume_before > 0
            if direction == 1
                [ret2] = strategy.shortclose(instrument,volume_before);
            elseif direction == -1
                [ret2] = strategy.longclose(instreument,volume_before);
            end
        else
            ret2 = 1;
        end
        if volume_total > 0 && ret1 && ret2
            fprintf('%s:positions of %s are unwinded...\n',strategy.name_,instrument.code_ctp);
        end
    else
        if direction == 1 && volume_total > 0
            [ret] = strategy.shortclose(instrument,volume_total);
        elseif direction == -1 && volume_total > 0
            [ret] = strategy.longclose(instrument,volume_total);
        end
        if ret
            fprintf('%s:positions of %s are unwinded...\n',strategy.name_,instrument.code_ctp);
        end
    end
    
end
%end of unwindpositions