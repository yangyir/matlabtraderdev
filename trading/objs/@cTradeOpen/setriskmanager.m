function [] = setriskmanager(obj,varargin)
%cTradeOpen
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name',[],@ischar);
    
    p.parse(varargin{:});
    name = p.Results.Name;
    
    if strcmpi(name,'batman')
        obj.setriskmanager_batman(varargin{:})
        %
    elseif strcmpi(name,'standard')
        obj.setriskmanager_standard(varargin{:});
        %
    elseif strcmpi(name,'wrstep')
        obj.setriskmanager_wrstep(varargin{:});
        %
    elseif strcmpi(name,'stairs')
        obj.setriskmanager_stairs(varargin{:});
        %
    elseif strcmpi(name,'spiderman')
        obj.setriskmanager_spiderman(varargin{:});
        %
    else
        error('cTradeOpen:setriskmanager:%s not supported',name);
    end
    
    
end