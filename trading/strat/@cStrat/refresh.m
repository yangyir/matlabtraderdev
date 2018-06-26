function [] = refresh(strategy)
    if ~isempty(strategy.mde_fut_)
        if strcmpi(strategy.mde_fut_.status_,'sleep')
            return
        end
    end
    
    if strcmpi(strategy.mode_,'replay') && strcmpi(strategy.status_,'working')
        instrument = strategy.instruments_.getinstrument{1};
        tick = strategy.mde_fut_.getlasttick(instrument);
        candle = strategy.mde_fut_.getlastcandle(instrument);
        fprintf('runtime:%s; candlebuckettime:%s; price:%s\n',...
            datestr(tick(1),'yyyy-mm-dd HH:MM:SS'),...
            datestr(candle{1}(1),'HH:MM'),num2str(candle{1}(5)));
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
        strategy.autoplacenewentrusts_sunq(signals{:,1});
        strategy.autoplacenewentrusts_sunq(signals{:,2});
    catch e
        msg = ['error:cStrat:autoplacenewentrusts:',e.message,'\n'];
        fprintf(msg);
    end
end