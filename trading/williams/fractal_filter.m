function [tblb1,tbls1,trades,resmat,resstruct] = fractal_filter(codes,data_intraday,filterstr,direction,doplot)
if length(codes) ~= size(data_intraday,1)
    error('fractal_filter:invalid codes and data_intraday inputs')
end

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
    error('fractal_filter:invalid filterstr input')
end

if ~(direction == 1 || direction == -1)
    error('fractal_filter:invalid direction input')
end

if nargin < 5
    doplot = 0;
end

n = length(codes);
resmat = cell(n,1);
resstruct = cell(n,1);
idxb1 = cell(n,1);
idxs1 = cell(n,1);
% commentsb1 = cell(n,1);
tblb1 = cell(n,1);
tbls1 = cell(n,1);
% nfractal = 4;

trades = cTradeOpenArray;

iplot = 0;
for i = 1:n
    if strcmpi(codes{i},'510300')
        instrument = codes{i};
        ticksize = 0.001;
    elseif strcmpi(codes{i},'gzhy')
        instrument = codes{i};
        ticksize = 0.0001;%1bp
    else
        try
            instrument = code2instrument(codes{i});
            ticksize = instrument.tick_size;
        catch
            ticksize = 0;
        end
    end
    p = data_intraday{i};
    if p(2,1) - p(1,1) < 1
        freqstr = '30m';
        nfractal = 4;
    else
        freqstr = 'daily';
        nfractal = 2;
        if strcmpi(codes{i},'gzhy')
            nfractal = 4;
        end
    end
    [resmat{i},resstruct{i}] = tools_technicalplot1(p,nfractal,0,'volatilityperiod',0,'tolerance',0);
    [idxb1{i},idxs1{i}] = fractal_genindicators1(resstruct{i}.px,...
        resstruct{i}.hh,resstruct{i}.ll,...
        resstruct{i}.jaw,resstruct{i}.teeth,resstruct{i}.lips,...
        'instrument',instrument);
    
    nb_i = size(idxb1{i},1);ns_i = size(idxs1{i},1);
    nabovelips1_i = zeros(nb_i,1);nbelowlips1_i = zeros(ns_i,1);
    naboveteeth1_i = zeros(nb_i,1);nbelowteeth1_i = zeros(ns_i,1);
    nabovelips2_i = zeros(nb_i,1);nbelowlips2_i = zeros(ns_i,1);
    nkaboveteeth2_i = zeros(nb_i,1);nkbelowteeth2_i = zeros(ns_i,1);
    nkfromhh_i = zeros(nb_i,1);nkfromll_i = zeros(ns_i,1);
    teethjawcrossed_b_i = zeros(nb_i,1);teethjawcrossed_s_i = zeros(ns_i,1);
    useflagb_i = zeros(nb_i,1);useflags_i = zeros(ns_i,1);
    commentsb1_i = cell(nb_i,3);commentss1_i = cell(ns_i,3);
    for j = 1:nb_i
        %double check whether the open price on the next candle is still valid
        %for a breach as per trading code
        k = idxb1{i}(j,1);
        b1type = idxb1{i}(j,2);
        extrainfo = fractal_genextrainfo(resstruct{i},k);
        [nabovelips1_i(j),naboveteeth1_i(j),nabovelips2_i(j),nkaboveteeth2_i(j),nkfromhh_i(j),teethjawcrossed_b_i(j)] = fractal_countb(p(1:k,:),extrainfo.idxhh,nfractal,extrainfo.lips,extrainfo.teeth,extrainfo.jaw,ticksize);
        op = fractal_filterb1_singleentry(b1type,nfractal,extrainfo,ticksize);
        status = fractal_b1_status(nfractal,extrainfo,ticksize);
        commentsb1_i{j,3} = fractal_b1_status2str(status);
        commentsb1_i{j,2} = op.comment;
        useflagb_i(j) = op.use;
        
        if k == size(p,1), continue;end
        
        if p(k+1,2) < resstruct{i}.hh(k)
            commentsb1_i{j,1} = 'breachb1 break:next open below HH';
            useflagb_i(j) = 0;
            continue
        end
        if p(k,5) <= p(k,3)-0.382*(p(k,3)-resstruct{i}.ll(k))
            commentsb1_i{j,1} = 'breachb1 break:below initial stoploss';
            useflagb_i(j) = 0;
            continue
        end
%         if p(k,5) > resstruct{i}.hh(k)+1.618*(resstruct{i}.hh(k)-resstruct{i}.ll(k))
%             commentsb1_i{j,1} = 'breachb1 break:above initial target';
%             useflagb_i(j) = 0;
%             continue
%         end
        if p(k+1,2) < resstruct{i}.lips(k)
            commentsb1_i{j,1} = 'breachb1 break:next open below lips';
            useflagb_i(j) = 0;
            continue
        end
