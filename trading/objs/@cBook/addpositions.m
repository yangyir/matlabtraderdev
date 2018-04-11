function [] = addpositions(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('price',[],@isnumeric);
    p.addParameter('volume',[],@isnumeric);
    p.addParameter('time',now,@isnumeric);
    p.addParameter('closetodayflag',0,@isnumeric);
    p.parse(varargin{:});
    code_ctp = p.Results.code;
    px = p.Results.price;
    volume = p.Results.volume;
    time = p.Results.time;
    closetoday = p.Results.closetodayflag;
    
    [bool,idx] = obj.hasposition(code_ctp);
    if ~bool
        if closetoday ~= 0
            error('cBook:addpositions:position not found to close in the portfolio')
        end
        n = size(obj.positions_,1);
        positions = cell(n+1,1);
        pos = cPos;
        pos.override('code',code_ctp,'price',px,'volume',volume,'time',time);
        positions{n+1,1} = pos;
        
        for i = 1:n, positions{i,1} = obj.positions_{i,1}; end
        obj.positions_ = positions;
    else
        obj.positions_{idx,1}.add('code',code_ctp,'price',px,'volume',volume,'time',time,'closetodayflag',closetoday);
    end
    

end