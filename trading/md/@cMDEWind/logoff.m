function [ret] = logoff(obj)
%cMDEWind
    if strcmpi(obj.mode_,'replay')
        error('cMDEWind:logoff not implemented in replay mode') 
    end
    
    try
        obj.conn_.ds_.close;
        ret = true;
        if ~obj.conn_.ds_.isconnected
            fprintf('logoff Wind...\n');
        end
    catch
        fprintf('Wind not installed...\n');
        ret = false;
    end
    
end