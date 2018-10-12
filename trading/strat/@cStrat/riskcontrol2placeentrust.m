function [ret] = riskcontrol2placeentrust(obj,instrument,varargin)
%cStrat
%note:risk control of placing (open) entrust
%rules:
%   1.the instrument is self-registered with the strategy
%   2.not to breach the unit volume for each entrust
%   3.not to breach the maximum volume allowance for the instrumet of
%   interest
%   4.not to breach the existing margin allowance of strategy
%
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = false;
p.addParameter('price',[],@isnumeric);
p.addParameter('volume',[],@isnumeric);
p.addParameter('direction',[],@isnumeric);
p.parse(varargin{:})
price = p.Results.price;
if isempty(price)
    ret = 0;
    fprintf('cStrat:riskcontrol2placeentrust:invalid price input\n')
    return
end
volume = p.Results.volume;
if isempty(volume) || volume <= 0
    ret = 0;
    fprintf('cStrat:riskcontrol2placeentrust:invalid volume input\n')
    return
end
direction = p.Results.direction;
if isempty(direction) || ~(direction == 1 || direction == -1)
    ret = 0;
    fprintf('cStrat:riskcontrol2placeentrust:invalid direction input\n')
    return
end

%first check whether the instrument is registed with the strategy
flag = obj.instruments_.hasinstrument(instrument);
if ~flag
    ret = 0;
    if ischar(instrument)
        code = instrument;
    else
        code = instrument.code_ctp;
    end
    fprintf('cStrat:riskcontrol2placeentrust:instrument %s not registed with strategy\n', code);
    return
end

%second to check whether to exceed the max volume allowance per entrust
maxvolumeperentrust = obj.getbaseunits(instrument);
if volume > maxvolumeperentrust
    ret = 0;
    fprintf('cStrat:riskcontrol2placeentrust:volume exceeds max volume allowance per entrust\n');
    return
end

%third to check whether to exceed the max volume allowance per instrument
[flag,idx] = obj.helper_.book_.hasposition(instrument);
if ~flag
    volume_exist = 0;
    direction_exist = 0;
else
    pos = obj.helper_.book_.positions_{idx};
    volume_exist = pos.position_total_;
    direction_exist = pos.direction_;
end

volume2check = volume*direction + volume_exist*direction_exist;
maxvolume = obj.getmaxunits(instrument);
if volume2check > maxvolume
    ret = 0;
    fprintf('cStrat:riskcontrol2placeentrust:volume exceeds max volume allowance per instrument\n');
    return
end

%fourth to check whether margin is sufficient to place an entrust
if ischar(instrument), instrument = code2instrument(instrument);end
marginratio = instrument.init_margin_rate;
ticksize = instrument.tick_size;
tickvalue = instrument.tick_value;
marginrequirement = marginratio * price * volume /ticksize*tickvalue;
availablefund = obj.getavailablefund;

if marginrequirement > availablefund
    ret = 0;
    fprintf('cStrat:riskcontrol2placeentrust:insufficent fund\n');
    return
end

ret = 1;


end