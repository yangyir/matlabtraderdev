function [ret] = kellyempirical2(varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Table','',@istable);
    p.addParameter('AssetName','',@ischar);
    p.addParameter('Direction','',@ischar);
    p.addParameter('SignalName','',@ischar);
    p.parse(varargin{:});
    
    tblInput = p.Results.Table;
    asset = p.Results.AssetName;
    directionstr = p.Results.Direction;
    if strcmpi(directionstr,'l') || strcmpi(directionstr,'long')
        direction = 1;
    elseif strcmpi(directionstr,'s') || strcmpi(directionstr,'short')
        direction = -1;
    else
        fprintf('kellyempirical:invalid direction input');
    end
    signal = p.Results.SignalName;
    
    if ~strcmpi(asset,'all')
        idx2check = tblInput.direction == direction & ...
            strcmpi(tblInput.assetname,asset) &...
            strcmpi(tblInput.opensignal,signal);
    else
        idx2check = tblInput.direction == direction & ...
            strcmpi(tblInput.opensignal,signal);
    end
    
    tblOut = tblInput(idx2check,:);
    
    [winp_running,R_running,kelly_running] = calcrunningkelly(tblOut.pnlrel);
    N = size(tblOut.pnlrel,1);
    if N == 0
        W = NaN;
        R = NaN;
        K = NaN;
    else
        W = winp_running(end);
        R = R_running(end);
        K = kelly_running(end);
    end
    
    ret = struct('N',N,'W',W,'R',R,'K',K);
end