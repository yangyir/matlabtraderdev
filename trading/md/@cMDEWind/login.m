function [ret] = login(obj,varargin)
%cMDEWind
    if strcmpi(obj.mode_,'replay')
        error('cMDEWind:login:not implemented in replay mode')
%         return; 
    end
    
    try
        obj.conn_ = cWind;
        ret = obj.conn_.ds_.isconnected;
        if ret
            fprintf('login to Wind...\n');
        end
    catch
        fprintf('Wind not installed...\n');
        ret = false;
    end
    
    
end