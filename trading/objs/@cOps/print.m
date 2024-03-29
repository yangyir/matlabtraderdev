function [] = print(obj,varargin)
%cOps
    if ~obj.printflag_, return; end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    time = p.Results.Time;
    
    if strcmpi(obj.status_,'sleep')
        fprintf('%s:ops sleeps......\n',datestr(time,'yyyy-mm-dd HH:MM:SS'));
    elseif strcmpi(obj.status_,'working')
        if strcmpi(obj.mode_,'replay')
            ismarketopen = sum(obj.mdefut_.ismarketopen('time',obj.replay_time1_));
        else
            ismarketopen = sum(obj.mdefut_.ismarketopen('time',time));
        end
        try
            if ismarketopen
                obj.printrunningpnl('mdefut',obj.mdefut_);
            end
        catch e
            fprintf('error:cOps:printrunningpnl:%s\n',e.message);
        end
        %
        try
            if ismarketopen
                obj.printpendingentrusts;
            end
        catch e
            fprintf('error:cOps:printpendingentrusts:%s\n',e.message);
        end
    end
    
end