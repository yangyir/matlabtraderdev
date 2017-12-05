function [] = override(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('price',[],@isnumeric);
    p.addParameter('volume',[],@isnumeric);
    p.addParameter('time',now,@isnumeric);
    p.parse(varargin{:});
    code_ctp = p.Results.code;
    px = p.Results.price;
    volume = p.Results.volume;
    time = p.Results.time;
    if px <= 0
        error('cPos:override:invalid price input')
    end
    
    obj.code_ctp_ = code_ctp;
    obj.direction_ = sign(volume);
    obj.position_total_ = abs(volume);
    if time > getlastbusinessdate
        obj.position_today_ = abs(volume);
    else
        obj.position_today_ = 0;
    end
    obj.cost_carry_ = px;
    obj.cost_open_ = px;
    obj.cob_date1_ = floor(time);

end