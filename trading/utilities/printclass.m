function [] = printclass(obj)
%this function print the information of the input obj which could either be
%a struct or class
try
    fls = fields(obj);
    for i = 1:size(fls,1)
        info = class(obj.(fls{i}));
        if strcmpi(info,'double')
            fprintf('%s:%4.1f; ',fls{i},obj.(fls{i}));
        elseif strcmpi(info,'cFutures')
            fprintf('%s:%s; ',fls{i},obj.(fls{i}).code_ctp);
        else
            fprintf('%s:%s; ',fls{i},obj.(fls{i}));
        end
    end
    fprintf('\n');
    
    
catch e
    fprintf([e.message,'\n']);
end
end