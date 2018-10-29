function [ret,e,msg] = condlongclose(strategy,code_ctp,lots,closetodayFlag,varargin)
    variablenotused(code_ctp);
    variablenotused(lots);
    variablenotused(closetodayFlag);
    ret = 0;
    e = [];
    msg = sprintf('%s:condlongclose not implemented yet\...',class(strategy));
end