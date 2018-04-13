function [] = removepositions(obj,varargin)
%cBook
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.parse(varargin{:});
    code_ctp = p.Results.code;
    [flag,idx] = obj.hasposition(code_ctp);
    if ~flag
        return
    end
    n = size(obj.positions_,1);
    if n == 1
        obj.positions_ = {};
    else
        positions = cell(n-1,1);
        for i = 1:idx-1
            positions{i,1} = obj.positions_{i,1};
        end
        for i = idx+1:n
            positions{i-1,1} = obj.positions_{i,1};
        end
        obj.positions_ = positions;
    end
end