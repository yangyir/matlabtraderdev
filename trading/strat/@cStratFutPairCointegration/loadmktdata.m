function [] = loadmktdata(obj,varargin)
    fprintf('%s:loadmktdata:%s\n',class(obj),datestr(now,'yyyymmdd HH:MM:SS'));
%     fprintf('haha,we are here!\n');
%     if isempty(obj.data_)
%         combos.strategy.initdata;
%     else
%         
%     end
    obj.initdata;
end