function [] = savemktdata(obj,varargin)
%note cOps doesn't save mktdata
%     variablenotused(obj);
    if strcmpi(obj.mode_,'replay'), return; end
    if strcmpi(obj.mode_,'demo'), return;end

    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    t = p.Results.Time;
    
    counter = obj.getcounter;
    if counter.is_Counter_Login
        counter.logout;
        fprintf('cOps:log off %s on %s......\n',counter.char,datestr(t,'yyyy-mm-dd HH:MM:SS'));
    end
    
end