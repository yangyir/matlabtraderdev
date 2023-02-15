function [dailystruct,intradaystruct] = showfigures(obj,varargin)
%cAShareWindIndustries
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Code','',@ischar);
    p.parse(varargin{:});
    code2plot = p.Results.Code;
    
    n_index = size(obj.codes_index_,1);
    
    foundflag = false;
    for i = 1:n_index
        if strcmpi(code2plot,obj.codes_index_{i}(1:end-3)) || strcmpi(code2plot,obj.codes_index_{i})
            foundflag = true;
            dailybarmat_ = obj.dailybarmat_index_{i};
            idx1 = find(dailybarmat_(:,1)>=datenum(dateadd(dailybarmat_(end,1),'-6m')),1,'first');
            tools_technicalplot2(dailybarmat_(idx1:end,:),2,[obj.codes_index_{i},'-',obj.names_index_{i}],true,0.02);    
            dailystruct = obj.dailybarstruct_index_{i};
            break
        end
    end
    %
    if ~foundflag
        warning('cAShareWindIndustries:showfigure:code not registed...');
        dailystruct = {};
        intradaystruct = {};
    end
    
end