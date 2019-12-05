function [] = savemktdata(obj,varargin)
%cMDEOptSimple
    %note:the mktdata is scheduled to be saved between 02:30am and 02:40am
    %on each trading date
    %we shall logoff the MD server after the mktdata is saved
    if strcmpi(obj.mode_,'realtime')
        if obj.qms_.isconnect
            obj.logoff;
            fprintf('cMDEOptSimple:logoff from MD on %s......\n',datestr(dtnum,'yyyy-mm-dd HH:MM:SS'));
        end
    end
end