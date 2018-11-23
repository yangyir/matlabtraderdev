function handles = gui_frame_entrusts(handles,ui_frame)
    variablenotused(ui_frame);
    %
    tbbackcolor = [1 1 0.8;1 1 1];
    boxBackGroundColor = [0.8 1 0.8];
    panelbox = handles.entrusts.panelbox;
    %

    entrustTblX = 0.015;
    entrustTblW = 1-2*entrustTblX;
    entrustTblH = 0.9;
    entrustTblY = 0.01;
    nfuts = size(handles.instruments2trade,1);

    columnnames = {'id','instrument','direction',...
            'offset','status','price','volume','dealvolume','dealtime'};
    handles.entrusts.table = uitable('Parent', panelbox, 'Units', 'Normalized', ...
        'Position', [entrustTblX entrustTblY entrustTblW entrustTblH], 'FontSize' , 8 , 'FontWeight' ,'bold', ...
        'Data', num2cell(zeros(nfuts, length(columnnames))), 'ColumnWidth', num2cell(ones(1,5)*100), 'BackgroundColor', tbbackcolor,...
        'ColumnName',columnnames);
    %
    entrustPopupmenuX = entrustTblX;
    entrustPopupmenuW = 0.15;
    entrustPopupmenuH = 1-entrustTblH-entrustTblY-2*0.01;
    entrustPopupmenuY = entrustTblH + 2*entrustTblY;
    handles.entrusts.popupmenu  = uicontrol('Parent', panelbox, 'style', 'popupmenu', ...
            'Backgroundcolor', boxBackGroundColor, 'Foregroundcolor', 'b', 'String', {'all','pending','finished'}, 'Units', 'Normalized', ...
                    'Position', [entrustPopupmenuX entrustPopupmenuY entrustPopupmenuW entrustPopupmenuH], 'FontSize', 8, ...
                    'FontWeight', 'bold');

end