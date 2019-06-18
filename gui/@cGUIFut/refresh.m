function [] = refresh(obj,varargin)
    %
    % update table
    plotinput = obj.refreshtbl;
    %
    % update plot
    refreshplot(obj,'input',plotinput);
end