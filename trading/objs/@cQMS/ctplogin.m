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
            strcmpi(countername,'huaxin_ly_fut') ||...
            strcmpi(countername,'ccb_ly_fut') ||...
            strcmpi(countername,'ccb_yy_fut') ||...
            strcmpi(countername,'simnow_test') ||...
            strcmpi(countername,'rh_tf6') || ...
            strcmpi(countername,'gfqh_ctp2358') || ...
            strcmpi(countername,'gfqh_tgzg'))
        error('cQMS:ctplogin:invalid countername')
    end
       
    obj.watcher_.ds = cCTP.(countername);
    ret = obj.watcher_.ds.login;
    if ret
        fprintf('CTP MD counter "%s" successfully login!!!\n',countername);
    end
    
    
end