function [res] = getposition(obj,varargin)
% a cETFWatcher method
% to get position of an underlying
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Code','',@ischar);
    p.parse(varargin{:});
    codein = p.Results.Code;
    
    res = {};
    foundflag = false;
    
    n_index = size(obj.codes_index_,1);
    n_sector = size(obj.codes_sector_,1);
    n_stock = size(obj.codes_stock_,1);
    
    for i = 1:n_index
        if strcmpi(codein,obj.codes_index_{i}(1:end-3)) || strcmpi(codein,obj.codes_index_{i})
            foundflag = true;
            res = obj.pos_index_{i};
            break
        end
    end
    
    if ~foundflag
        for i = 1:n_sector
            if strcmpi(codein,obj.codes_sector_{i}(1:end-3)) || strcmpi(codein,obj.codes_sector_{i})
                foundflag = true;
                res = obj.pos_sector_{i};
                break
            end
        end
    end
    %
    if ~foundflag
        for i = 1:n_stock
            if strcmpi(codein,obj.codes_stock_{i}(1:end-3)) || strcmpi(codein,obj.codes_stock_{i})
                foundflag = true;
                res = obj.pos_stock_{i};
                break
            end
        end
    end
    %
    if ~foundflag
        warning('cETFWatcher:getposition:code not registed with etf watcher'); 
    end
end