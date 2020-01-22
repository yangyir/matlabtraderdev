function [ret] = login(obj,varargin)
%cMDEOptBBG
    if strcmpi(obj.mode_,'replay'), return; end
    
    try
        obj.conn_ = cBloomberg;
        ret = obj.conn_.ds_.isconnection;
        if ret
            fprintf('login to Bloomberg...\n');
        end
    catch
        fprintf('Bloomberg not installed...\n');
        ret = false;
    end
    
    
end