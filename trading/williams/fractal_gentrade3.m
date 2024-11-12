function [trade] = fractal_gentrade3(resstruct,code,idx,freq)

if strcmpi(freq,'30m')
    nfractal = 4;
    tickratio = 0.5;
elseif strcmpi(freq,'15m')
    nfractal = 4;
    tickratio = 0.5;
elseif strcmpi(freq,'5m')
    nfractal = 6;
    tickratio = 0;
elseif strcmpi(freq,'1440m') || strcmpi(freq,'daily')
    nfractal = 2;
    tickratio = 1;
else
    nfractal = 4;
    tickratio = 0.5;
end

fut = code2instrument(code);

idx_ = idx-1;
try
    ei_ = fractal_truncate(resstruct,idx_);
catch
    trade = [];
    return
end

[condsignal,condop,condflags] = fractal_signal_conditional(ei_,tickratio*fut.tick_size,nfractal,'uselastcandle',true);
ei = fractal_truncate(resstruct,idx);
[uncondsignal,uncondop,uncondstatus] = fractal_signal_unconditional(ei,tickratio*fut.tick_size,nfractal);

%
if isempty(condsignal) && isempty(uncondsignal)
    trade = [];
    return
end
%
%
if isempty(condsignal) && ~isempty(uncondsignal)
    if uncondstatus.istrendconfirmed
        %here in case there were no trended conditional signal
        trade = [];
    else
        trade = fractal_gentrade(resstruct,code,idx,uncondop.comment,uncondop.direction,freq);
    end
    return
end
%
%
if ~isempty(condsignal) && isempty(uncondsignal)
    %conditional trade might be generated
    return
end
%
%
if ~isempty(condsignal) && ~isempty(uncondsignal)
    return
end