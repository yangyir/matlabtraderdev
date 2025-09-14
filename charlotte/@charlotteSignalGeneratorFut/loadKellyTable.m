function [] = loadKellyTable(obj,varargin)
    % a charlotteSignalGenerator function
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('frequency','',@ischar);
    p.addParameter('foldername','',@ischar);
    p.addParameter('filename','',@ischar);
    p.parse(varargin{:});
    freq = p.Results.frequency;
    if ~(strcmpi(freq,'m1') || strcmpi(freq,'1m') || ...
            strcmpi(freq,'m5') || strcmpi(freq,'5m') || ...
            strcmpi(freq,'m15') || strcmpi(freq,'15m') || ...
            strcmpi(freq,'m30') || strcmpi(freq,'30m') || ...
            strcmpi(freq,'d1') || strcmpi(freq,'daily'))
        error('%s:loadKellyTable:invalid frequency input:%s....',class(obj),freq)
    end
    
    foldername = p.Results.foldername;
    if strcmpi(foldername(end),'\')
        foldername = [foldername,'\'];
    end
    
    filename = p.Results.filename;
    
    data = load([foldername,filename]);
    propname = filename(1:end-4);
    kellytable = data.(propname);
    
    if strcmpi(freq,'m1') || strcmpi(freq,'1m')
        obj.kellytable_m1_ = kellytable;
    elseif strcmpi(freq,'m5') || strcmpi(freq,'5m')
        obj.kellytable_m5_ = kellytable;
    elseif strcmpi(freq,'m15') || strcmpi(freq,'15m')
        obj.kellytable_m15_ = kellytable;
    elseif strcmpi(freq,'m30') || strcmpi(freq,'30m')
        obj.kellytable_m30_ = kellytable;
    elseif strcmpi(freq,'d1') || strcmpi(freq,'daily')
        obj.kellytable_d1_ = kellytable;
    end
        
end