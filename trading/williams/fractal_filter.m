function [tblb1,tbls1,trades,resmat,resstruct] = fractal_filter(codes,data_in,filterstr,direction,doplot,dt1,dt2)
if length(codes) ~= size(data_in,1)
    error('fractal_filter:invalid codes and data_intraday inputs')
end

if ~(fractal_isvalidstr(filterstr) || strcmpi(filterstr,'all')) 
    error('fractal_filter:invalid filterstr input')
end

if ~(direction == 1 || direction == -1)
    error('fractal_filter:invalid direction input')
end

if nargin == 4
    doplot = 0;
    dt1 = [];
    dt2 = [];
end

if nargin == 5
    dt1 = [];
    dt2 = [];
end

if nargin == 6
    dt2 = [];
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

iplot = 1;
for i = 1:n
    instrument = codes{i};
    [isequity,equitytype] = isinequitypool(codes{i});
    if isequity
        if equitytype == 1 || equitytype == 2
            ticksize = 0.001;
        else
            ticksize = 0.01;
        end
    else
        if strcmpi(codes{i},'gzhy')
            instrument = codes{i};
            ticksize = 0.0001;%1bp
        elseif strcmpi(codes{i},'audusd') || strcmpi(codes{i},'eurusd') || strcmpi(codes{i},'gbpusd') || ...
                strcmpi(codes{i},'usdcad') || strcmpi(codes{i},'usdchf') || strcmpi(codes{i},'eurchf') || ...
                strcmpi(codes{i},'gbpeur') || strcmpi(codes{i},'usdcnh')
            instrument = codes{i};
            ticksize = 0.0001;%1bp
        elseif strcmpi(codes{i},'usdjpy') || strcmpi(codes{i},'eurjpy') || strcmpi(codes{i},'gbpjpy') || strcmpi(codes{i},'audjpy')
            instrument = codes{i};
            ticksize = 0.01;
        elseif strcmpi(codes{i},'usdx')
            instrument = codes{i};
            ticksize = 0.01;
        else
            try
                instrument = code2instrument(codes{i});
                ticksize = instrument.tick_size;
            catch
                ticksize = 0;
            end
        end
    end
    p = data_in{i};
    if p(2,1) - p(1,1) < 1
        freqstr = '30m';
        nfractal = 4;
    else
        freqstr = 'daily';
        nfractal = 2;
%         if strcmpi(codes{i},'gzhy')
%             nfractal = 4;
%         end
    end
    [resmat{i},resstruct{i}] = tools_technicalplot1(p,nfractal,0,'volatilityperiod',0,'tolerance',0);
    [idxb1{i},idxs1{i}] = fractal_genindicators1(resstruct{i}.px,...
        resstruct{i}.hh,resstruct{i}.ll,...
        resstruct{i}.jaw,resstruct{i}.teeth,resstruct{i}.lips,...
        'instrument',instrument);
    if ~isempty(dt1)
        idxstart_i = find(resstruct{i}.px(:,1)>=dt1,1,'first');
        if isempty(idxstart_i)
            fprintf('fractal_filter:input start date is beyond input data...\n')
            idxstart_i = 1;
        end
    else
        idxstart_i = 1;
    end
    if ~isempty(dt2)
        idxend_i = find(resstruct{i}.px(:,1)<=dt2,1,'last');
        if isempty(idxend_i)
            fprintf('fractal_filter:input end date is before input data...\n')
            idxend_i = size(resstruct{i}.px,1);
        end
    else
        idxend_i = size(resstruct{i}.px,1);
    end
    
    idxb1_i = idxb1{i};
    idx1_b = find(idxb1_i(:,1)>=idxstart_i,1,'first');
    idx2_b = find(idxb1_i(:,1)<=idxend_i,1,'last');
    idxb1_i = idxb1_i(idx1_b:idx2_b,:);
    %
    idxs1_i = idxs1{i};
    idx1_s = find(idxs1_i(:,1)>=idxstart_i,1,'first');
    idx2_s = find(idxs1_i(:,1)<=idxend_i,1,'last');
    idxs1_i = idxs1_i(idx1_s:idx2_s,:);
    
    nb_i = size(idxb1_i,1);ns_i = size(idxs1_i,1);
    nabovelips1_i = zeros(nb_i,1);nbelowlips1_i = zeros(ns_i,1);
    naboveteeth1_i = zeros(nb_i,1);nbelowteeth1_i = zeros(ns_i,1);
    nabovelips2_i = zeros(nb_i,1);nbelowlips2_i = zeros(ns_i,1);
    nkaboveteeth2_i = zeros(nb_i,1);nkbelowteeth2_i = zeros(ns_i,1);
    nkfromhh_i = zeros(nb_i,1);nkfromll_i = zeros(ns_i,1);
    teethjawcrossed_b_i = zeros(nb_i,1);teethjawcrossed_s_i = zeros(ns_i,1);
    useflagb_i = zeros(nb_i,1);useflags_i = zeros(ns_i,1);
    commentsb1_i = cell(nb_i,3);commentss1_i = cell(ns_i,3);
    for j = 1:nb_i
        if direction == -1, continue;end
        %double check whether the open price on the next candle is still valid
        %for a breach as per trading code
        k = idxb1_i(j,1);
        b1type = idxb1_i(j,2);
        extrainfo = fractal_genextrainfo(resstruct{i},k);
        [nabovelips1_i(j),naboveteeth1_i(j),nabovelips2_i(j),nkaboveteeth2_i(j),nkfromhh_i(j),teethjawcrossed_b_i(j)] = fractal_countb(p(1:k,:),extrainfo.idxhh,nfractal,extrainfo.lips,extrainfo.teeth,extrainfo.jaw,ticksize);
        [op,status] = fractal_filterb1_singleentry(b1type,nfractal,extrainfo,ticksize);
