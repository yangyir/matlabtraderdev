function [vtotal,vtoday] = getpositions(obj,varargin)
%cBook
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.parse(varargin{:});
    code_ctp = p.Results.code;
    [bool,idx] = obj.hasposition(code_ctp);
    if ~bool
        vtotal = 0;
        vtoday = 0;
    else
        pos = obj.positions_{idx};
        vtotal = pos.position_total_;
        vtoday = pos.position_today_;
    end
end