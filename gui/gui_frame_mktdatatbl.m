function [handles] = gui_frame_mktdatatbl(handles,ui_frame,varargin)
    variablenotused(ui_frame);
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code',{},@iscell);
    p.parse(varargin{:});
    code = p.Results.code;
    
    panelbox = handles.mktdatatbl.panelbox;
    refdate = getlastbusinessdate;
    
    if isempty(code)
        try
            futs = cDataFileIO.loadDataFromTxtFile([getenv('DATAPATH'),'activefutures\activefutures_',datestr(refdate,'yyyymmdd'),'.txt']);
        catch
            refdate = businessdate(refdate,-1);
            futs = cDataFileIO.loadDataFromTxtFile([getenv('DATAPATH'),'activefutures\activefutures_',datestr(refdate,'yyyymmdd'),'.txt']);
        end
    else
        futs = code;
    end
    
    nfuts = size(futs,1);
    %table will centred with 1.5% distance 2 each side of the panel
    positionTblX = 0.015;
    mktdataTblW = 1-2*positionTblX;
    mktdataTblH = 1-2*positionTblX;
    mktdataTblY = (1-mktdataTblH)/2;

%     columnnames = {'last trade','bid','ask','update time','last close','change','highest','lowest','wlpr'};
    columnnames = {'last trade','bid','ask','update time','last close','change','wr','max','min','bs','ss','levelup','leveldn','macd','sig'};
    handles.mktdatatbl.table  = uitable('Parent', panelbox, 'Units', 'Normalized', ...
        'Position', [positionTblX mktdataTblY mktdataTblW mktdataTblH], 'FontSize' , 8 , 'FontWeight' ,'bold', ...
        'Data', num2cell(ones(nfuts, length(columnnames))*NaN), 'ColumnWidth', {80 80 80 100 80 80 80 80 80 80 80 80 80 80 80}, 'BackgroundColor', [1 1 0.8;1 1 1],...
        'RowName',futs,...
        'ColumnName',columnnames);
    handles.instruments2trade = futs;
end