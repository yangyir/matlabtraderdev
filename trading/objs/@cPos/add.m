function [] = add(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('price',[],@isnumeric);
    p.addParameter('volume',[],@isnumeric);
    p.addParameter('time',now,@isnumeric);
    p.addParameter('closetodayflag',0,@isnumeric);
    p.addParameter('lastbusinessdate',getlastbusinessdate,@isnumeric);
    p.parse(varargin{:});
    code_ctp = p.Results.code;
    px = p.Results.price;
    if isempty(px), return; end
    
    volume = p.Results.volume;
    if volume == 0, return; end
    
    time = p.Results.time;
    closetodayFlag = p.Results.closetodayflag;
    lastbusinessdate = p.Results.lastbusinessdate;
    
    if ~strcmpi(code_ctp,obj.code_ctp_), error('cPos:add:invalid code input');end
    
    if px <= 0, error('cPos:add:invalid price input'); end
    
    direction_exist = obj.direction_;
    direction_new = sign(volume);
    
    volume_exist = obj.direction_*obj.position_total_;
    volume_today_exist = obj.direction_*obj.position_today_;
    %in case unwind some or all existing positions
    if direction_exist ~= direction_new && direction_exist ~= 0
        closeFlag = 1;
        if ~closetodayFlag && abs(volume_exist) < abs(volume)
            error('cPos:add:invalid volume input,exceed current volume')
        end
        if closetodayFlag && abs(volume_today_exist) < abs(volume)
            error('cPos:add:invalid volume input,exceed current volume of today')
        end
    else
        closeFlag = 0;
    end
    
    volume_total_new = volume_exist + volume;
    if time > lastbusinessdate
        if closeFlag && ~closetodayFlag
            %平仓但不是平今仓
            volume_exist_before = volume_exist - volume_today_exist;
            if abs(volume_exist_before) >= abs(volume)
                %如果昨仓大小比平仓大小大，今仓不变
                volume_today_new = volume_today_exist;
            else
                %如果昨仓已经被平完，要平部分今仓
                volume_today_new = volume_today_exist + (volume+volume_exist_before);
            end
        elseif closeFlag && closetodayFlag
            %平仓且是平今仓
            volume_today_new = volume_today_exist + volume;
        elseif ~closeFlag && ~closetodayFlag
            %不是平仓
            volume_today_new = volume_today_exist + volume;
        end
    else
        volume_today_new = volume_today_exist;
    end
    
    if volume_total_new == 0
        cost_carry_new = 0;
        cost_open_new = 0;
    else
        cost_carry_exist = obj.cost_carry_;
        cost_open_exist = obj.cost_open_;
        amount_carry = volume_exist*cost_carry_exist+px*volume;
        amount_open = volume_exist*cost_open_exist+px*volume;
        cost_carry_new = amount_carry/volume_total_new;
        cost_open_new = amount_open/volume_total_new;
    end
    
    obj.direction_ = sign(volume_total_new);
    obj.position_total_ = abs(volume_total_new);
    obj.position_today_ = abs(volume_today_new);
    obj.cost_carry_ = cost_carry_new;
    obj.cost_open_ = cost_open_new;
    obj.cob_date1_ = floor(time);

end