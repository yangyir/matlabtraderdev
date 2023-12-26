function [ret] = fractal_tradeinfo_last(varargin)
% fractal utility function
% to check the last trade information, i.e. open signal, live or closed
% condtion
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('code','',@ischar);
p.addParameter('extrainfo','',@isstruct);
p.addParameter('frequency','daily',@ischar);
p.addParameter('repeat',true,@islogical);
p.addParameter('kellydistribution','',@isstruct);
p.parse(varargin{:});
code = p.Results.code;
ei = p.Results.extrainfo;
freq = p.Results.frequency;
repeatflag = p.Results.repeat;
kellytbl = p.Results.kellydistribution;

if strcmpi(freq,'daily')
    nfractal = 2;
else
    if strcmpi(freq,'intraday-30m') || strcmpi(freq,'intraday')
        nfractal = 4;
    elseif strcmpi(freq,'intraday-15m')
        nfractal = 4;
    elseif strcmpi(freq,'intraday-5m')
        nfractal = 6;
    else
        error('fractal_tradeinfo_anyb:invalud frequency input')
    end
end

asset = code2instrument(code);

[idxb1,idxs1] = fractal_genindicators1(ei.px,...
            ei.hh,ei.ll,...
            ei.jaw,ei.teeth,ei.lips,...
            'instrument',asset);
