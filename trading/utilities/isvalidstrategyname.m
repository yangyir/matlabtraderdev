function [ret] = isvalidstrategyname(stratname)
    if ~ischar(stratname)
        error('isvalidstrategyname:invalid input data type, char as expected')
    end
    
    if strcmpi(stratname,'wlpr') || ...
            strcmpi(stratname,'batman') || ...
            strcmpi(stratname,'wlprbatman') || ...
            strcmpi(stratname,'manual') || ...
            strcmpi(stratname,'pair') || ...
            strcmpi(stratname,'tdsq')
        % we can add more names going forward
        ret = true;
    else
        ret = false;
    end
        
end