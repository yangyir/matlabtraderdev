function [handles] = gui_frame_mktdataops(handles,ui_frame,buttonnames,buttontags)
%
    variablenotused(ui_frame);
    panelbox = handles.mktdataops.panelbox;
    
    % buttons are 60% height of the panel centre in the middle and 80% width
    nButtons = size(buttonnames,1);
    buttonH = 0.6;
    button2buttonH = (1-0.8)/(nButtons+1);
    buttonW = 0.8/nButtons;
    buttonY = (1-buttonH)/2;
    buttonFontSize = 8;
    for i = 1:nButtons  
        buttonX_i = i*button2buttonH + (i-1)*buttonW;
        handles.mktdataops.(buttontags{i})   = uicontrol('Parent', panelbox, 'style', 'pushbutton', ...
            'Backgroundcolor', 'k', 'Foregroundcolor', 'r', 'String', buttonnames{i}, ...
            'Units', 'Normalized', ...
            'Position', [buttonX_i buttonY buttonW buttonH], 'FontSize', buttonFontSize, ...
            'FontWeight', 'bold');
    end
end