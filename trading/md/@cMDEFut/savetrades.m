function [] = savetrades(obj,varargin)
%note:cMDEFut doesn't save trades
%     variablenotused(obj);
% the trades are saved between 15:15pm and 15:25pm, when we can disconnect
% the MDE
    if obj.qms_.isconnect
        obj.logoff;
    end
    
end