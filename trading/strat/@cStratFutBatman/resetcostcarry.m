function [] = resetcostcarry(obj,varargin)    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('level',[],@isnumeric);
    p.parse(varargin{:});
    codestr = p.Results.code;
    if isempty(codestr), return; end
    
    [flag,idx] = obj.bookrunning_.hasposition(codestr);
    
    if ~flag, return; end
       
    level = p.Results.level;
    obj.bookrunning_.positions_{idx}.cost_carry_ = level;
    
end