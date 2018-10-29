function [ret,e,msg] = condshortclose(strategy,code_ctp,lots,closetodayFlag,varargin)
    variablenotused(code_ctp);
    variablenotused(lots);
    variablenotused(closetodayFlag);
    ret = 0;
    e = [];
    msg = sprintf('%s:condshortclose not implemented yet\...',class(strategy));
end
