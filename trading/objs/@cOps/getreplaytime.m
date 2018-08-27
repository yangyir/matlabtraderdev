function [t] = getreplaytime(obj,varargin)
    if ~strcmpi(obj.mode_,'replay'), t = []; return;end
    
    if isempty(obj.mdefut_) && isempty(obj.mdeopt_)
        t = now;
        obj.replay_date1_ = floor(t);
        obj.replay_date2_ = datestr(obj.replay_date1_,'yyyy-mm-dd');
        obj.replay_time1_ = t;
        obj.replay_time2_ = datestr(obj.replay_time1_,'yyyy-mm-dd HH:MM:SS');
        return
    end
    
    if ~isempty(obj.mdefut_)
        if strcmpi(obj.mdefut_.mode_,'realtime')
            error('cOps and cMDEFut shall both in replay mode');
        end
        t = obj.mdefut_.getreplaytime;
        obj.replay_date1_ = obj.mdefut_.replay_date1_;
        obj.replay_date2_ = obj.mdefut_.replay_date2_;
        obj.replay_time1_ = obj.mdefut_.replay_time1_;
        obj.replay_time2_ = obj.mdefut_.replay_time2_;
        return
    end
    
    if isempty(obj.mdefut_) && ~isempty(obj.mdeopt_)
        if strcmpi(obj.mdeopt_.mode_,'realtime')
            error('cOps and cMDEFut shall both in replay mode');
        end
        t = obj.mdeopt_.getreplaytime;
        obj.replay_date1_ = obj.mdeopt_.replay_date1_;
        obj.replay_date2_ = obj.mdeopt_.replay_date2_;
        obj.replay_time1_ = obj.mdeopt_.replay_time1_;
        obj.replay_time2_ = obj.mdeopt_.replay_time2_;
        return
    end
    
end