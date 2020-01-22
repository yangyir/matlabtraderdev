function [ret] = logoff(obj)
%cMDEOptBBG
    if strcmpi(obj.mode_,'replay'), return; end
    try
        obj.conn_.ds_.close;
        ret = true;
        if ~obj.conn_.ds_.isconnection
            fprintf('logoff Bloomberg...\n');
        end
    catch
        fprintf('Bloomberg not installed...\n');
        ret = false;
    end
    
end