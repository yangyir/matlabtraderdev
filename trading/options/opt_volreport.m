function [output] = opt_volreport(code_underlier,cobdate,varargin)
    hd_underlier = cDataFileIO.loadDataFromTxtFile([code_underlier,'_daily.txt']);
    if ischar(cobdate),cobdate = datenum(cobdate);end
    
    spot = hd_underlier(hd_underlier(:,1) == cobdate,5);
    if isempty(spot)
        fprintf('%s price not saved on %s\n',code_underlier,datestr(cobdate,'yyyy-mm-dd'));
        output = [];
        return
    end
end