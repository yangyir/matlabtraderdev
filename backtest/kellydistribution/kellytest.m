function [resOut] = kellytest(tblInput,modeInput,directionInput,doPlot) 
% kelly utility function
% to test whether winning,odds rates and kelly are stable, i.e. followed a
% normal distribution as sample size goes larger
%
if nargin < 4
    doPlot = 0;
end

n = size(tblInput,1);
%idx_breachuplvlup_tc is for conditional entrust placement as the fractal
%barrier is above or equal to the TDSQ lvlup
idx_breachuplvlup_tc = tblInput.direction == 1 & ...
    tblInput.trendflag == 1 & ...
    tblInput.barrierfractal >= tblInput.barriertdsq & ...
    ~isnan(tblInput.barriertdsq) & ...
    strcmpi(tblInput.opensignal,'breachup-lvlup');
%
idx_breachuplvlup_tc_all = tblInput.direction == 1 & ...
    tblInput.trendflag == 1 & ...
    strcmpi(tblInput.opensignal,'breachup-lvlup');
%
idx_breachuplvlup_tb = tblInput.direction == 1 & ...
    tblInput.trendflag == 0 & ...
    strcmpi(tblInput.opensignal,'breachup-lvlup');
%idx_breachdnlvldn_tc is for conditional entrust placement as the fractal
%barrier is below or equal to the TDSQ lvldn 
idx_breachdnlvldn_tc = tblInput.direction == -1 & ...
    tblInput.trendflag == 1 & ...
    tblInput.barrierfractal <= tblInput.barriertdsq & ...
    ~isnan(tblInput.barriertdsq) & ...
    strcmpi(tblInput.opensignal,'breachdn-lvldn');
%
idx_breachdnlvldn_tc_all = tblInput.direction == -1 & ...
    tblInput.trendflag == 1 & ...
    strcmpi(tblInput.opensignal,'breachdn-lvldn');
%
idx_breachdnlvldn_tb = tblInput.direction == -1 & ...
    tblInput.trendflag == 0 & ...
    strcmpi(tblInput.opensignal,'breachdn-lvldn');
%
idx_breachupsshighvalue_tc = tblInput.direction == 1 & ...
    tblInput.trendflag == 1 & ...
    strcmpi(tblInput.opensignal,'breachup-sshighvalue');
%
idx_breachupsshighvalue_tb = tblInput.direction == 1 & ...
    tblInput.trendflag == 0 & ...
    strcmpi(tblInput.opensignal,'breachup-sshighvalue');
%
idx_breachdnbshighvalue_tc = tblInput.direction == -1 & ...
    tblInput.trendflag == 1 & ...
    strcmpi(tblInput.opensignal,'breachdn-bshighvalue');
%
idx_breachdnbshighvalue_tb = tblInput.direction == -1 & ...
    tblInput.trendflag == 0 & ...
    strcmpi(tblInput.opensignal,'breachdn-bshighvalue');
%
idx_breachuphighsc13 = tblInput.direction == 1 & ...
    tblInput.trendflag == 1 & ...
    strcmpi(tblInput.opensignal,'breachup-highsc13');
%
idx_breachdnlowbc13 = tblInput.direction == -1 & ...
    tblInput.trendflag == 1 & ...
    strcmpi(tblInput.opensignal,'breachdn-lowbc13');
%
idx_bmtc = tblInput.direction == 1 & ...
    tblInput.trendflag == 1 & ...
    tblInput.opentype == 2 & ...
    ~idx_breachuplvlup_tc & ...
    ~idx_breachupsshighvalue_tc & ...
    ~idx_breachuphighsc13;
%
idx_bstc = tblInput.direction == 1 & ...
    tblInput.trendflag == 1 & ...
    tblInput.opentype == 3 & ...
    ~idx_breachuplvlup_tc & ...
    ~idx_breachupsshighvalue_tc & ...
    ~idx_breachuphighsc13;
