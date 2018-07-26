function [] = refresh(strategy)
    
    if ~isempty(strategy.mde_fut_)
        if strcmpi(strategy.mde_fut_.status_,'sleep')
            return
        end
    end
    
    inst = strategy.instruments_.getinstrument;
    try
        strategy.updategreeks;
    catch e
        msg = ['error:cStrat:updategreeks:',e.message,'\n'];
        fprintf(msg);
    end
    %
    try
        if strcmpi(strategy.mode_,'realtime')
            strategy.riskmanagement(now);
        elseif strcmpi(strategy.mode_,'replay')
%             codestr = inst{1}.code_ctp;
            tick = strategy.mde_fut_.getlasttick(inst{1});
            strategy.riskmanagement(tick(1));
        end
    catch e
        msg = ['error:cStrat:riskmanagment:',e.message,'\n'];
        fprintf(msg);
    end
    %
    calcsignalflag = false;
    try
        if strcmpi(strategy.mode_,'realtime')
            fprintf('todo:not implemented...\n')
        elseif strcmpi(strategy.mode_,'replay') && strcmpi(strategy.status_,'working')
            %note:yangyiran 20180727
            %we need to make sure we need to calc(re-calc) signal here
            %rule:we start to recalc signal once the candle K is fully
            %feeded. however, the newset flag is set once the first tick
            %after the candle bucket arrives and is reset FALSE after the
            %second tick arrives.           
            calcsignalflag = strategy.getcalcsignalflag(inst{1});
            if calcsignalflag
                signals = strategy.gensignals;
                signal = signals{1};
                if ~isempty(signal)
                    fprintf('\thighest:%d;lowest:%d\n',signal.highestprice,signal.lowestprice);
                end
            else
                signals = {};
            end
        end
    catch e
        msg = ['error:cStrat:gensignals:',e.message,'\n'];
        fprintf(msg);
    end
    %
    try
        strategy.autoplacenewentrusts(signals);
    catch e
        msg = ['error:cStrat:autoplacenewentrusts:',e.message,'\n'];
        fprintf(msg);
    end
    
    if strcmpi(strategy.mode_,'replay') && strcmpi(strategy.status_,'working')
        try
            if calcsignalflag
                strategy.helper_.book_.printpositions;
                strategy.helper_.printallentrusts;
            end
        catch
        end
    end
        
end