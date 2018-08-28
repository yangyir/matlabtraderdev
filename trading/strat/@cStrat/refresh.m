function [] = refresh(strategy,varargin)
    %note:cStrat::refresh
    %add sanity check
    if isempty(strategy.mde_fut_) && isempty(strategy.mde_opt_)
        strategy.stop;
        error('cStrat:refresh:mdefut or mdeopt not registed in strategy......\n')
    end
    
    if ~isempty(strategy.mde_fut_)
        if strcmpi(strategy.mde_fut_.status_,'sleep'), return; end
    end
    
    p = inputParser;
    p.CaseSensitive = false; p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    t = p.Results.Time;
    
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
            strategy.riskmanagement(t);
        elseif strcmpi(strategy.mode_,'replay')
            tick = strategy.mde_fut_.getlasttick(inst{1});
            %note:stratety might run in front of the mdefut and thus tick
            %shall return empty in such case
            if ~isempty(tick), strategy.riskmanagement(tick(1));end
        end
    catch e
        msg = ['error:cStrat:riskmanagment:',e.message,'\n'];
        fprintf(msg);
    end
    %
    calcsignalflag = false;
    signals = {};
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
            try
                calcsignalflag = strategy.getcalcsignalflag(inst{1});
%                 calcsignalflag = strategy.istime2calcsignal(t);
            catch e
                msg = ['error:cStrat:getcalcsignalflag:',e.message,'\n'];
                fprintf(msg);
            end
            if calcsignalflag
                signals = strategy.gensignals;
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
    
%     if strcmpi(strategy.mode_,'replay') && strcmpi(strategy.status_,'working')
%         try
%             if calcsignalflag
% %                 strategy.helper_.printrunningpnl('mdefut',strategy.mde_fut_);
% %                 strategy.helper_.printallentrusts;
%             end
%         catch
%         end
%     end
        
end