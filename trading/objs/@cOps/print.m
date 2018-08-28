function [] = print(obj,varargin)
    if ~obj.printflag_, return; end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    time = p.Results.Time;
    
    if strcmpi(obj.status_,'sleep')
        fprintf('%s:ops sleeps......\n',datestr(time,'yyyy-mm-dd HH:MM:SS'));
    elseif strcmpi(obj.status_,'working')
        try
            obj.printrunningpnl('mdefut',obj.mdefut_);
        catch e
            fprintf('error:cOps:printrunningpnl:%s\n',e.message);
        end
        %
        try
            obj.printallentrusts;
        catch e
            fprintf('error:cOps:printpendingentrusts:%s\n',e.message);
        end
    end
    
end