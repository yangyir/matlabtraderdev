function [] = override(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('price',[],@isnumeric);
    p.addParameter('volume',[],@isnumeric);
    p.addParameter('time',now,@isnumeric);
    p.addParameter('lastbusinessdate',getlastbusinessdate,@isnumeric);
    p.parse(varargin{:});
    code_ctp = p.Results.code;
    px = p.Results.price;
    volume = p.Results.volume;
    time = p.Results.time;
    lastbusinessdate = p.Results.lastbusinessdate;
    
    code_bbg = ctp2bbg(code_ctp);
    if ~isempty(strfind(code_bbg,'TFT')) || ~isempty(strfind(code_bbg,'TFC'))
        lastbusinessdate = datenum([datestr(lastbusinessdate,'yyyy-mm-dd'),' 15:15:00']);
    else
        lastbusinessdate = datenum([datestr(lastbusinessdate,'yyyy-mm-dd'),' 15:00:00']);
    end
    
    if isempty(px), return; end
    
    if px <= 0
        error('cPos:override:invalid price input')
    end
    
    obj.code_ctp_ = code_ctp;
    obj.direction_ = sign(volume);
    obj.position_total_ = abs(volume);
    if time > lastbusinessdate
        obj.position_today_ = abs(volume);
    else
        obj.position_today_ = 0;
    end
    obj.cost_carry_ = px;
    obj.cost_open_ = px;
    obj.cob_date1_ = floor(time);

end