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
            if ~isempty(obj.mdefut_)
                ismarketopen = sum(obj.mdefut_.ismarketopen('time',obj.replay_time1_));
            else
                if ~isempty(obj.mdeopt_)
                    ismarketopen = obj.mdeopt_.ismarketopen('time',obj.replay_time1_);
                else
                    ismarketopen = 0;
                end
            end
        else
            if ~isempty(obj.mdefut_)
                ismarketopen = sum(obj.mdefut_.ismarketopen('time',time));
            else
                if ~isempty(obj.mdeopt_)
                    ismarketopen = obj.mdeopt_.ismarketopen('time',time);
                else
                    ismarketopen = 0;
                end
            end
        end
        try
            if ismarketopen
                if ~isempty(obj.mdefut_)
                    obj.printrunningpnl('mdefut',obj.mdefut_);
                else
                    obj.printrunningpnl('mdeopt',obj.mdeopt_);
                end
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