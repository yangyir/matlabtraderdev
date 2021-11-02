function [] = printsignal(obj,varargin)
%cETFWatcher
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Code','all',@ischar);
    p.parse(varargin{:});
    code2print = p.Results.Code;
    
    n_index = size(obj.codes_index_,1);
    n_sector = size(obj.codes_sector_,1);
    
    ticksize = 0.001;
    
    if strcmpi(code2print,'all')
        for i = 1:n_index
        end
        %
        for i = 1:n_sector
        end
        %
        return
    end
    %
    foundflag = false;
    for i = 1:n_index
        if strcmpi(code2print,obj.codes_index_{i}(1:end-3))
            foundflag = true;
            px = obj.intradaybarstruct_index_{i}.px;
            hh = obj.intradaybarstruct_index_{i}.hh;
            lips = obj.intradaybarstruct_index_{i}.lips;
            teeth = obj.intradaybarstruct_index_{i}.teeth;
            jaw = obj.intradaybarstruct_index_{i}.jaw;
            break
        end
    end
    
    if ~foundflag
        for i = 1:n_sector
            if strcmpi(code2print,obj.codes_sector_{i}(1:end-3))
                foundflag = true;
                
                break
        end
        end
    
    if ~foundflag
        warning('cETFWatcher:printsignal:input code not found......')
    end
    
    
    
    
end