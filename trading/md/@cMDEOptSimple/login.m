function [ret] = login(obj,varargin)
%cMDEOpt
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
        fprintf('cMDEOpt:login:empty connection entry!!!\n');
        return
    end
    
    if isempty(countername)
        fprintf('cMDEOpt:login:empty countername entry!!!\n');
    end
    
    if ~(strcmpi(conn,'Bloomberg') || strcmpi(conn,'Wind') || ...
            strcmpi(conn,'CTP') || strcmpi(conn,'Local'))
        error('cMDEOpt:login:invalid connection entry!!!\n')
    end
    
    obj.qms_.setdatasource(conn);
    if strcmpi(conn,'CTP')
        ret = obj.qms_.ctplogin('countername',countername);
    elseif strcmpi(conn,'Bloomberg')
        error('cMDEOpt:login:Bloomberg login not implemented')
    elseif strcmpi(conn,'Wind')
        error('cMDEOpt:login:Wind login not implemented')
    elseif strcmpi(conn,'Local')
        error('cMDEOpt:login:Local login not implemented')
    else
        %do nothing
    end
    
    
end