%
idx_smtc = tblInput.direction == -1 & ...
    tblInput.trendflag == 1 & ...
    tblInput.opentype == 2 & ...
    ~idx_breachdnlvldn_tc & ...
    ~idx_breachdnbshighvalue_tc & ...
    ~idx_breachdnlowbc13;
%
idx_sstc = tblInput.direction == -1 & ...
    tblInput.trendflag == 1 & ...
    tblInput.opentype == 3 & ...
    ~idx_breachdnlvldn_tc & ...
    ~idx_breachdnbshighvalue_tc & ...
    ~idx_breachdnlowbc13;
%
if strcmpi(modeInput,'breachup-lvlup-tc')
    tblOut = tblInput(idx_breachuplvlup_tc,:);
elseif strcmpi(modeInput,'breachup-lvlup-tc-all')
    tblOut = tblInput(idx_breachuplvlup_tc_all,:);
elseif strcmpi(modeInput,'breachup-lvlup-tb')
    tblOut = tblInput(idx_breachuplvlup_tb,:);
elseif strcmpi(modeInput,'breachdn-lvldn-tc')
    tblOut = tblInput(idx_breachdnlvldn_tc,:);
elseif strcmpi(modeInput,'breachdn-lvldn-tc-all')
    tblOut = tblInput(idx_breachdnlvldn_tc_all,:);
elseif strcmpi(modeInput,'breachdn-lvldn-tb')
    tblOut = tblInput(idx_breachdnlvldn_tb,:);
elseif strcmpi(modeInput,'breachup-sshighvalue-tc')
    tblOut = tblInput(idx_breachupsshighvalue_tc,:);
elseif strcmpi(modeInput,'breachup-sshighvalue-tb')
    tblOut = tblInput(idx_breachupsshighvalue_tb,:);
elseif strcmpi(modeInput,'breachdn-bshighvalue-tc')
    tblOut = tblInput(idx_breachdnbshighvalue_tc,:);
elseif strcmpi(modeInput,'breachdn-bshighvalue-tb')
    tblOut = tblInput(idx_breachdnbshighvalue_tb,:);
elseif strcmpi(modeInput,'breachup-highsc13')
    tblOut = tblInput(idx_breachuphighsc13,:);
elseif strcmpi(modeInput,'breachdn-lowbc13')
    tblOut = tblInput(idx_breachdnlowbc13,:);
elseif strcmpi(modeInput,'bmtc')
    tblOut = tblInput(idx_bmtc,:);
elseif strcmpi(modeInput,'bstc')
    tblOut = tblInput(idx_bstc,:);
elseif strcmpi(modeInput,'smtc')
    tblOut = tblInput(idx_smtc,:);
elseif strcmpi(modeInput,'sstc')
    tblOut = tblInput(idx_sstc,:);
else
    idx2check = tblInput.direction == directionInput & ...
        strcmpi(tblInput.opensignal,modeInput);
    tblOut = tblInput(idx2check,:);
end
%
pnl2check = tblOut.pnlrel;
nRecords = size(pnl2check,1);
if nRecords <= 15
    wMu = NaN;wSigma = NaN;wH = NaN;
    rMu = NaN;rSigma = NaN;rH = NaN;
    kMu = NaN;kSigma = NaN;kH = NaN;
    [winp_running,R_running,kelly_running] = calcrunningkelly(tblOut.pnlrel);
    if nRecords <= 8
        if ~isempty(strfind(modeInput,'bcreverse')) || ...
                ~isempty(strfind(modeInput,'screverse')) || ...
                ~isempty(strfind(modeInput,'bsreverse')) || ...
                ~isempty(strfind(modeInput,'ssreverse')) || ...
                ~isempty(strfind(modeInput,'bsbcdoublereverse')) || ...
                ~isempty(strfind(modeInput,'ssscdoublereverse')) || ...
                ~isempty(strfind(modeInput,'sshighbreach')) || ...
                ~isempty(strfind(modeInput,'bslowbreach'))
            if kelly_running(end) >= 0.166 && winp_running(end) >= 0.5 && R_running(end) >= 1.5
                useOut = 1;
            else
                useOut = 0;
            end
        else
            useOut = 0;
        end
    else
        if kelly_running(end) >= 0.2 && winp_running(end) >= 0.5
            useOut = 1;
        else
            if kelly_running(end) >= 0.166 && winp_running(end) >= 0.5 && R_running(end) >= 1.5
                useOut = 1;
            else
                useOut = 0;
            end
        end
    end
    
    resOut = struct('use',useOut,...
        'wMu',wMu,'wSigma',wSigma,'wH',wH,...
        'rMu',rMu,'rSigma',rSigma,'rH',rH,...
        'kMu',kMu,'kSigma',kSigma,'kH',kH,...
        'sigmalmode',modeInput,'direction',directionInput,...
        'tblout',tblOut,...
        'wSample',winp_running(end),...
        'rSample',R_running(end),...
        'kSample',kelly_running(end));
