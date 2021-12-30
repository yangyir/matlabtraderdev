function [ret] = login(obj,varargin)
%cMDEFut
    if strcmpi(obj.mode_,'replay'), return; end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Connection','',@ischar);
    p.addParameter('CounterName','',@ischar);
    p.parse(varargin{:});
    conn = p.Results.Connection;
    countername = p.Results.CounterName;
    
    ret = 0;
    
    if isempty(conn) 
        fprintf('cMDEFut:login:empty connection entry!!!\n');
        return
    end
    
    if isempty(countername) && strcmpi(conn,'CTP')
        fprintf('cMDEFut:login:empty countername entry!!!\n');
    end
    
    if ~(strcmpi(conn,'Bloomberg') || strcmpi(conn,'Wind') || ...
            strcmpi(conn,'CTP') || strcmpi(conn,'Local'))
        error('cMDEFut:login:invalid connection entry!!!\n')
    end
    
    obj.qms_.setdatasource(conn);
    if strcmpi(conn,'CTP')
        ret = obj.qms_.ctplogin('countername',countername);
    elseif strcmpi(conn,'Bloomberg')
        error('cMDEFut:login:Bloomberg login not implemented')
    elseif strcmpi(conn,'Wind')
%         error('cMDEFut:login:Wind login not implemented')
        try
            obj.qms_.setdatasource('wind');
            ret = 1;
        catch
            ret = 0;
        end
    elseif strcmpi(conn,'Local')
        error('cMDEFut:login:Local login not implemented')
    else
        %do nothing
    end
    
    
end