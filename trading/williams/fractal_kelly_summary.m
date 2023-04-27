function [output] = fractal_kelly_summary(varargin)
% to summary kelly criterion given list of codes and different open signals
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('codes',{},@iscell);
    p.addParameter('frequency','daily',@ischar);
    p.addParameter('usefractalupdate',1,@isnumeric);
    p.addParameter('usefibonacci',1,@isnumeric);
    p.addParameter('direction','both',@ischar);
    p.parse(varargin{:});

    codes = p.Results.codes;
    freq = p.Results.frequency;
    usefractalupdateflag = p.Results.usefractalupdate;
    usefibonacciflag = p.Results.usefibonacci;
    directionin = p.Results.direction;


    ncodes = length(codes);
    tblbcell = cell(ncodes,1);
    tblscell = cell(ncodes,1);
    tradesbcell = cell(ncodes,1);
    tradesscell = cell(ncodes,1);
    validtradesbcell = cell(ncodes,1);
    validtradesscell = cell(ncodes,1);
    kellybcell = cell(ncodes,1);
    kellyscell = cell(ncodes,1);
    datacell = cell(ncodes,1);
    % use parallel computing with local CPU here...
    parfor i = 1:ncodes
        [~,tblb_data,~,tbls_data,data,tradesb,tradess,validtradesb,validtradess,kellyb,kellys] = fractal_gettradesummary(codes{i},...
            'frequency',freq,...
            'usefractalupdate',usefractalupdateflag,...
            'usefibonacci',usefibonacciflag,...
            'direction',directionin);
        tblbcell{i} = tblb_data;
        tblscell{i} = tbls_data;
        datacell{i} = data;
        tradesbcell{i} = tradesb;
        tradesscell{i} = tradess;
        validtradesbcell{i} = validtradesb;
        validtradesscell{i} = validtradess;
        kellybcell{i} = kellyb;
        kellyscell{i} = kellys;
    end

    output.tblb = tblbcell;
    output.tbls = tblscell;
    output.data = datacell;
    output.tradesb = tradesbcell;
    output.tradess = tradesscell;
    output.validtradesb = validtradesbcell;
    output.validtradess = validtradesscell;
    
    output.kellys = kellyscell;

    % compute kelly ratio for each signal open mode
    for i = 1:ncodes
        if ~isempty(kellybcell{i})
            kellyb = kellybcell{i};
            if i == 1
                OpenSignal_L = kellyb.OpenSignal;
                NumOfTrades_L = kellyb.NumOfTrades;
                WinProb_L = kellyb.WinProb;
                WinAvgPnL_L = kellyb.WinAvgPnL;
                LossAvgPnL_L = kellyb.LossAvgPnL;
                KellyRatio_L = kellyb.KellyRatio;
                Code_L = kellyb.Code;
            else
                temp = [OpenSignal_L;kellyb.OpenSignal];OpenSignal_L = temp;
                temp = [NumOfTrades_L;kellyb.NumOfTrades];NumOfTrades_L = temp;
                temp = [WinProb_L;kellyb.WinProb];WinProb_L = temp;
                temp = [WinAvgPnL_L;kellyb.WinAvgPnL];WinAvgPnL_L = temp;
                temp = [LossAvgPnL_L;kellyb.LossAvgPnL];LossAvgPnL_L = temp;
                temp = [KellyRatio_L;kellyb.KellyRatio];KellyRatio_L = temp;
                temp = [Code_L;kellyb.Code];Code_L = temp;
            end
        end
        if ~isempty(kellyscell{i})
            kellys = kellyscell{i};
            if i == 1
                OpenSignal_S = kellys.OpenSignal;
                NumOfTrades_S = kellys.NumOfTrades;
                WinProb_S = kellys.WinProb;
                WinAvgPnL_S = kellys.WinAvgPnL;
                LossAvgPnL_S = kellys.LossAvgPnL;
                KellyRatio_S = kellys.KellyRatio;
                Code_S = kellys.Code;
            else
                temp = [OpenSignal_S;kellys.OpenSignal];OpenSignal_S = temp;
                temp = [NumOfTrades_S;kellys.NumOfTrades];NumOfTrades_S = temp;
                temp = [WinProb_S;kellys.WinProb];WinProb_S = temp;
                temp = [WinAvgPnL_S;kellys.WinAvgPnL];WinAvgPnL_S = temp;
                temp = [LossAvgPnL_S;kellys.LossAvgPnL];LossAvgPnL_S = temp;
                temp = [KellyRatio_S;kellys.KellyRatio];KellyRatio_S = temp;
                temp = [Code_S;kellys.Code];Code_S = temp;
            end
        end
    end
    % %
    if ~isempty(OpenSignal_L)
        kellyltbl = table(OpenSignal_L,NumOfTrades_L,WinProb_L,WinAvgPnL_L,LossAvgPnL_L,KellyRatio_L,Code_L);
        opensignal_l_unique = unique(OpenSignal_L);
        nunique_l = length(opensignal_l_unique);
        ntrades_unique_l = zeros(nunique_l,1);
        winprob_unique_l = zeros(nunique_l,1);
        winavgpnl_unique_l  = zeros(nunique_l,1);
        lossavgpnl_unique_l = zeros(nunique_l,1);
        kelly_unique_l = zeros(nunique_l,1);
        for i = 1:nunique_l
            this_mode = opensignal_l_unique{i};
            idx = strcmpi(OpenSignal_L,this_mode);
            ntrades = NumOfTrades_L(idx);ntrades = cell2mat(ntrades);
            winprobs = WinProb_L(idx);winprobs = cell2mat(winprobs);
            winavgpnls = WinAvgPnL_L(idx);winavgpnls = cell2mat(winavgpnls);
            lossavgpnls = LossAvgPnL_L(idx);lossavgpnls = cell2mat(lossavgpnls);
            %
            totaltrades = sum(ntrades);
            ntrades_unique_l(i) = totaltrades;
            wintrades = sum(ntrades.*winprobs);
            winprob =  wintrades/totaltrades;
            if wintrades ~= 0
                winavgpnl = sum(ntrades.*winprobs.*winavgpnls)/wintrades;
            else
                winavgpnl = 0;
            end
            if totaltrades > wintrades
                lossavgpnl = sum((ntrades-ntrades.*winprobs).*lossavgpnls)/(totaltrades-wintrades);
            else
                lossavgpnl = 0;
            end
            winprob_unique_l(i) = winprob;
            winavgpnl_unique_l(i) = winavgpnl;
            lossavgpnl_unique_l(i) = lossavgpnl;
            kelly_unique_l(i) = winprob - (1-winprob)/(abs(winavgpnl/lossavgpnl));
        end
        kellyltbl_unique = table(opensignal_l_unique,ntrades_unique_l,winprob_unique_l,winavgpnl_unique_l,lossavgpnl_unique_l,kelly_unique_l);
        output.kellyb = kellyltbl;
        output.kellyb_unique = kellyltbl_unique;
    end
    % %
    if ~isempty(OpenSignal_S)
        kellystbl = table(OpenSignal_S,NumOfTrades_S,WinProb_S,WinAvgPnL_S,LossAvgPnL_S,KellyRatio_S,Code_S);
        opensignal_s_unique = unique(OpenSignal_S);
        nunique_s = length(opensignal_s_unique);
        ntrades_unique_s = zeros(nunique_s,1);
        winprob_unique_s = zeros(nunique_s,1);
        winavgpnl_unique_s  = zeros(nunique_s,1);
        lossavgpnl_unique_s = zeros(nunique_s,1);
        kelly_unique_s = zeros(nunique_s,1);
        for i = 1:nunique_s
            this_mode = opensignal_s_unique{i};
            idx = strcmpi(OpenSignal_S,this_mode);
            ntrades = NumOfTrades_S(idx);ntrades = cell2mat(ntrades);
            winprobs = WinProb_S(idx);winprobs = cell2mat(winprobs);
            winavgpnls = WinAvgPnL_S(idx);winavgpnls = cell2mat(winavgpnls);
            lossavgpnls = LossAvgPnL_S(idx);lossavgpnls = cell2mat(lossavgpnls);
            %
            totaltrades = sum(ntrades);
            ntrades_unique_s(i) = totaltrades;
            wintrades = sum(ntrades.*winprobs);
            winprob =  wintrades/totaltrades;
            if wintrades ~= 0
                winavgpnl = sum(ntrades.*winprobs.*winavgpnls)/wintrades;
            else
                winavgpnl = 0;
            end
            if totaltrades > wintrades
                lossavgpnl = sum((ntrades-ntrades.*winprobs).*lossavgpnls)/(totaltrades-wintrades);
            else
                lossavgpnl = 0;
            end
            winprob_unique_s(i) = winprob;
            winavgpnl_unique_s(i) = winavgpnl;
            lossavgpnl_unique_s(i) = lossavgpnl;
            kelly_unique_s(i) = winprob - (1-winprob)/(abs(winavgpnl/lossavgpnl));
        end
        kellystbl_unique = table(opensignal_s_unique,ntrades_unique_s,winprob_unique_s,winavgpnl_unique_s,lossavgpnl_unique_s,kelly_unique_s);
        output.kellys = kellystbl;
        output.kellys_unique = kellystbl_unique;
    end

end