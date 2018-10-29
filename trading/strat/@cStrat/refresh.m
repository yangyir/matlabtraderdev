function [] = refresh(strategy,varargin)
    %note:cStrat::refresh
    %add sanity check
    if isempty(strategy.mde_fut_) && isempty(strategy.mde_opt_)
        strategy.stop;
        error('cStrat:refresh:mdefut or mdeopt not registed in strategy......\n')
    end
    
    if isempty(strategy.helper_)
        strategy.stop;
        error('cStrat:refresh:ops not registed in strategy......\n')
    end
    
    try
        if strcmpi(strategy.mde_fut_.timer_.running,'off')
            fprintf('%s stops because %s is off\n',strategy.timer_.Name,strategy.mde_fut_.timer_.Name);
            strategy.stop;
            return
        end 
    catch e
        fprintf('error:cMDEFut::refresh::%s\n',e.message);
        return
    end
    
    if ~isempty(strategy.mde_fut_)
        if strcmpi(strategy.mde_fut_.status_,'sleep'), return; end
    end
    
    %update totalequity_, currentmargin_, availablefund_ and frozenmargin_
    [runningpnl,closedpnl] = strategy.helper_.calcpnl('mdefut',strategy.mde_fut_);
    totalpnl = sum(sum(runningpnl+closedpnl));
    strategy.currentequity_ = strategy.preequity_ + totalpnl;
    strategy.currentmargin_ = strategy.getcurrentmargin;
    strategy.frozenmargin_ = strategy.getfrozenmargin;
    strategy.availablefund_ = strategy.currentequity_ - strategy.currentmargin_ - strategy.frozenmargin_;
    
    if ~isempty(strategy.gui_)
        try
            set(strategy.gui_.tradingstats.preinterest_edit,'string',num2str(strategy.preequity_));
            set(strategy.gui_.tradingstats.availablefund_edit,'string',num2str(strategy.availablefund_));
            set(strategy.gui_.tradingstats.currentmargin_edit,'string',num2str(strategy.currentmargin_));
            set(strategy.gui_.tradingstats.frozenmargin_edit,'string',num2str(strategy.frozenmargin_));
            val = sum(sum(runningpnl));
            if val >= 0
                set(strategy.gui_.tradingstats.runningpnl_edit,'string',num2str(val),'foregroundcolor','b');
            else
                set(strategy.gui_.tradingstats.runningpnl_edit,'string',num2str(val),'foregroundcolor','r');
            end
            val = sum(sum(closedpnl));
            if val >= 0
                set(strategy.gui_.tradingstats.closedpnl_edit,'string',num2str(val),'foregroundcolor','b');
            else
                set(strategy.gui_.tradingstats.closedpnl_edit,'string',num2str(val),'foregroundcolor','r');
            end
            if strcmpi(strategy.mode_,'replay')
                set(strategy.gui_.tradingstats.time_edit,'string',datestr(strategy.replay_time1_,'dd/mmm HH:MM:SS'));
            else
                set(strategy.gui_.tradingstats.time_edit,'string',datestr(now,'dd/mmm HH:MM:SS'));
            end
        catch
        end
    end
    
    p = inputParser;
    p.CaseSensitive = false; p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    t = p.Results.Time;
    
    inst = strategy.getinstruments;
    try
        strategy.updategreeks;
    catch e
        msg = ['error:',class(strategy),':updategreeks:',e.message,'\n'];
        fprintf(msg);
    end
    %
    try
        strategy.riskmanagement(t);
    catch e
        msg = ['error:',class(strategy),':riskmanagment:',e.message,'\n'];
        fprintf(msg);
    end
    %
    calcsignalflag = false;
    signals = {};
    try
        if strcmpi(strategy.status_,'working')
            %note:yangyiran 20180727
            %we need to make sure we need to calc(re-calc) signal here
            %rule:we start to recalc signal once the candle K is fully
            %feeded. however, the newset flag is set once the first tick
            %after the candle bucket arrives and is reset FALSE after the
            %second tick arrives.
            try
                calcsignalflag = strategy.getcalcsignalflag(inst{1});
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
        msg = ['error:',class(strategy),':autoplacenewentrusts:',e.message,'\n'];
        fprintf(msg);
    end
        
end