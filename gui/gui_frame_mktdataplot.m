function [handles] = gui_frame_mktdataplot(handles,ui_frame)
    variablenotused(ui_frame);
    %
    panelbox = handles.mktdataplot.panelbox;
    
    %the plot ara will be 85% height of the panel and 3% from left and right
    mktdataPlotAxesX = 0.03;
    mktdataPlotAxesW = 1-2*mktdataPlotAxesX;
    mktdataPlotAxesH = 0.85;
    mktdataPlotAxesY = (1-mktdataPlotAxesH)/2;
    handles.mktdataplot.axes  = axes('Parent', panelbox, 'Units', 'Normalized', ...
        'Position', [mktdataPlotAxesX mktdataPlotAxesY mktdataPlotAxesW mktdataPlotAxesH], ...
        'FontSize', 8, 'FontWeight', 'bold');
    % popup menu
    boxBackGroundColor = [0.8 1 0.8];
    mktdataPlotPopupmenuX = mktdataPlotAxesX;
    mktdataPlotPopupmenuW = 0.15;
    mktdataPlotPopupmenuH = 0.9*(1-mktdataPlotAxesH-mktdataPlotAxesY);
    mktdataPlotPopupmenuY = mktdataPlotAxesH + mktdataPlotAxesY;
    handles.mktdataplot.popupmenu  = uicontrol('Parent', panelbox, 'style', 'popupmenu', ...
        'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', handles.instruments2trade, 'Units', 'Normalized', ...
                'Position', [mktdataPlotPopupmenuX mktdataPlotPopupmenuY mktdataPlotPopupmenuW mktdataPlotPopupmenuH], 'FontSize', 8, ...
                'FontWeight', 'bold');
    handles.mktdataplot.flag = false;
    
end