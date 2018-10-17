function [ret] = setavailablefund(obj,val,varargin)
%cStrat
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('firstset',false,@islogical);
    p.parse(varargin{:});
    firstset = p.Results.firstset;

    if strcmpi(obj.mode_,'realtime')
        %the available fund cannot breach the available fund of the account
        try
            c = obj.helper_.getcounter;
            info = c.queryAccount;
            availabefundfromcounter = info.available_fund;
            if val > availabefundfromcounter
                fprintf('insufficient fund!\n');
                ret = 0;
                return
            end
            obj.availablefund_ = val;
            if firstset
                obj.preequity_ = val;
            end
            ret = 1;
        catch e
            fprintf('%s\n',e.message);
            ret = 0;
        end
    elseif strcmpi(obj.mode_,'replay')
        obj.availablefund_ = val;
        if firstset
            obj.preequity_ = val;
        end
        ret = 1;
    end
end