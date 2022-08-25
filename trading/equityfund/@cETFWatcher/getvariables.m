function [res] = getvariables(obj,varargin)
% a cETFWatcher method
% to get private variables of an underlying
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('Code','',@ischar);
p.parse(varargin{:});
codein = p.Results.Code;

res = {};
foundflag = false;
    
n_index = size(obj.codes_index_,1);
n_sector = size(obj.codes_sector_,1);
n_stock = size(obj.codes_stock_,1);

for i = 1:n_index
    if strcmpi(codein,obj.codes_index_{i}(1:end-3)) || strcmpi(codein,obj.codes_index_{i})
        foundflag = true;
        if isempty(obj.pos_index_{i})
            pos = NaN;
        else
            pos = obj.pos_index_{i};
        end
        res = struct('position',pos,...
            'ei_d',obj.dailybarstruct_index_{i},...
            'ei_i',obj.intradaybarstruct_index_{i},...
            'cb_d',obj.dailybarriers_conditional_index_(i,:),...
            'cb_i',obj.intradaybarriers_conditional_index_(i,:),...
            'status_d',obj.dailystatus_index_(i));
        break
    end
end

if ~foundflag
    for i = 1:n_sector
        if strcmpi(codein,obj.codes_sector_{i}(1:end-3)) || strcmpi(codein,obj.codes_sector_{i})
            foundflag = true;
            if isempty(obj.pos_sector_{i})
                pos = NaN;
            else
                pos = obj.pos_sector_{i};
            end
            res = struct('position',pos,...
                'ei_d',obj.dailybarstruct_sector_{i},...
                'ei_i',obj.intradaybarstruct_sector_{i},...
                'cb_d',obj.dailybarriers_conditional_sector_(i,:),...
                'cb_i',obj.intradaybarriers_conditional_sector_(i,:),...
                'status_d',obj.dailystatus_sector_(i));
            break
        end
    end
end
%
if ~foundflag
    for i = 1:n_stock
        if strcmpi(codein,obj.codes_stock_{i}(1:end-3)) || strcmpi(codein,obj.codes_stock_{i})
            foundflag = true;
            if isempty(obj.pos_stock_{i})
                pos = NaN;
            else
                pos = obj.pos_stock_{i};
            end
            res = struct('position',pos,...
                'ei_d',obj.dailybarstruct_stock_{i},...
                'ei_i',obj.intradaybarstruct_stock_{i},...
                'cb_d',obj.dailybarriers_conditional_stock_(i,:),...
                'cb_i',obj.intradaybarriers_conditional_stock_(i,:),...
                'status_d',obj.dailystatus_stock_(i));
            break
        end
    end
end
%
if ~foundflag
    warning('cETFWatcher:getvariables:code not registed with etf watcher'); 
end

end