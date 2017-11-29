function [] = replay_timer_fcn(strategy,~,event)
    if strcmpi(strategy.mode_,'debug')
        strategy.dtcount4debug_ = strategy.dtcount4debug_ + 1;
        dtnum = strategy.timevec4debug_(strategy.dtcount4debug_,1);
    else
        dtnum = datenum(event.Data.time);
    end
    mm = minute(dtnum) + hour(dtnum)*60;

    %note: friday evening market, e.g.all market close on 2:30am and the
    %last closed contract is shfe au
    if isholiday(floor(dtnum))
        if weekday(dtnum) == 7 && mm >= 180
            return
        elseif weekday(dtnum) == 7 && mm < 180
            %market might be still open
        else
            return
        end
    end

    %market closed for sure
    if (mm > 150 && mm < 540) || (mm > 690 && mm < 780 ) || (mm > 915 && mm < 1260)
        % save candles on 2:31am
%         if mm == 151, strategy.mde_fut_.savecandles2file(dtnum); end
% 
%         %init the required data on 8:50
%         if mm == 530
%             %todo
%         end
        return
    end

    %market open refresh the market data
    if ~isempty(strategy.mde_fut_), strategy.mde_fut_.refresh; end
    if ~isempty(strategy.mde_opt_), strategy.mde_opt_.refresh; end

    try
        strategy.updategreeks;
    catch e
        msg = ['error:cStrat:updategreeks:',e.message,'\n'];
        fprintf(msg);
    end
    %
    try
        strategy.updateentrusts;
    catch e
        msg = ['error:cStrat:updateentrusts:',e.message,'\n'];
        fprintf(msg);
    end
    %
    try
        strategy.riskmanagement(dtnum);
    catch e
        msg = ['error:cStrat:riskmanagment:',e.message,'\n'];
        fprintf(msg);
    end
    %
    try
        signals = strategy.gensignals;
    catch e
        msg = ['error:cStrat:gensiignals:',e.message,'\n'];
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