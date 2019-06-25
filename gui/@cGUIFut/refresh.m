function [] = refresh(obj,varargin)
    %
    % update table
    plotinput = obj.refreshtbl;
    %
    % update plot
    if ~isempty(plotinput)
        refreshplot(obj,'input',plotinput);
    end
end