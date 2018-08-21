function [t] = getreplaytime(obj,varargin)
    if ~strcmpi(obj.mode_,'replay'), t = []; return;end
    
    t = obj.replay_time1_;
    
end