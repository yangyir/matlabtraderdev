function [ret] = kellyempirical(varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Distribution','',@isstruct);
    p.addParameter('AssetName','',@ischar);
    p.addParameter('Direction','',@ischar);
    p.addParameter('SignalName','',@ischar);
    p.parse(varargin{:});
    
    distributionstruct = p.Results.Distribution;
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
     
    if direction == 1
        vlookuptbl = distributionstruct.kellyb;
        assetcolumn = vlookuptbl.Asset_L;
        signalcolumn = vlookuptbl.OpenSignal_L;
    else
        vlookuptbl = distributionstruct.kellys;
        assetcolumn = vlookuptbl.Asset_S;
        signalcolumn = vlookuptbl.OpenSignal_S;
    end
    assetidx = strcmpi(assetcolumn,asset);
    signalidx = strcmpi(signalcolumn,signal);
    idx = assetidx & signalidx;
    tbl = vlookuptbl(idx,:);
    if direction == 1
        ntrades = sum(cell2mat(tbl.NumOfTrades_L));
        nwintrades = sum(cell2mat(tbl.NumOfTrades_L).*cell2mat(tbl.WinProb_L));
        winavgpnl = sum(cell2mat(tbl.NumOfTrades_L).*cell2mat(tbl.WinProb_L).*cell2mat(tbl.WinAvgPnL_L))/nwintrades;
        lossavgpnl = sum(cell2mat(tbl.NumOfTrades_L).*(1-cell2mat(tbl.WinProb_L)).*cell2mat(tbl.LossAvgPnL_L))/(ntrades-nwintrades);
    else
        ntrades = sum(cell2mat(tbl.NumOfTrades_S));
        nwintrades = sum(cell2mat(tbl.NumOfTrades_S).*cell2mat(tbl.WinProb_S));
        winavgpnl = sum(cell2mat(tbl.NumOfTrades_S).*cell2mat(tbl.WinProb_S).*cell2mat(tbl.WinAvgPnL_S))/nwintrades;
        lossavgpnl = sum(cell2mat(tbl.NumOfTrades_S).*(1-cell2mat(tbl.WinProb_S)).*cell2mat(tbl.LossAvgPnL_S))/(ntrades-nwintrades);
    end
    W = nwintrades/ntrades;
    if W == 1
        R = 9.99;
    else
        R = abs(winavgpnl/lossavgpnl);
    end
    K = W - (1-W)/R;
    
    %tbl2 is based on all assets
    if direction == 1
        vlookuptbl2 = distributionstruct.kellyb_unique;
        idx = strcmpi(vlookuptbl2.opensignal_l_unique,signal);
        W2 = vlookuptbl2.winprob_unique_l(idx);
        R2 = vlookuptbl2.r_unique_l(idx);
        K2 = vlookuptbl2.kelly_unique_l(idx);
    else
        vlookuptbl2 = distributionstruct.kellys_unique;
        idx = strcmpi(vlookuptbl2.opensignal_s_unique,signal);
        W2 = vlookuptbl2.winprob_unique_s(idx);
        R2 = vlookuptbl2.r_unique_s(idx);
        K2 = vlookuptbl2.kelly_unique_s(idx);
    end
    
    ret = struct('W',W,'R',R,'K',K,'W2',W2,'R2',R2,'K2',K2);
    


end

