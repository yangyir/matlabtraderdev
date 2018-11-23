function [handles] = gui_frame_positions(handles,ui_frame)
    variablenotused(ui_frame);
    panelbox = handles.positions.panelbox;
    positionTblX = 0.015;
    positionTblW = 1-2*positionTblX;
    positionTblH = 1-2*positionTblX;
    entrustTblY = (1-positionTblH)/2;
    %
    tbbackcolor = [1 1 0.8;1 1 1];
    %
    nfuts = size(handles.instruments2trade,1);
    columnnames = {'direction','volume total','volume today','avg open price','running pnl','close pnl'};
    handles.positions.table  = uitable('Parent', panelbox, 'Units', 'Normalized', ...
        'Position', [positionTblX entrustTblY positionTblW positionTblH], 'FontSize' , 8 , 'FontWeight' ,'bold', ...
        'Data', num2cell(zeros(nfuts, length(columnnames))), 'ColumnWidth', num2cell(ones(1,5)*100), 'BackgroundColor', tbbackcolor,...
        'RowName',handles.instruments2trade,...
        'ColumnName',columnnames);
end