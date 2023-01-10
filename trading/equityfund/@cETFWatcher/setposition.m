function [] = setposition(obj,varargin)
% a cETFWatcher method
% to set position of an underlying
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Code','',@ischar);
    p.addParameter('Position',[],...
        @(x) validateattributes(x,{'struct','cTradeOpen'},{},'','Position'));
   
    p.parse(varargin{:});
    code = p.Results.Code;
    pos = p.Results.Position;
    
    n_index = size(obj.codes_index_,1);
    n_sector = size(obj.codes_sector_,1);
    n_stock = size(obj.codes_stock_,1);
    
    foundflag = false;
    
    for i = 1:n_index
        if strcmpi(code,obj.codes_index_{i}(1:end-3)) || strcmpi(code,obj.codes_index_{i})
            if strcmpi(pos.code_,code)
                foundflag = true;
                obj.pos_index_{i} = pos;
                obj.dailystatus_index_(i)= pos.opendirection_;
                break
            else
                error('cETFWatcher:setposition:invaid input:code and position mismatch')
            end
        end
    end
    
    if ~foundflag
        for i = 1:n_sector
            if strcmpi(code,obj.codes_sector_{i}(1:end-3)) || strcmpi(code,obj.codes_sector_{i})
                if strcmpi(pos.code_,code)
                    foundflag = true;
                    obj.pos_sector_{i} = pos;
                    obj.dailystatus_sector_(i)= pos.opendirection_;
                    break
                end
            else
                error('cETFWatcher:setposition:invaid input:code and position mismatch')
            end
        end
    end
    %
    if ~foundflag
        for i = 1:n_stock
            if strcmpi(code,obj.codes_stock_{i}(1:end-3)) || strcmpi(code,obj.codes_stock_{i})
                if strcmpi(pos.code_,code)
                    foundflag = true;
                    obj.pos_stock_{i} = pos;
                    obj.dailystatus_stock_(i)= pos.opendirection_;
                    break
                end
            else
                error('cETFWatcher:setposition:invaid input:code and position mismatch')
            end
        end
    end
    %
    if ~foundflag
        warning('cETFWatcher:setposition:code not registed with etf watcher'); 
    end
    
end