idxb1 = [idxb1,ones(size(idxb1,1),1)];
idxs1 = [idxs1,-ones(size(idxs1,1),1)];
idx = [idxb1;idxs1];
idx = sortrows(idx);
lastbidx = find(idx(:,end) == 1,1,'last');
lastsidx = find(idx(:,end) == -1,1,'last');
%
if lastbidx > lastsidx
    ret.opendirection = 'long';
    b1type = idx(lastbidx,2);
    if b1type == 1
        if isempty(kellytbl)
            ret.status = 'n/a';
            ret.opensignal = 'invalid weak long breach';
            ret.trade = [];
            return
        else
            %here we need to check whether 'weak' breach has historically
            %positive kelly criteria
            error('not implemented');
        end
    end
    j = idx(lastbidx,1);
    d = fractal_truncate(ei,j);
    [op,statusstruct] = fractal_filterb1_singleentry(b1type,nfractal,d,asset.tick_size); 
    
    if isempty(kellytbl)
        if op.use || (~op.use && statusstruct.istrendconfirmed)
            trade = fractal_gentrade(ei,code,j,op.comment,1,freq);
            ret.opensignal = op.comment;
            ret.kelly = 'n/a';
            ret.winp = 'n/a';
        else
            ret.status = 'n/a';
            ret.opensignal = ['invalid long ',op.comment];
            ret.trade = [];
            ret.kelly = 'n/a';
            ret.winp = 'n/a';
            return
        end
    else
        assetname = asset.asset_name;
        if isempty(assetname), assetname = code;end
        kellythreshold = 0.146;
        if strcmpi(op.comment,'volblowup') || strcmpi(op.comment,'volblowup2') || ...
                strcmpi(op.comment,'strongbreach-trendconfirmed') || strcmpi(op.comment,'mediumbreach-trendconfirmed')
            kelly = kelly_k(op.comment,assetname,kellytbl.signal_l,kellytbl.asset_list,kellytbl.kelly_matrix_l);
            wprob = kelly_w(op.comment,assetname,kellytbl.signal_l,kellytbl.asset_list,kellytbl.winprob_matrix_l);
            %here we also need to double check whether bmtc or bstc table
            %gives kelly greater than the kelly threshold
            if statusstruct.b1type == 2
                vlookuptbl = kellytbl.bmtc;
            elseif statusstruct.b1type == 3
                vlookuptbl = kellytbl.bstc;
            end
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly2 = vlookuptbl.K(idx);
            wprob2 = vlookuptbl.W(idx);
            if isempty(kelly2)
                kelly2 = -9.99;
                wprob2 = 0;
            end
            if kelly > kellythreshold && kelly2 > kellythreshold
                %later
            elseif kelly > kellythreshold && kelly2 <= kellythreshold
                %conditional kelly below threshold but unconditional kelly
                %above threshold (due to volblowup cases as it was
                %identified once the candle finished)
                ret.status = 'n/a';
                ret.opensignal = ['invalid long as conditional kelly below threshold',op.comment];
                ret.trade = [];
                ret.kelly = kelly2;
                ret.winp = wprob2;
                return
            elseif kelly <= kellythreshold && kelly2 > kellythreshold    
                %conditional kelly above threshold but unconditional kelly
                %below threshold (due to most non-volblowup cases returns
                %low kellies)
                ret.status = 'n/a';
                ret.opensignal = ['invalid long as kelly below threshold',op.comment];
                ret.trade = [];
                ret.kelly = kelly;
                ret.winp = wprob;
                return
            elseif kelly < kellythreshold && kelly2 < kellythreshold
                ret.status = 'n/a';
                ret.opensignal = ['invalid long ',op.comment];
                ret.trade = [];
                ret.kelly = kelly;
                ret.winp = wprob;
                return
            end
        elseif strcmpi(op.comment,'breachup-highsc13')
            vlookuptbl = kellytbl.breachuphighsc13;
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly)
                kelly = -9.99;
                wprob = 0;
            end
        else
            if ~isempty(strfind(op.comment,'breachup-lvlup'))
                if ~statusstruct.istrendconfirmed
                    vlookuptbl = kellytbl.breachuplvlup_tb;
                else
                    vlookuptbl = kellytbl.breachuplvlup_tc;
                end
                idx = strcmpi(vlookuptbl.asset,assetname);
                kelly = vlookuptbl.K(idx);
                wprob = vlookuptbl.W(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                end
            elseif ~isempty(strfind(op.comment,'breachup-sshighvalue'))
                if ~statusstruct.istrendconfirmed
                    vlookuptbl = kellytbl.breachupsshighvalue_tb;
                else
                    vlookuptbl = kellytbl.breachupsshighvalue_tc;
                end
                idx = strcmpi(vlookuptbl.asset,assetname);
                kelly = vlookuptbl.K(idx);
                wprob = vlookuptbl.W(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                end
            else
                try
                    kelly = kelly_k(op.comment,assetname,kellytbl.signal_l,kellytbl.asset_list,kellytbl.kelly_matrix_l);
                    wprob = kelly_w(op.comment,assetname,kellytbl.signal_l,kellytbl.asset_list,kellytbl.winprob_matrix_l);
                catch
                    idx = strcmpi(op.comment,kellytbl.kelly_table_l.opensignal_unique_l);
                    kelly = kellytbl.kelly_table_l.kelly_unique_l(idx);
                    wprob = kellytbl.kelly_table_l.winp_unique_l(idx);
                end
            end
        end
        %
        if kelly > kellythreshold
            trade = fractal_gentrade(ei,code,j,op.comment,1,freq);
            ret.opensignal = op.comment;
            ret.kelly = kelly;
            ret.winp = wprob;
        else
            ret.status = 'n/a';
            ret.opensignal = ['invalid long ',op.comment];
            ret.trade = [];
            ret.kelly = kelly;
            ret.winp = wprob;
            return
        end
    end
    % run trade with historical data
    unwindtrade = {};
    for k = j+1:size(ei.px,1)
        if strcmpi(trade.status_,'closed'),break;end
        ei_k = fractal_truncate(ei,k);
        if k == size(ei.px,1)
            ei_k.latestopen = ei.px(k,5);
            ei_k.latestdt = ei.px(k,1);
        else
            ei_k.latestopen = ei.px(k+1,2);
            ei_k.latestdt = ei.px(k+1,1);
        end
        unwindtrade = trade.riskmanager_.riskmanagementwithcandle([],...
            'usecandlelastonly',false,...
            'debug',false,...
            'updatepnlforclosedtrade',true,...
            'extrainfo',ei_k);
        if ~isempty(unwindtrade), break;end
    end
    if isempty(unwindtrade)
        ret.status = 'live';
    else
        ret.status = ['long closed:',trade.riskmanager_.closestr_];
    end
    ret.trade = trade;
elseif lastbidx < lastsidx
    ret.opendirection = 'short';
    s1type = idx(lastsidx,2);
    if s1type == 1
        if isempty(kellytbl)
            ret.status = 'n/a';
            ret.opensignal = 'invalid weak short breach';
            ret.trade = [];
            return
        else
            error('not implemented')
        end
    end
    j = idx(lastsidx,1);
    d = fractal_truncate(ei,j);
    [op,statusstruct] = fractal_filters1_singleentry(s1type,nfractal,d,asset.tick_size); 
    
    if isempty(kellytbl)
        if op.use || (~op.use && statusstruct.istrendconfirmed)
            trade = fractal_gentrade(ei,code,j,op.comment,-1,'daily');
            ret.opensignal = op.comment;
            ret.kelly = 'n/a';
            ret.winp = 'n/a';
        else
            ret.status = 'n/a';
            ret.opensignal = ['invalid short ',op.comment];
            ret.trade = [];
            ret.kelly = 'n/a';
            ret.winp = 'n/a';
            return
        end
    else
        assetname = asset.asset_name;
        if isempty(assetname), assetname = code;end
        kellythreshold = 0.146;
        if strcmpi(op.comment,'volblowup') || strcmpi(op.comment,'volblowup2') || ...
                strcmpi(op.comment,'strongbreach-trendconfirmed') || strcmpi(op.comment,'mediumbreach-trendconfirmed')
            kelly = kelly_k(op.comment,assetname,kellytbl.signal_s,kellytbl.asset_list,kellytbl.kelly_matrix_s);
            wprob = kelly_w(op.comment,assetname,kellytbl.signal_s,kellytbl.asset_list,kellytbl.winprob_matrix_s);
            %here we also need to double check whether smtc or sstc table
            %gives kelly greater than the kelly threshold
            if statusstruct.s1type == 2
                vlookuptbl = kellytbl.smtc;
            elseif statusstruct.s1type == 3
                vlookuptbl = kellytbl.sstc;
            end
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly2 = vlookuptbl.K(idx);
            wprob2 = vlookuptbl.W(idx);
            if isempty(kelly2)
                kelly2 = -9.99;
                wprob2 = 0;
            end
            if kelly > kellythreshold && kelly2 > kellythreshold
                %later
            elseif kelly > kellythreshold && kelly2 <= kellythreshold
                %conditional kelly below threshold but unconditional kelly
                %above threshold (due to volblowup cases as it was
                %identified once the candle finished)
                ret.status = 'n/a';
                ret.opensignal = ['invalid short as conditional kelly below threshold',op.comment];
                ret.trade = [];
                ret.kelly = kelly2;
                ret.winp = wprob2;
                return
            elseif kelly <= kellythreshold && kelly2 > kellythreshold
                %conditional kelly above threshold but unconditional kelly
                %below threshold (due to most non-volblowup cases returns
                %low kellies)
                ret.status = 'n/a';
                ret.opensignal = ['invalid short as kelly below threshold',op.comment];
                ret.trade = [];
                ret.kelly = kelly;
                ret.winp = wprob;
                return
            elseif kelly < kellythreshold && kelly2 < kellythreshold
                ret.status = 'n/a';
                ret.opensignal = ['invalid short ',op.comment];
                ret.trade = [];
                ret.kelly = kelly;
                ret.winp = wprob;
                return
            end     
        elseif strcmpi(op.comment,'breachdn-lowbc13')
            vlookuptbl = kellytbl.breachdnlowbc13;
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly)
                kelly = -9.99;
                wprob = 0;
            end
        else
            if ~isempty(strfind(op.comment,'breachdn-lvldn')) 
                if ~statusstruct.istrendconfirmed
                    vlookuptbl = kellytbl.breachdnlvldn_tb;
                else
                    vlookuptbl = kellytbl.breachdnlvldn_tc;
                end
                idx = strcmpi(vlookuptbl.asset,assetname);
                kelly = vlookuptbl.K(idx);
                wprob = vlookuptbl.W(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                end
            elseif ~isempty(strfind(op.comment,'breachdn-bshighvalue')) 
                if ~statusstruct.istrendconfirmed
                    vlookuptbl = kellytbl.breachdnbshighvalue_tb;
                else
                    vlookuptbl = kellytbl.breachdnbshighvalue_tc;
                end
                idx = strcmpi(vlookuptbl.asset,assetname);
                kelly = vlookuptbl.K(idx);
                wprob = vlookuptbl.W(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                end
            else
                try
                    kelly = kelly_k(op.comment,assetname,kellytbl.signal_s,kellytbl.asset_list,kellytbl.kelly_matrix_s);
                    wprob = kelly_w(op.comment,assetname,kellytbl.signal_s,kellytbl.asset_list,kellytbl.winprob_matrix_s);
                catch
                    idx = strcmpi(op.comment,kellytbl.kelly_table_s.opensignal_unique_s);
                    kelly = kellytbl.kelly_table_s.kelly_unique_s(idx);
                    wprob = kellytbl.kelly_table_s.winp_unique_s(idx);
                end
            end
        end
        %
        if kelly > kellythreshold
            trade = fractal_gentrade(ei,code,j,op.comment,-1,freq);
            ret.opensignal = op.comment;
            ret.kelly = kelly;
            ret.winp = wprob;
        else
            ret.status = 'n/a';
            ret.opensignal = ['invalid short ',op.comment];
            ret.trade = [];
            ret.kelly = kelly;
            ret.winp = wprob;
            return
        end
        %
    end
    % run trade with historical data
    unwindtrade = {};
    for k = j+1:size(ei.px,1)
        if strcmpi(trade.status_,'closed'),break;end
        ei_k = fractal_truncate(ei,k);
        if k == size(ei.px,1)
            ei_k.latestopen = ei.px(k,5);
            ei_k.latestdt = ei.px(k,1);
        else
            ei_k.latestopen = ei.px(k+1,2);
            ei_k.latestdt = ei.px(k+1,1);
        end
        unwindtrade = trade.riskmanager_.riskmanagementwithcandle([],...
            'usecandlelastonly',false,...
            'debug',false,...
            'updatepnlforclosedtrade',true,...
            'extrainfo',ei_k);
        if ~isempty(unwindtrade), break;end
    end
    if isempty(unwindtrade)
        ret.status = 'live';
    else
        ret.status = ['short closed:',trade.riskmanager_.closestr_];
    end
    ret.trade = trade;
else
    error('internal error')
end

end