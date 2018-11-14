function [ret,errmsg] = riskcontrol2placeentrust(obj,instrument,varargin)
%cStrat
%note:risk control of placing (open) entrust
%rules:
%   1.the instrument is self-registered with the strategy
%   2.not to breach the unit volume for each entrust
%   3.not to breach the maximum volume allowance for the instrumet of
%   interest
%   4.not to breach the existing margin allowance of strategy
%   5.not to breach the amber line of the strategy itself
%   6.not to breach the maximum execution number per bucket
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
    errmsg = [class(obj),':riskcontrol2placeentrust:invalid price input...']; 
    fprintf('%s\n',errmsg)
    return
end
volume = p.Results.volume;
if isempty(volume) || volume <= 0
    ret = 0;
    errmsg = [class(obj),'riskcontrol2placeentrust:invalid volume input...'];
    fprintf('%s\n',errmsg);
    return
end
direction = p.Results.direction;
if isempty(direction) || ~(direction == 1 || direction == -1)
    ret = 0;
    errmsg = [class(obj),'riskcontrol2placeentrust:invalid direction input...'];
    fprintf('%s\n',errmsg);
    return
end

if ischar(instrument)
    code = instrument;
else
    code = instrument.code_ctp;
end

%first check whether the instrument is registed with the strategy
[flag,idxinstrument] = obj.instruments_.hasinstrument(instrument);
if ~flag
    ret = 0;
    errmsg = [class(obj),':failed to place entrust as ',code,' not registed with strategy... '];
    fprintf('%s\n',errmsg);
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
    errmsg = sprintf('%s:failed to place entrust as max allowance of %d lots per entrust on %s breached...',class(obj),maxvolumeperentrust,code); 
    fprintf('%s\n',errmsg);
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
    errmsg = sprintf('%s:failed to place entrust as max allowance of %d lots on %s breached...',class(obj),maxvolume,code);
    fprintf('%s\n',errmsg);
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
    errmsg = sprintf('%s:failed to place entrust with insufficent funds...',class(obj));
    fprintf('%s\n',errmsg);
    return
end

%fifth to check whether the amber line of the strategy is breached or not
currentequity = obj.currentequity_;
amberline = obj.amberline_;
if ~isempty(amberline)
    if currentequity < amberline
        ret = 0;
        errmsg = sprintf('%s:failed to place entrust with amberline breached...',class(obj));
        fprintf('%s\n',errmsg);
        return
    end
end

%sixth to check whether the max execution number per bucket is breached
try
    maxexecutionperbucket = obj.riskcontrols_.getconfigvalue('code',code,'propname','maxexecutionperbucket');

catch
    maxexecutionperbucket = 1;
    
end
numexecuted = obj.executionperbucket_(idxinstrument);
if numexecuted >= maxexecutionperbucket
    ret = 0;
    errmsg = sprintf('%s:failed to place entrust with maximum execution per bucket breached...',class(obj));
    fprintf('%s\n',errmsg);
    return
end

ret = 1;
errmsg = '';

end