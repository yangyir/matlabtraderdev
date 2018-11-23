function [handles] = gui_frame_generalsetup(handles,ui_frame,propnames,propvalues)

    panelbox = handles.generalsetup.panelbox;
    %note: in the general set up panelbox, we will have 'Static Text' on the
    %left hand side and 'Edit Text' and popup-menu on the right hand side
    box2LeftPanel = 3*ui_frame.panel2LeftFrame;
    box2RightPanel = 3*ui_frame.panel2RightFrame;
    box2TopPanel = 2*ui_frame.panel2TopFrame;
    box2BottomPanel = 2*ui_frame.panel2BottomFrame;
    box2boxH = 4*ui_frame.panel2panelH;
    box2boxV = 4*ui_frame.panel2panelV;
    boxFontSize = 8;
    boxBackGroundColor = [0.8 1 0.8];
    textboxNames = propnames;
    textboxCount = size(textboxNames,1);
    %
    textboxX = box2LeftPanel;
    textboxW = (1-box2LeftPanel-box2RightPanel-box2boxH)/2;
    textboxH = (1-box2TopPanel-box2BottomPanel-(textboxCount-1)*box2boxV)/textboxCount;

    for i = 1:textboxCount
        %on the left hand-side
        textboxname = [lower(textboxNames{i}),'_text'];
        textboxPosY = 1-box2TopPanel-i*textboxH-(i-1)*box2boxV;
        handles.generalsetup.(textboxname) = uicontrol('Parent', panelbox, 'style', 'text', ...
        'Foregroundcolor', 'k','String', textboxNames{i}, 'Units', 'Normalized',... 
        'Position', [textboxX textboxPosY textboxW textboxH],... 
        'FontSize', boxFontSize, ...
        'FontWeight', 'bold');
        %
        val = propvalues{i};
        nval = length(val);
        if nval > 1
            popupmenuname = [lower(textboxNames{i}),'_popupmenu'];
            popupmenuPositionY = textboxPosY;
            popupmenuPositionX = textboxX + textboxW + box2boxH;
            handles.generalsetup.(popupmenuname) = uicontrol('Parent', panelbox, 'style', 'popupmenu', ...
                'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', val, ...
                'Units', 'Normalized', 'Position', [popupmenuPositionX popupmenuPositionY textboxW textboxH], 'FontSize', boxFontSize, ...
                'FontWeight', 'bold');
        else
            editboxname = [lower(textboxNames{i}),'_edit'];
            editboxPositionY = textboxPosY;
            editboxPositionX = textboxX + textboxW + box2boxH;
            handles.generalsetup.(editboxname) = uicontrol('Parent', panelbox, 'style', 'edit', ...
                'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', val, ...
                'Units', 'Normalized',...
                'Position', [editboxPositionX editboxPositionY textboxW textboxH], ...
                'FontSize', boxFontSize, ...
                'FontWeight', 'bold');
        end
    end
end