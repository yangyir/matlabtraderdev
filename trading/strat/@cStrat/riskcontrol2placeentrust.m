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

if ischar(instrument)
    code = instrument;
else
    code = instrument.code_ctp;
end

%first check whether the instrument is registed with the strategy
flag = obj.instruments_.hasinstrument(instrument);
if ~flag
    ret = 0;
    fprintf('%s:failed to place entrust as %s not registed with strategy...\n', class(obj),code);
    return
end

%second to check whether to exceed the max volume allowance per entrust
try
    maxvolumeperentrust = obj.riskcontrols_.getconfigvalue('code',code,'propname','baseunits');
catch
    maxvolumeperentrust = 0;
end
if volume > maxvolumeperentrust
    ret = 0;
    fprintf('%s:failed to place entrust as max allowance of %d lots per entrust on %s breached...\n',class(obj),maxvolumeperentrust,code);
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

%NOTE:apart from this entrust with existing positions, we shall check all
%other pending entrust with the same instrument
npending = obj.helper_.entrustspending_.latest;
volume_pending = 0;
if npending == 0
    volume_pending = 0;
else
    for ipending = npending
        e_i = obj.helper_.entrustspending_.node(ipending);
        if strcmpi(e_i.instrumentCode,code) && e_i.offsetFlag == 1
            volume_pending = volume_pending + e_i.volume * e_i.direction;
        end
    end
end

volume2check = volume*direction + volume_exist*direction_exist+volume_pending;

try
    maxvolume = obj.riskcontrols_.getconfigvalue('code',code,'propname','maxunits');
catch
    maxvolume = 0;
end
if volume2check > maxvolume
    ret = 0;
    fprintf('%s:failed to place entrust as max allowance of %d lots on %s breached...\n',class(obj),maxvolume,code);
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
    fprintf('%s:failed to place entrust with insufficent funds...\n',class(obj),num2str(marginrequirement));
    return
end

ret = 1;


end