else
    nTrials = 200;
    rng(100);
    if nRecords > 50
        nSample = ceil(nRecords/5);
    else
        nSample = ceil(nRecords/2);
    end
    wTrials = zeros(nTrials,1);
    rTrials = zeros(nTrials,1);
    kTrials = zeros(nTrials,1);
    for i = 1:nTrials
        idxRand = randperm(nRecords,nSample);
        temp = pnl2check(idxRand);
        [w,r,k] = calcrunningkelly(temp);
        wTrials(i) = w(end);
        rTrials(i) = r(end);
        if k(end) == -inf
            kTrials(i) = -9.99;
        else
            kTrials(i) = k(end);
        end
    end
    
    try
        wH = kstest((wTrials-mean(wTrials))/std(wTrials));
    catch
        wH = 1;
    end
    [wMu,wSigma] = normfit(wTrials,0.05);
    try
        rH = kstest((rTrials-mean(rTrials))/std(rTrials));
    catch
        rH = 1;
    end
    [rMu,rSigma] = normfit(rTrials,0.05);
    try
        kH = kstest((kTrials-mean(kTrials))/std(kTrials));
    catch
        kH = 1;
    end
    [kMu,kSigma] = normfit(kTrials,0.05);
    
    [winp_running,R_running,kelly_running] = calcrunningkelly(tblOut.pnlrel);
    
    if (kMu >= 0.145 || (kMu > 0.1 && wMu > 0.4))
        if kH == 0
            useOut = 1;
        else
            if kelly_running(end) >= 0.145
                useOut = 1;
            else
                useOut = 0;
            end
        end
    else
        if kelly_running(end) >= 0.145 && winp_running(end) >= 0.45 && R_running(end) > 1
            useOut = 1;
        else
            useOut = 0;
        end
    end
    
    if strcmpi(modeInput,'breachup-lvlup') || ...
            strcmpi(modeInput,'breachup-highsc13') || ...
            strcmpi(modeInput,'breachup-sshighvalue') || ...
            strcmpi(modeInput,'breachdn-lvldn') || ...
            strcmpi(modeInput,'breachdn-lowbc13') || ...
            strcmpi(modeInput,'breachdn-bshighvalue')
        %special modes and kelly is calculated seperately
        if kelly_running(end) > 0
            useOut = 1;
        else
            useOut = 0;
        end
    end
    
    
    resOut = struct('use',useOut,...
        'wMu',wMu,'wSigma',wSigma,'wH',wH,...
        'rMu',rMu,'rSigma',rSigma,'rH',rH,...
        'kMu',kMu,'kSigma',kSigma,'kH',kH,...
        'sigmalmode',modeInput,'direction',directionInput,...
        'tblout',tblOut,...
        'wSample',winp_running(end),...
        'rSample',R_running(end),...
        'kSample',kelly_running(end));
    
end

if doPlot
    close all;
    set(0,'defaultfigurewindowstyle','docked');
    
    figure(2);
    subplot(311);plot(winp_running,'r');title(modeInput);ylabel('winning rates');grid on;
    subplot(312);plot(R_running,'b');ylabel('odds rates');grid on;
    subplot(313);plot(kelly_running,'g');xlabel('number of trades');ylabel('kelly criteria');grid on;
end
    
    
