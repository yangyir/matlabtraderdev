function [tblb1,trades,resmat,resstruct] = fractal_filter_etf(code,datainput,nfractal,filterstr,direction,doplot)

    if ~(strcmpi(filterstr,'breachup-lvlup') || ...
            strcmpi(filterstr,'breachup-lvldn') || ...
            strcmpi(filterstr,'breachup-highsc13') || ...
            strcmpi(filterstr,'breachup-highsc13-negative') || ...
            strcmpi(filterstr,'breachdn-lowbc13') || ...
            strcmpi(filterstr,'breachdn-lvldn') || ...
            strcmpi(filterstr,'breachdn-lvlup') || ...
            strcmpi(filterstr,'volblowup') || ...
            strcmpi(filterstr,'volblowup-alligatorfailed') || ...
            strcmpi(filterstr,'volblowup2-alligatorfailed') || ...
            strcmpi(filterstr,'volblowup2') || ...
            strcmpi(filterstr,'volblowup2-ss1') || ...
            strcmpi(filterstr,'volblowup2-bs1') || ...
            strcmpi(filterstr,'strongbreach-trendbreak') ||...
            strcmpi(filterstr,'strongbreach-trendconfirmed') ||...
            strcmpi(filterstr,'strongbreach-sshighvalue') ||...
            strcmpi(filterstr,'strongbreach-bshighvalue') ||...
            strcmpi(filterstr,'breachup-sshighvalue') ||...
            strcmpi(filterstr,'mediumbreach-trendbreak') ||...
            strcmpi(filterstr,'mediumbreach-trendconfirmed') ||...
            strcmpi(filterstr,'mediumbreach-sshighvalue') ||...
            strcmpi(filterstr,'mediumbreach-bshighvalue') ||...
            strcmpi(filterstr,'teethjawcrossed') || ...
            strcmpi(filterstr,'breachdn-bshighvalue') ||...
            strcmpi(filterstr,'closetolvlup') ||...
            strcmpi(filterstr,'closetolvldn') ||...
            strcmpi(filterstr,'weakbreach') || ...
            strcmpi(filterstr,'sc13') || ...
            strcmpi(filterstr,'bc13') || ...
            strcmpi(filterstr,'all')) 
        error('fractal_filter_etf:invalid filterstr input')
    end

    if ~(direction == 1)
        error('fractal_filter_etf:invalid direction input')
    end

    if nargin < 5
        doplot = 0;
    end

    trades = cTradeOpenArray;

    ticksize = 0.001;

    iplot = 0;

    
    p = datainput;
    
    if p(2,1) - p(1,1) < 1
        freqstr = '30m';
    else
        freqstr = 'daily';
    end
    
    [resmat,resstruct] = tools_technicalplot1(p,nfractal,0,'volatilityperiod',0,'tolerance',0);
    [idxb1,~ ]= fractal_genindicators1(resstruct.px,...
        resstruct.hh,resstruct.ll,...
        resstruct.jaw,resstruct.teeth,resstruct.lips,...
        'instrument','510300');
    
    nb = size(idxb1,1);
    nabovelips1 = zeros(nb,1);
    naboveteeth1 = zeros(nb,1);
    nabovelips2 = zeros(nb,1);
    nkaboveteeth2 = zeros(nb,1);
    nkfromhh = zeros(nb,1);
    teethjawcrossed = zeros(nb,1);
    useflagb = zeros(nb,1);
    commentsb1 = cell(nb,3);
    for j = 1:nb
        %double check whether the open price on the next candle is still valid
        %for a breach as per trading code
        k = idxb1(j,1);
        b1type = idxb1(j,2);
        extrainfo = fractal_genextrainfo(resstruct,k);
        [nabovelips1(j),naboveteeth1(j),nabovelips2(j),nkaboveteeth2(j),nkfromhh(j),teethjawcrossed(j)] = fractal_countb(p(1:k,:),extrainfo.idxhh,nfractal,extrainfo.lips,extrainfo.teeth,extrainfo.jaw,ticksize);
        op = fractal_filterb1_singleentry(b1type,nfractal,extrainfo,ticksize);
        status = fractal_b1_status(nfractal,extrainfo,ticksize);
        commentsb1{j,3} = fractal_b1_status2str(status);
        commentsb1{j,2} = op.comment;
        useflagb(j) = op.use;
        
        if k == size(p,1), continue;end
        
        if p(k+1,2) < resstruct.hh(k)
            commentsb1{j,1} = 'breachb1 break:next open below HH';
            useflagb(j) = 0;
            continue
        end
        if p(k,5) <= p(k,3)-0.382*(p(k,3)-resstruct.ll(k))
            commentsb1{j,1} = 'breachb1 break:below initial stoploss';
            useflagb(j) = 0;
            continue
        end
%         if p(k,5) > resstruct{i}.hh(k)+1.618*(resstruct{i}.hh(k)-resstruct{i}.ll(k))
%             commentsb1_i{j,1} = 'breachb1 break:above initial target';
%             useflagb_i(j) = 0;
%             continue
%         end
        if p(k+1,2) < resstruct.lips(k)
            commentsb1{j,1} = 'breachb1 break:next open below lips';
            useflagb(j) = 0;
            continue
        end
%         if p(k,5) - resstruct{i}.hh(k) < 2*instrument.tick_size
%             commentsb1_i{j,1} = 'breachb1 break:close less than 2 ticks above HH';
%             useflagb_i(j) = 0;
%             continue
%         end
        if p(k+1,2) - resstruct.hh(k) < 0 && k ~= size(p,1)
            commentsb1{j,1} = 'breachb1 break:open less than  HH';
            useflagb(j) = 0;
            continue
        end
        
        if (strcmpi(op.comment,filterstr) || strcmpi(filterstr,'all')) && direction == 1
            iplot = iplot + 1;
            for jj = k:size(p,1)
                if p(jj,5)-resstruct.teeth(jj) < -2*ticksize
                    break
                end
            end
            if doplot
                if strcmpi(op.comment,'breachup-highsc13') || strcmpi(op.comment,'breachup-highsc13-negative')
                    lastsc13 = find(extrainfo.sc(1:k) == 13,1,'last');
                    tools_technicalplot2(resmat(min(lastsc13,k-nkfromhh(j)+1):jj,:),iplot,[code,'-',num2str(k),'-',filterstr]);
                elseif strcmpi(op.comment,'breachup-sshighvalue')
                    lastss9 = find(extrainfo.ss(1:k) == 9,1,'last');
                    tools_technicalplot2(resmat(min(lastss9-8,k-nkfromhh(j)+1):jj,:),iplot,[code,'-',num2str(k),'-',filterstr]);
                else
                    tools_technicalplot2(resmat(k-max(9,nkfromhh(j))+1:jj,:),iplot,[code,'-',num2str(k),'-',filterstr]);
                end
            end
            trade = fractal_gentrade(resstruct,code,k,op.comment,1,freqstr);
            trades.push(trade);
        end
        
    end
    idx = idxb1(:,1);
    breachtype = idxb1(:,2);
    useflag = useflagb;
    comments1 = commentsb1(:,1);
    comments2 = commentsb1(:,2);
    comments3 = commentsb1(:,3);
    tblb1 = table(idx,breachtype,nabovelips1,naboveteeth1,nabovelips2,nkaboveteeth2,nkfromhh,teethjawcrossed,useflag,comments1,comments2,comments3);
    %
    %    
end
