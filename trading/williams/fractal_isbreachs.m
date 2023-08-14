function flag = fractal_isbreachs(px,HH,LL,jaw,teeth,lips,varargin)
    variablenotused(HH);
    variablenotused(lips);
    %sanity check
    if length(px) ~= length(LL) || ...
            length(px) ~= length(LL) || ...
            length(px) ~= length(jaw) || ...
            length(px) ~= length(teeth) || ...
            length(px) ~= length(lips)
        error('fractal_isbreachs:size of input variables mismatch')
    end
    p = inputParser;p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('level','medium',@ischar);
    p.addParameter('instrument',[],@(x)validateattributes(x,{'cInstrument','char'},{},'','instrument'));
    p.parse(varargin{:});
    level = p.Results.level;
    instrument = p.Results.instrument;
    if ~(strcmpi(level,'weak') || strcmpi(level,'medium') || strcmpi(level,'strong'))
        error('fractal_isbreachs:invalid level input')
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
            elseif strcmpi(instrument,'audusd') || strcmpi(instrument,'eurusd') || strcmpi(instrument,'gbpusd') || ...
                strcmpi(instrument,'usdcad') || strcmpi(instrument,'usdchf') || strcmpi(instrument,'eurchf') || ...
                strcmpi(instrument,'gbpeur') || strcmpi(instrument,'usdcnh')
                ticksize = 0.0001;
            elseif strcmpi(instrument,'usdjpy') || strcmpi(instrument,'eurjpy') || strcmpi(instrument,'gbpjpy') || strcmpi(instrument,'audjpy') ||...
                    strcmpi(instrument,'usdx')
                ticksize = 0.01;
            else
                ticksize = 0;
            end
        else
            error('fractal_isbreachs:invalid instrument input')
        end
    end
    
    flag = (px(1:end-1,5)>=LL(1:end-1)&(px(2:end,5)-LL(1:end-1)<=-ticksize)) &...
        abs(LL(1:end-1)./LL(2:end)-1)<0.002 &...
        px(2:end,4)<lips(2:end) &...
        ~isnan(lips(1:end-1)) & ~isnan(teeth(1:end-1)) & ~isnan(jaw(1:end-1));
%         ~(lips(2:end)>teeth(2:end) & teeth(2:end)>jaw(2:end));
    if strcmpi(level,'weak')
        %in the weak level:
        %just need 1)price breach LL and 2)LL doesn't jump on that point
        flag = flag & ~(LL(2:end) > lips(2:end) & lips(2:end)>teeth(2:end) & teeth(2:end)>jaw(2:end));
        flag = [0;flag];
        return
    end
    %
    if strcmpi(level,'medium')
        %in the medium level we require an additional condition,i.e.
        %LL shall below alligator's teeth
        flag = flag & (LL(2:end) - teeth(2:end)<ticksize);
        flag = [0;flag];
        return
    end
    %
    if strcmpi(level,'strong')
        %in the strong level we require alligator's teeth is below
        %alligator's jaw
        flag = flag & (LL(2:end) - teeth(2:end)<ticksize) & ...
            teeth(2:end) < jaw(2:end);
        flag = [0;flag];
        return
    end

end