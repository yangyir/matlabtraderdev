function [obj] = init(obj,varargin)
%cQMS
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Connection','',@ischar);
    p.parse(varargin{:});
    conn = p.Results.Connection;
    
    obj.instruments_ = cInstrumentArray;
    obj.watcher_ = cWatcher;
    
    if ~isempty(conn)
        obj.setdatasource(conn);
    end
    
end