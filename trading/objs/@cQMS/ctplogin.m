function [ret] = ctplogin(obj,varargin)
%cQMS
    ret = 0;
    if ~strcmpi(obj.watcher_.conn,'ctp'), return; end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('CounterName','',@ischar);
    p.parse(varargin{:});
    countername = p.Results.CounterName;
    
    if isempty(countername), return; end
    
    if ~(strcmpi(countername,'citic_kim_fut') ||...
            strcmpi(countername,'ccb_liyang_fut'))
        error('cQMS:ctplogin:invalid countername')
    end
       
    obj.watcher_.ds = cCTP.(countername);
    obj.watcher_.ds.login;
    ret = 1;
    if ret
        fprintf('CTP counter "%s" successfully login!!!\n',countername);
    end
    
    
end