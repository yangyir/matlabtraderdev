function flag = fractal_isbreachb(px,HH,LL,jaw,teeth,lips,varargin)
    variablenotused(LL);
    variablenotused(lips);
    %sanity check
    if length(px) ~= length(HH) || ...
            length(px) ~= length(LL) || ...
            length(px) ~= length(jaw) || ...
            length(px) ~= length(teeth) || ...
            length(px) ~= length(lips)
        error('fractal_isbreachb:size of input variables mismatch')
    end
    p = inputParser;p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('level','medium',@ischar);
    p.addParameter('instrument',[],@(x)validateattributes(x,{'cInstrument','char'},{},'','instrument'));
    p.parse(varargin{:});
    level = p.Results.level;
    instrument = p.Results.instrument;
    if ~(strcmpi(level,'weak') || strcmpi(level,'medium') || strcmpi(level,'strong'))
        error('fractal_isbreachb:invalid level input')
    end
    if isempty(instrument)
        ticksize = 0;
    else
        if isa(instrument,'cInstrument')
            ticksize = instrument.tick_size;
        elseif ischar(instrument)
            [isequity,equitytype] = isinequitypool(instrument);
            if isequity
                if equitytype == 1 || equitytype == 2 
                    ticksize = 0.001;
                else
                    ticksize = 0.01;
                end
            else
                ticksize = 0;
            end
        else
            error('fractal_isbreachb:invalid instrument input')
        end
    end
    
    flag = (px(1:end-1,5)<=HH(1:end-1)&px(2:end,5)-HH(1:end-1)>=ticksize) &...
        abs(HH(1:end-1)./HH(2:end)-1) < 0.002 &...
        px(2:end,3)>lips(2:end) &...
        ~isnan(lips(1:end-1)) & ~isnan(teeth(1:end-1)) & ~isnan(jaw(1:end-1));
%         ~(lips(2:end)<teeth(2:end) & teeth(2:end)<jaw(2:end));
    if strcmpi(level,'weak')
        %in the weak level:
        %just need 1)price breach HH and 2)HH doesn't jump on that point
        flag = flag & ~(HH(2:end) < lips(2:end) & lips(2:end)<teeth(2:end) & teeth(2:end)<jaw(2:end));
        flag = [0;flag];
        return
    end
    %
    if strcmpi(level,'medium')
        %in the medium level we require an additional condition,i.e.
        %HH shall above alligator's teeth
        flag = flag & (HH(2:end) - teeth(2:end)>-ticksize);
        flag = [0;flag];
        return
    end
    %
    if strcmpi(level,'strong')
        %in the strong level we require alligator's teeth is above
        %alligator's jaw
        flag = flag & (HH(2:end) - teeth(2:end)>-ticksize) & ...
            teeth(2:end) > jaw(2:end);
        flag = [0;flag];
        return
    end

end