%         status = fractal_b1_status(nfractal,extrainfo,ticksize);
        commentsb1_i{j,3} = fractal_b1_status2str(status);
        commentsb1_i{j,2} = op.comment;
        useflagb_i(j) = op.use;
        
%         if k == size(p,1), continue;end
        
        if ~status.istrendconfirmed && k < size(p,1)
%             if p(k+1,2) - resstruct{i}.hh(k) + 2*ticksize < 0
%                 commentsb1_i{j,1} = 'breachb1 break:next open below HH';
%                 useflagb_i(j) = 0;
%                 continue
%             end
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
        end
        
        if (strcmpi(op.comment,filterstr) || strcmpi(filterstr,'all')) && direction == 1
            %
            if doplot
                iplot = iplot + 1;
                for jj = k:size(p,1)
                    if p(jj,5)-resstruct{i}.teeth(jj) < -2*ticksize
                        break
                    end
                end
                if strcmpi(op.comment,'breachup-highsc13') || strcmpi(op.comment,'breachup-highsc13-negative')
                    lastsc13 = find(extrainfo.sc(1:k) == 13,1,'last');
                    tools_technicalplot2(resmat{i}(min(lastsc13,k-nkfromhh_i(j)+1):jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                elseif strcmpi(op.comment,'breachup-sshighvalue')
                    lastss9 = find(extrainfo.ss(1:k) == 9,1,'last');
                    tools_technicalplot2(resmat{i}(min(lastss9-8,k-nkfromhh_i(j)+1):jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                elseif strcmpi(op.comment,'strongbreach-trendbreak')
                    tools_technicalplot2(resmat{i}(max(1,k-max(13,nkfromhh_i(j))+1):jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                elseif strcmpi(op.comment,'mediumbreach-trendbreak')
                    lastbs_index = find(extrainfo.bs(1:k) >= 9,1,'last');
                    lastbc_index = find(extrainfo.bc(1:k) == 13,1,'last');
                    if ~isempty(lastbs_index) || ~isempty(lastbc_index)
                        if ~isempty(lastbs_index)
                            %check whether there has been any further breach
                            %dn of ll since last bs
                            hasbreacheddn = false;
                            for jjj = lastbs_index:k-1
                                if extrainfo.px(jjj,5) > extrainfo.ll(jjj-1) && extrainfo.px(jjj+1,5) < extrainfo.ll(jjj) && extrainfo.ll(jjj-1) == extrainfo.ll(jjj)
                                    hasbreacheddn = true;
                                    break
                                end
                            end
                            if hasbreacheddn
                                tools_technicalplot2(resmat{i}(k-max(9,nkfromhh_i(j))+1:jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                            else
                                lastbs9 = find(extrainfo.bs(1:k) == 9,1,'last');
                                tools_technicalplot2(resmat{i}(min(lastbs9-8,k-nkfromhh_i(j)+1):jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                            end
                        elseif isempty(lastbs_index) && ~isempty(lastbc_index)
                            hasbreacheddn = false;
                            for jjj = lastbc_index:k-1
                                if extrainfo.px(jjj,5) > extrainfo.ll(jjj-1) && extrainfo.px(jjj+1,5) < extrainfo.ll(jjj) && extrainfo.ll(jjj-1) == extrainfo.ll(jjj)
                                    hasbreacheddn = true;
                                    break
                                end
                            end
                            if hasbreacheddn
                                tools_technicalplot2(resmat{i}(k-max(9,nkfromhh_i(j))+1:jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                            else
                                tools_technicalplot2(resmat{i}(min(lastbc_index-8,k-nkfromhh_i(j)+1):jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                            end
                        end
                    else
                        tools_technicalplot2(resmat{i}(k-max(9,nkfromhh_i(j))+1:jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                    end
                else
                    tools_technicalplot2(resmat{i}(k-max(9,nkfromhh_i(j))+1:jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                end
            end
            trade = fractal_gentrade(resstruct{i},codes{i},k,op.comment,1,freqstr);
            trades.push(trade);
        end 
    end
    if direction == 1
        idx = idxb1_i(:,1);
        breachtype = idxb1_i(:,2);
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
    end
    %
    %
    for j = 1:ns_i
        if direction == 1, continue;end
        %double check whether the open price on the next candle is still valid
        %for a breach as per trading code
        k = idxs1_i(j,1);
        s1type = idxs1_i(j,2);
        extrainfo = fractal_genextrainfo(resstruct{i},k);
        [nbelowlips1_i(j),nbelowteeth1_i(j),nbelowlips2_i(j),nkbelowteeth2_i(j),nkfromll_i(j),teethjawcrossed_s_i(j)] = fractal_counts(p(1:k,:),extrainfo.idxll,nfractal,extrainfo.lips,extrainfo.teeth,extrainfo.jaw,ticksize);
        [op,status] = fractal_filters1_singleentry(s1type,nfractal,extrainfo,ticksize);
%         status = fractal_s1_status(nfractal,extrainfo,ticksize);
        commentss1_i{j,3} = fractal_s1_status2str(status);
        commentss1_i{j,2} = op.comment;
        useflags_i(j) = op.use;
        
%         if k == size(p,1), continue;end
        if ~status.istrendconfirmed && k < size(p,1)
            if p(k+1,2) - resstruct{i}.ll(k)-2*ticksize > 0
                commentss1_i{j,1} = 'breachs1 break:next open above LL';
                useflags_i(j) = 0;
                continue;
            end
            if p(k,5) >= p(k,4)+0.382*(resstruct{i}.hh(k)-p(k,4))
                commentss1_i{j,1} = 'breachs1 break:above initial stoploss';
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
            if p(k+1,2) > resstruct{i}.lips(k) > 0
                commentss1_i{j,1} = 'breachs1 break:next open above lips';
                useflags_i(j) = 0;
                continue;
            end
        end
        
        if (strcmpi(op.comment,filterstr) || strcmpi(filterstr,'all')) && direction == -1
            %
            if doplot
                iplot = iplot + 1;
                for jj = k:size(p,1)
                    if p(jj,5)-resstruct{i}.teeth(jj) > 2*ticksize
                        break
                    end
                end
                if strcmpi(op.comment,'breachdn-lowbc13')
                    lastbc13 = find(extrainfo.bc(1:k) == 13,1,'last');
                    tools_technicalplot2(resmat{i}(min(lastbc13,k-nkfromll_i(j)+1):jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                elseif strcmpi(op.comment,'breachdn-bshighvalue')
                    lastbs9 = find(extrainfo.bs(1:k) == 9,1,'last');
                    tools_technicalplot2(resmat{i}(min(lastbs9-8,k-nkfromll_i(j)+1):jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                elseif strcmpi(op.comment,'strongbreach-trendbreak')
                    tools_technicalplot2(resmat{i}(max(k-max(13,nkfromll_i(j))+1,1):jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                else
                    tools_technicalplot2(resmat{i}(k-max(9,nkfromll_i(j))+1:jj,:),iplot,[codes{i},'-',num2str(k),'-',filterstr]);
                end
            end
            trade = fractal_gentrade(resstruct{i},codes{i},k,op.comment,-1,freqstr);
            trades.push(trade);
        end
        
    end
    if direction == -1
        idx = idxs1_i(:,1);
        breachtype = idxs1_i(:,2);
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
    




    
    
end