%         if p(k,5) - resstruct{i}.hh(k) < 2*instrument.tick_size
%             commentsb1_i{j,1} = 'breachb1 break:close less than 2 ticks above HH';
%             useflagb_i(j) = 0;
%             continue
%         end
        if p(k+1,2) - resstruct{i}.hh(k) < 0 && k ~= size(p,1)
            commentsb1_i{j,1} = 'breachb1 break:open less than  HH';
            useflagb_i(j) = 0;
            continue
        end
        
        if (strcmpi(op.comment,filterstr) || strcmpi(filterstr,'all')) && direction == 1
            iplot = iplot + 1;
            for jj = k:size(p,1)
                if p(jj,5)-resstruct{i}.teeth(jj) < -2*ticksize
                    break
                end
            end
            if doplot
                if strcmpi(op.comment,'breachup-highsc13') || strcmpi(op.comment,'breachup-highsc13-negative')
                    lastsc13 = find(extrainfo.sc(1:k) == 13,1,'last');
                    tools_technicalplot2(resmat{i}(min(lastsc13,k-nkfromhh_i(j)+1):jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                elseif strcmpi(op.comment,'breachup-sshighvalue')
                    lastss9 = find(extrainfo.ss(1:k) == 9,1,'last');
                    tools_technicalplot2(resmat{i}(min(lastss9-8,k-nkfromhh_i(j)+1):jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                else
                    tools_technicalplot2(resmat{i}(k-max(9,nkfromhh_i(j))+1:jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                end
            end
            trade = fractal_gentrade(resstruct{i},codes{i},k,op.comment,1,freqstr);
            trades.push(trade);
        end
        
    end
    idx = idxb1{i}(:,1);
    breachtype = idxb1{i}(:,2);
    nabovelips1 = nabovelips1_i;
    naboveteeth1 = naboveteeth1_i;
    nabovelips2 = nabovelips2_i;
    nkaboveteeth2 = nkaboveteeth2_i;
    nkfromhh = nkfromhh_i;
    teethjawcrossed = teethjawcrossed_b_i;
    useflag = useflagb_i;
    commentsb1 = commentsb1_i(:,1);
    commentsb2 = commentsb1_i(:,2);
    commentsb3 = commentsb1_i(:,3);
    tblb1{i,1} = table(idx,breachtype,nabovelips1,naboveteeth1,nabovelips2,nkaboveteeth2,nkfromhh,teethjawcrossed,useflag,commentsb1,commentsb2,commentsb3);
    %
    %
    for j = 1:ns_i
        %double check whether the open price on the next candle is still valid
        %for a breach as per trading code
        k = idxs1{i}(j,1);
        s1type = idxs1{i}(j,2);
        extrainfo = fractal_genextrainfo(resstruct{i},k);
        [nbelowlips1_i(j),nbelowteeth1_i(j),nbelowlips2_i(j),nkbelowteeth2_i(j),nkfromll_i(j),teethjawcrossed_s_i(j)] = fractal_counts(p(1:k,:),extrainfo.idxll,nfractal,extrainfo.lips,extrainfo.teeth,extrainfo.jaw,ticksize);
        op = fractal_filters1_singleentry(s1type,nfractal,extrainfo,ticksize);
        status = fractal_s1_status(nfractal,extrainfo,ticksize);
        commentss1_i{j,3} = fractal_s1_status2str(status);
        commentss1_i{j,2} = op.comment;
        useflags_i(j) = op.use;
        
        if k == size(p,1), continue;end
        if p(k+1,2) >  resstruct{i}.ll(k)
            commentss1_i{j,1} = 'breach break:next open above LL';
            useflags_i(j) = 0;
            continue;
        end
        if p(k,5) >= p(k,4)+0.382*(resstruct{i}.hh(k)-p(k,4))
            commentss1_i{j,1} = 'breach break:above initial stoploss';
            useflags_i(j) = 0;
            continue;
        end
%         if p(k,5) < resstruct{i}.ll(k)-1.618*(resstruct{i}.hh(k)-resstruct{i}.ll(k))
%             commentss1_i{j,1} = 'breach break:below initial target';
%             useflags_i(j) = 0;
%             continue;
%         end
%         if p(k,5) - resstruct{i}.ll(k) > -2*instrument.tick_size
%             commentss1_i{j,1} = 'breach break:close less than 2 ticks below LL';
%             useflags_i(j) = 0;
%             continue;
%         end
        if p(k+1,2) - resstruct{i}.ll(k) > 0
            commentss1_i{j,1} = 'breach break:open above LL';
            useflags_i(j) = 0;
            continue;
        end
        
        if (strcmpi(op.comment,filterstr) || strcmpi(filterstr,'all')) && direction == -1
            iplot = iplot + 1;
            for jj = k:size(p,1)
                if p(jj,5)-resstruct{i}.teeth(jj) > 2*ticksize
                    break
                end
            end
            if doplot
                if strcmpi(op.comment,'breachdn-lowbc13')
                    lastbc13 = find(extrainfo.bc(1:k) == 13,1,'last');
                    tools_technicalplot2(resmat{i}(min(lastbc13,k-nkfromll_i(j)+1):jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                elseif strcmpi(op.comment,'breachdn-bshighvalue')
                    lastbs9 = find(extrainfo.bs(1:k) == 9,1,'last');
                    tools_technicalplot2(resmat{i}(min(lastbs9-8,k-nkfromll_i(j)+1):jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                else
                    tools_technicalplot2(resmat{i}(k-max(9,nkfromll_i(j))+1:jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                end
            end
            trade = fractal_gentrade(resstruct{i},codes{i},k,op.comment,-1,freqstr);
            trades.push(trade);
        end
        
    end
    idx = idxs1{i}(:,1);
    breachtype = idxs1{i}(:,2);
    nbelowlips1 = nbelowlips1_i;
    nbelowteeth1 = nbelowteeth1_i;
    nbelowlips2 = nbelowlips2_i;
    nkbelowteeth2 = nkbelowteeth2_i;
    nkfromll = nkfromll_i;
    teethjawcrossed = teethjawcrossed_s_i;
    useflags = useflags_i;
    commentss1 = commentss1_i(:,1);
    commentss2 = commentss1_i(:,2);
    commentss3 = commentss1_i(:,3);
    tbls1{i,1} = table(idx,breachtype,nbelowlips1,nbelowteeth1,nbelowlips2,nkbelowteeth2,nkfromll,teethjawcrossed,useflags,commentss1,commentss2,commentss3);
end
    




    
    
end
