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
    p.parse(varargin{:});
    level = p.Results.level;
    if ~(strcmpi(level,'weak') || strcmpi(level,'medium') || strcmpi(level,'strong'))
        error('fractal_isbreachs:invalid level input')
    end
    
    flag = (px(1:end-1,5)>LL(1:end-1)&px(2:end,5)<LL(1:end-1)) &...
        LL(1:end-1) == LL(2:end) &...
        px(2:end,4)<lips(2:end) &...
        ~isnan(lips(1:end-1)) & ~isnan(teeth(1:end-1)) & ~isnan(jaw(1:end-1));
%         ~(lips(2:end)>teeth(2:end) & teeth(2:end)>jaw(2:end));
    if strcmpi(level,'weak')
        %in the weak level:
        %just need 1)price breach LL and 2)LL doesn't jump on that point 
        flag = [0;flag];
        return
    end
    %
    if strcmpi(level,'medium')
        %in the medium level we require an additional condition,i.e.
        %LL shall below alligator's teeth
        flag = flag & LL(1:end-1) < teeth(1:end-1);
        flag = [0;flag];
        return
    end
    %
    if strcmpi(level,'strong')
        %in the strong level we require alligator's teeth is below
        %alligator's jaw
        flag = flag & LL(1:end-1) < teeth(1:end-1) & ...
            teeth(1:end-1) < jaw(1:end-1);
        flag = [0;flag];
        return
    end

end