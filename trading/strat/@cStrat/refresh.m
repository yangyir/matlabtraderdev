function [] = refresh(strategy,varargin)
    %note:cStrat::refresh
    %add sanity check
    if isempty(strategy.mde_fut_) && isempty(strategy.mde_opt_)
        %note:here we must stop the strategy
        strategy.stop;
        error('%s:refresh:mdefut or mdeopt not registed in strategy......\n',class(strategy))
    end
    
    if isempty(strategy.mde_fut_) && ~isempty(strategy.mde_opt_)
        %note:here we must stop the strategy
        strategy.stop;
        error('%s:refresh:mdeopt case not fully implemented yet......\n',class(strategy))
    end
    
    if isempty(strategy.helper_)
        %note:here we must stop the strategy
        strategy.stop;
        error('%s:refresh:ops not registed in strategy......\n',class(strategy))
    end
    
    try
        if strcmpi(strategy.mde_fut_.timer_.running,'off')
            fprintf('%s stops because MDE %s is off\n',class(strategy),strategy.mde_fut_.timer_.Name);
            strategy.stop;
            return
        end 
    catch e
        fprintf('error:%s::refresh::%s\n',class(strategy),e.message);
        if strcmpi(strategy.onerror_,'stop')
            strategy.stop;
        end
        return
    end
    
    %do nothing if mdefut is sleeping
    if ~isempty(strategy.mde_fut_)
        if strcmpi(strategy.mde_fut_.status_,'sleep'), return; end
    end
    %do nothing if mdeopt is sleeping
    if ~isempty(strategy.mde_opt_)
        if strcmpi(strategy.mde_opt_.status_,'sleep'), return; end
    end
    
    %process conditional entrust if there is any
    strategy.updatecondentrusts
    %
    %update totalequity_, currentmargin_, availablefund_ and frozenmargin_
    try
        [runningpnl,closedpnl] = strategy.helper_.calcpnl('mdefut',strategy.mde_fut_);
        totalpnl = sum(sum(runningpnl+closedpnl));
        strategy.currentequity_ = strategy.preequity_ + totalpnl;
        strategy.currentmargin_ = strategy.getcurrentmargin;
        strategy.frozenmargin_ = strategy.getfrozenmargin;
        strategy.availablefund_ = strategy.currentequity_ - strategy.currentmargin_ - strategy.frozenmargin_;
    catch e
        msg = ['error:',class(strategy),':refresh in updating margins:',e.message,'\n'];
        fprintf(msg);
        if strcmpi(strategy.onerror_,'stop')
            strategy.stop;
        end
    end
    %
    %check whether red line is breached or not
    if ~isempty(strategy.redline_)
        %if the redline is breached, we will unwind all existing positions
        if strategy.currentequity_ <= strategy.redline_
            instruments = strategy.getinstruments;
            n = strat.count;
            for i = 1:n
                flag = strategy.helper_.book_.hasposition(instruments{i});
                if flag
                    strat.unwindpositions(instruments{i});
                end
            end
        end
    end
    %
    %update gui
    if ~isempty(strategy.gui_)
        set(strategy.gui_.tradingstats.strategystatus_edit,'string',strategy.status_);
        set(strategy.gui_.tradingstats.strategyrunning_edit,'string',strategy.timer_.running);
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
            msg = ['error:',class(strategy),':refresh in updating gui:',e.message,'\n'];
            fprintf(msg);
            if strcmpi(strategy.onerror_,'stop')
                strategy.stop;
            end
        end
    end
    %
    %
    p = inputParser;
    p.CaseSensitive = false; p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    t = p.Results.Time;
    %
    %update greeks
    try
        if ~isempty(strategy.mde_opt_), strategy.updategreeks;end
    catch e
        msg = ['error:',class(strategy),':updategreeks:',e.message,'\n'];
        fprintf(msg);
        if strcmpi(strategy.onerror_,'stop')
            strategy.stop;
            return
        end
    end
    %
    %risk management
    try
        strategy.riskmanagement(t);
    catch e
        msg = ['error:',class(strategy),':riskmanagment:',e.message,'\n'];
        fprintf(msg);
        if strcmpi(strategy.onerror_,'stop')
            strategy.stop;
            return
        end
    end
    %
    %generate trading signals
    try
        signals = strategy.gensignals;
    catch e
        msg = ['error:',class(strategy),':gensignals:',e.message,'\n'];
        fprintf(msg);
        if strcmpi(strategy.onerror_,'stop')
            strategy.stop;
            return
        end
    end
    %
    try
        strategy.autoplacenewentrusts(signals);
    catch e
        msg = ['error:',class(strategy),':autoplacenewentrusts:',e.message,'\n'];
        fprintf(msg);
        if strcmpi(strategy.onerror_,'stop')
            strategy.stop;
            return
        end
    end
        
end