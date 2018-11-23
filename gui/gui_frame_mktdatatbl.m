function [handles] = gui_frame_mktdatatbl(handles,ui_frame)
    variablenotused(ui_frame);

    panelbox = handles.mktdatatbl.panelbox;
    refdate = getlastbusinessdate;
    try
        activefuts = cDataFileIO.loadDataFromTxtFile([getenv('DATAPATH'),'activefutures\activefutures_',datestr(refdate,'yyyymmdd'),'.txt']);
    catch
        refdate = businessdate(refdate,-1);
        activefuts = cDataFileIO.loadDataFromTxtFile([getenv('DATAPATH'),'activefutures\activefutures_',datestr(refdate,'yyyymmdd'),'.txt']);
    end
    
    nfuts = size(activefuts,1);
    %table will centred with 1.5% distance 2 each side of the panel
    positionTblX = 0.015;
    mktdataTblW = 1-2*positionTblX;
    mktdataTblH = 1-2*positionTblX;
    mktdataTblY = (1-mktdataTblH)/2;

    columnnames = {'last trade','bid','ask','update time','last close','change','highest','lowest','wlpr'};
    handles.mktdatatbl.table  = uitable('Parent', panelbox, 'Units', 'Normalized', ...
        'Position', [positionTblX mktdataTblY mktdataTblW mktdataTblH], 'FontSize' , 8 , 'FontWeight' ,'bold', ...
        'Data', num2cell(ones(nfuts, length(columnnames))*NaN), 'ColumnWidth', {80 80 80 100 80 80 80 80 80}, 'BackgroundColor', [1 1 0.8;1 1 1],...
        'RowName',activefuts,...
        'ColumnName',columnnames);
    handles.instruments2trade = activefuts;
end