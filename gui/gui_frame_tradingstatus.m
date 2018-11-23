function [handles] = gui_frame_tradingstatus(handles,ui_frame,propnames,propvalues)
    textboxCount = size(propnames,1);
    
    box2LeftPanel = 3*ui_frame.panel2LeftFrame;
    box2RightPanel = 3*ui_frame.panel2RightFrame;
    box2TopPanel = 1*ui_frame.panel2TopFrame;
    box2BottomPanel = 1*ui_frame.panel2BottomFrame;
    box2boxH = 2*ui_frame.panel2panelH;
    box2boxV = 3*ui_frame.panel2panelV;
    boxFontSize = 8;
    
    textboxX = box2LeftPanel;
    textboxW = (1-box2LeftPanel-box2RightPanel-box2boxH)/2;
    textboxH = (1-box2TopPanel-box2BottomPanel-(textboxCount-1)*box2boxV)/textboxCount;
    
    panelbox = handles.tradingstats.panelbox;
    
    for i = 1:textboxCount
        %on the left hand-side
        textboxname = [lower(propnames{i}),'_text'];
        textboxPosY = 1-box2TopPanel-i*textboxH-(i-1)*box2boxV;
        handles.tradingstats.(textboxname) = uicontrol('Parent', panelbox, 'style', 'text', ...
        'Foregroundcolor', 'k','String', propnames{i}, 'Units', 'Normalized',... 
        'Position', [textboxX textboxPosY textboxW textboxH],... 
        'FontSize', boxFontSize, ...
        'FontWeight', 'bold');
        % 
%         if strcmpi(propnames{i},'PreInterest') || strcmpi(propnames{i},'AvailableFund')
%             editstr = num2str(startupfund);
%         elseif strcmpi(propnames{i},'CurrentMargin') || strcmpi(propnames{i},'FrozenMargin') ...
%                 || strcmpi(propnames{i},'RunningPnL') || strcmpi(propnames{i},'ClosedPnL')
%             editstr = '0';
%         elseif strcmpi(propnames{i},'Time')
%             editstr = datestr(now,'dd/mmm HH:MM:SS');
%         end

        editboxname = [lower(propnames{i}),'_edit'];
        editboxPositionY = textboxPosY;
        editboxPositionX = textboxX + textboxW + box2boxH;
        handles.tradingstats.(editboxname) = uicontrol('Parent', panelbox, 'style', 'edit', ...
            'Backgroundcolor', 'w', 'Foregroundcolor', 'b', 'String', propvalues{i}, ...
            'Units', 'Normalized',...
            'Position', [editboxPositionX editboxPositionY textboxW textboxH], ...
            'FontSize', boxFontSize, ...
            'FontWeight', 'bold');
    end
end