function [] = printmarket(obj,varargin)
%cAShareWindIndustries
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.addParameter('SortByChange',false,@islogical);
    p.parse(varargin{:});
    tnum = p.Results.Time;
    tstr = datestr(tnum,'yyyy-mm-dd HH:MM:SS');
    sortbychange = p.Results.SortByChange;
  
    dataformat = '%10s %10.2f %10.2f %8.2f%% %11s %10.2f %10.2f %4s %4s %10.2f %10.2f %10.2f %10.2f %10.2f %10s %10s\n';
    n_index = size(obj.codes_index_,1);
    output_tbl = cell(n_index,16);
    for i = 1:n_index
        output_tbl{i,1} = obj.codes_index_{i};
        output_tbl{i,2} = obj.dailybarmat_index_{i}(end,5);
        output_tbl{i,3} =  obj.dailybarmat_index_{i}(end-1,5);
        output_tbl{i,4} = (output_tbl{i,2}/output_tbl{i,3}-1)*100;
        output_tbl{i,5} = datestr(tnum,'HH:MM:SS');
        output_tbl{i,6} = obj.dailybarstruct_index_{i}.hh(end);
        output_tbl{i,7} = obj.dailybarstruct_index_{i}.ll(end);
        output_tbl{i,8} = obj.dailybarstruct_index_{i}.bs(end);
        output_tbl{i,9} = obj.dailybarstruct_index_{i}.ss(end);
        output_tbl{i,10} = obj.dailybarstruct_index_{i}.lvlup(end);
        output_tbl{i,11} = obj.dailybarstruct_index_{i}.lvldn(end);
        output_tbl{i,12} = obj.dailybarstruct_index_{i}.teeth(end);
        output_tbl{i,13} = obj.dailybarstruct_index_{i}.lips(end);
        if ~isnan(obj.dailybarriers_conditional_index_(i,1))
            barrier = obj.dailybarriers_conditional_index_(i,1);
        elseif ~isnan(obj.dailybarriers_conditional_index_(i,2))
            barrier = obj.dailybarriers_conditional_index_(i,2);
        else
            barrier = NaN;
        end
        output_tbl{i,14} = barrier;
        output_tbl{i,15} = obj.dailystatus_index_(i);
        output_tbl{i,16} = obj.names_index_{i};
    end
    
    if sortbychange
        output_tbl = sortrows(output_tbl,4,'descend');
    end
    
    fprintf('\nlatest market quotes of indices on %s:\n',tstr);
    fprintf('%10s %10s %10s %9s %11s %10s %10s %4s %4s %10s %10s %10s %10s %10s %10s %10s\n',...
        'code','latest','preclose','change','Ktime','hh','ll','bs','ss','levelup','leveldn','teeth','lips','barrier','status-d','name');
    for i = 1:n_index            
        fprintf(dataformat,...
            output_tbl{i,1},...
            output_tbl{i,2},...
            output_tbl{i,3},...
            output_tbl{i,4},...
            output_tbl{i,5},...
            output_tbl{i,6},...
            output_tbl{i,7},...
            num2str(output_tbl{i,8}),...
            num2str(output_tbl{i,9}),...
            output_tbl{i,10},...
            output_tbl{i,11},...
            output_tbl{i,12},...
            output_tbl{i,13},...
            output_tbl{i,14},...
            num2str(output_tbl{i,15}),....
            output_tbl{i,16});
    end    
end