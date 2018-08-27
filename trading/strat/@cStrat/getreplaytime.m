function [t] = getreplaytime(obj,varargin)
    if ~strcmpi(obj.mode_,'replay'), t = []; return;end
    
    if isempty(obj.mde_fut_) && isempty(obj.mde_opt_)
        if isempty(obj.replay_time1_), obj.replay_time1_ = now; end
        t = obj.replay_time1_;
        obj.replay_time1_ = t + 0.5/86400;
        obj.replay_date1_ = floor(obj.replay_time1_);
        obj.replay_date2_ = datestr(obj.replay_date1_,'yyyy-mm-dd');
        obj.replay_time2_ = datestr(obj.replay_time1_,'yyyy-mm-dd HH:MM:SS');
        return
    end
    
    if ~isempty(obj.mde_fut_)
        if strcmpi(obj.mde_fut_.mode_,'realtime')
            error('cOps and cMDEFut shall both in replay mode');
        end
        t = obj.mde_fut_.getreplaytime;
        obj.replay_date1_ = obj.mde_fut_.replay_date1_;
        obj.replay_date2_ = obj.mde_fut_.replay_date2_;
        obj.replay_time1_ = obj.mde_fut_.replay_time1_;
        obj.replay_time2_ = obj.mde_fut_.replay_time2_;
        return
    end
    
    if isempty(obj.mde_fut_) && ~isempty(obj.mde_opt_)
        if strcmpi(obj.mde_opt_.mode_,'realtime')
            error('cOps and cMDEFut shall both in replay mode');
        end
        t = obj.mde_opt_.getreplaytime;
        obj.replay_date1_ = obj.mde_opt_.replay_date1_;
        obj.replay_date2_ = obj.mde_opt_.replay_date2_;
        obj.replay_time1_ = obj.mde_opt_.replay_time1_;
        obj.replay_time2_ = obj.mde_opt_.replay_time2_;
        return
    end
end