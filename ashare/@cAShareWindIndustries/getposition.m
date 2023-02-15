function [res] = getposition(obj,varargin)
% a cAShareWindIndustries method
% to get position of an underlying
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Code','',@ischar);
    p.parse(varargin{:});
    codein = p.Results.Code;
    
    res = {};
    foundflag = false;
    
    n_index = size(obj.codes_index_,1);
    
    for i = 1:n_index
        if strcmpi(codein,obj.codes_index_{i}(1:end-3)) || strcmpi(codein,obj.codes_index_{i})
            foundflag = true;
            res = obj.pos_index_{i};
            break
        end
    end
    
    %
    if ~foundflag
        warning('cAShareWindIndustries:getposition:code not registed...'); 
    end
end