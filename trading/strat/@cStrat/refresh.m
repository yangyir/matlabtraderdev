function [] = refresh(strategy)
    if ~isempty(strategy.mde_fut_)
        if strcmpi(strategy.mde_fut_.status_,'sleep')
            return
        end
    end
    
    if strcmpi(strategy.mode_,'replay') && strcmpi(strategy.status_,'working')
<<<<<<< HEAD
        instrument = strategy.instruments_.getinstrument{1};
        candle = strategy.mde_fut_.getlastcandle(instrument);
        fprintf('time:%s; price:%s\n',datestr(candle{1}(1)),num2str(candle{1}(5)));
=======
        instr = strategy.instruments_.getinstrument{1};
        c = strategy.mde_fut_.getlastcandle(instr);
        fprintf('time:%s; price:%s\n',datestr(c{1}(1)),num2str(c{1}(4)));
>>>>>>> c49191705c205d0cda0b8ecb6161bb96b63e9bba
    end

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
            inst = strategy.instruments_.getinstrument;
            codestr = inst{1}.code_ctp;
            tick = strategy.mde_fut_.getlasttick(codestr);
            strategy.riskmanagement(tick(1));
        end
    catch e
        msg = ['error:cStrat:riskmanagment:',e.message,'\n'];
        fprintf(msg);
    end
    %
    try
        signals = strategy.gensignals;
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
end