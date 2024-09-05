function signals = gensignalssingle(stratfractal,varargin)
%a cStratFutMultiFractal method
iparser = inputParser;
iparser.CaseSensitive = false;iparser.KeepUnmatched = true;
iparser.addParameter('Instrument','',@(x) validateattributes(x,{'char','cInstrument'},{},'','FromDate'));
iparser.addParameter('kellythresholdtrend',-9.99,@isnumeric);

iparser.parse(varargin{:});
instrument = iparser.Results.Instrument;
if ischar(instrument)
    instrument = code2instrument(instrument);
end

[flag,idx] = stratfractal.helper_.book_.hasposition(instrument);
if ~flag
    volume_exist = 0;
else
    pos = stratfractal.helper_.book_.positions_{idx};
    volume_exist = pos.position_total_;
end

code = instrument.code_ctp;
try
    maxvolume = stratfractal.riskcontrols_.getconfigvalue('code',code,'propname','maxunits');
catch
    maxvolume = 0;
end

if abs(maxvolume) == abs(volume_exist)
    signals = {};
    return
end

[flag,idx] = stratfractal.hasinstrument(instrument);
if ~flag
    signals = {};
    return;
end
   
try
    techvar = stratfractal.calctechnicalvariable(instrument,'IncludeLastCandle',0,'RemoveLimitPrice',1);
    p = techvar(:,1:5);
    idxHH = techvar(:,6);
    idxLL = techvar(:,7);
    hh = techvar(:,8);
    ll = techvar(:,9);
    jaw = techvar(:,10);
    teeth = techvar(:,11);
    lips = techvar(:,12);
    bs = techvar(:,13);
    ss = techvar(:,14);
    lvlup = techvar(:,15);
    lvldn = techvar(:,16);
    bc = techvar(:,17);
    sc = techvar(:,18);
    wad = techvar(:,19);
    %
    extrainfo = struct('px',p,...
    'ss',ss,'sc',sc,...
    'bs',bs,'bc',bc,...
    'lvlup',lvlup,'lvldn',lvldn,...
    'idxhh',idxHH,'hh',hh,...
    'idxll',idxLL,'ll',ll,...
    'lips',lips,'teeth',teeth,'jaw',jaw,...
    'wad',wad);

    stratfractal.hh_{idx} = hh;
    stratfractal.ll_{idx} = ll;
    stratfractal.jaw_{idx} = jaw;
    stratfractal.teeth_{idx} = teeth;
    stratfractal.lips_{idx} = lips;
    stratfractal.bs_{idx} = bs;
    stratfractal.ss_{idx} = ss;
    stratfractal.lvlup_{idx} = lvlup;
    stratfractal.lvldn_{idx} = lvldn;
    stratfractal.bc_{idx} = bc;
    stratfractal.sc_{idx} = sc;
    stratfractal.wad_{idx} = wad;
catch e
    msg = sprintf('ERROR:%s:gensignalssingle:calctechnicalvariable:%s:%s\n',class(stratfractal),instrument.code_ctp,e.message);
    fprintf(msg);
    signals = {};
    return
end
%
signals = cell(1,2);

nfractal = stratfractal.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','nfractals');
freq = stratfractal.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
isintraday = ~strcmpi(freq,'1440m');
if isintraday
    kellytable = stratfractal.tbl_all_intraday_;
else
    kellytable = stratfractal.tbl_all_daily_;
end

try
    ticksize = instrument.tick_size;
catch
    ticksize = 0;
end

try
    assetname = instrument.asset_name;
catch
    assetname = 'unknown';
end

tick = stratfractal.mde_fut_.getlasttick(instrument);

[signal_,op,status] = fractal_signal_unconditional(extrainfo,ticksize,nfractal,'lasttick',tick);
if ~isempty(signal_)
    if signal_(1) == 0
        if op.direction == 1
            try
                kelly = kelly_k(op.comment,assetname,kellytable.signal_l,kellytable.asset_list,kellytable.kelly_matrix_l,0);
                wprob = kelly_w(op.comment,assetname,kellytable.signal_l,kellytable.asset_list,kellytable.winprob_matrix_l,0);
                useflag = 1;
            catch
                idx = strcmpi(op.comment,kellytable.kelly_table_l.opensignal_unique_l);
                kelly = kellytable.kelly_table_l.kelly_unique_l(idx);
                wprob = kellytable.kelly_table_l.winp_unique_l(idx);
                useflag = kellytable.kelly_table_l.use_unique_l(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                    useflag = 0;
                end
            end
        elseif op.direction == -1
            try
                kelly = kelly_k(op.comment,assetname,kellytable.signal_s,kellytable.asset_list,kellytable.kelly_matrix_s,0);
                wprob = kelly_w(op.comment,assetname,kellytable.signal_s,kellytable.asset_list,kellytable.winprob_matrix_s,0);
                useflag = 1;
            catch
                idx = strcmpi(op.comment,kellytable.kelly_table_s.opensignal_unique_s);
                kelly = kellytable.kelly_table_s.kelly_unique_s(idx);
                wprob = kellytable.kelly_table_s.winp_unique_s(idx);
                useflag = kellytable.kelly_table_s.use_unique_s(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                    useflag = 0;
                end
            end
        else
            kelly = 0;
            wprob = 0;
            useflag = 0;
        end
        %NOTE:here kelly and wprob threshold shall be set
        %via configuration files, TODO:
        if kelly >= 0.141 && wprob >= 0.41 && useflag
            signal_(1) = op.direction;
            signal_(4) = op.direction;
        elseif wprob >= 0.5 && useflag && kelly > 0.1 && ...
                (strcmpi(op.comment,'strongbreach-trendbreak') || strcmpi(op.comment,'volblowup-trendbreak'))
            signal_(1) = op.direction;
            signal_(4) = op.direction;
        else
            if status.istrendconfirmed && strcmpi(op.comment,'breachup-lvlup-invalid long as close moves too high') && stratfractal.helper_.book_.hasposition(instrument)
                vlookuptbl = kellytable.breachuplvlup_tc;
                idx = strcmpi(vlookuptbl.asset,assetname); 
                kelly = vlookuptbl.K(idx);
                wprob = vlookuptbl.W(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                end
                if ~(kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41) || (kelly > 0.09 && wprob > 0.455))
                    stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                end
            else
                stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
            end
        end
        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),op.comment,100*kelly,100*wprob);
        %
        try
            stratfractal.processcondentrust(instrument,'techvar',techvar);
        catch e
            fprintf('gensignalssingle:processcondentrust called in gensignalssingle but failed:%s\n', e.message);
            stratfractal.stop;
        end
        %
    elseif signal_(1) == 1
        %20230613:further check of signals
        if strcmpi(op.comment,'volblowup') || strcmpi(op.comment,'volblowup2') || ...
                strcmpi(op.comment,'strongbreach-trendconfirmed') || strcmpi(op.comment,'mediumbreach-trendconfirmed')
            %do nothing as this is for sure trending trades           
            try
                kelly = kelly_k(op.comment,assetname,kellytable.signal_l,kellytable.asset_list,kellytable.kelly_matrix_l,0);
                wprob = kelly_w(op.comment,assetname,kellytable.signal_l,kellytable.asset_list,kellytable.winprob_matrix_l,0);
            catch
                idxvolblowup2 = strcmpi(kellytable.kelly_table_l.opensignal_unique_l,op.comment);
                kelly = kellytable.kelly_table_l.kelly_unique_l(idxvolblowup2);
                wprob = kellytable.kelly_table_l.winp_unique_l(idxvolblowup2);
            end
            %
            %%NOTE:here kelly or wprob threshold shall be set
            %%via configuration files,TODO:
            if ~(kelly>=0.145 || (kelly>0.11 && wprob>0.41) || (kelly>0.10 && wprob>0.45) || (kelly>0.12 && wprob>0.40)) 
                if stratfractal.helper_.book_.hasposition(instrument)
                    %in case the condtional uptrend trade was
                    %opened with breachsshighvalue but it turns
                    %out to be a normal trend trade, e.g.check
                    %with live hog on 24th Jan 2024
                    if ss(end) >= 9 && ~strcmpi(op.comment,'volblowup')
                        idxss9 = find(ss == 9,1,'last');
                        pxhightillss9 = max(p(idxss9-8:idxss9,3));
                        if pxhightillss9 == hh(end)
                            op.comment = 'breachup-sshighvalue';
                            vlookuptbl = kellytable.breachupsshighvalue_tc;
                            idx = strcmpi(vlookuptbl.asset,assetname);
                            kelly = vlookuptbl.K(idx);
                            wprob = vlookuptbl.W(idx);
                            if isempty(kelly)
                                kelly = -9.99;
                                wprob = 0;
                            end
                            if ~(kelly>=0.145 || (kelly>0.11 && wprob>0.41) || (kelly>0.10 && wprob>0.45) || (kelly>0.12 && wprob>0.40))
                                signal_(1) = 0;
                                signal_(4) = 0;
                                stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                            end
                        else
                            signal_(1) = 0;
                            signal_(4) = 0;
                            stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                        end
                    else
                        %unwind position as the kelly or
                        %winning probability is low
                        signal_(1) = 0;
                        signal_(4) = 0;
                        stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                    end
                else
                    signal_(1) = 0;
                    signal_(4) = 0;
                end
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),op.comment,100*kelly,100*wprob);
            else
                %special case found on backest of y2409 on 20240802
                if ss(end-1) >= 9
                    sslastval = ss(end-1);
                    sshighpx = max(p(end-sslastval:end-1,3));
                    sshighidx = find(p(end-sslastval:end-1,3) == sshighpx,1,'last') + size(p,1) - sslastval - 1;
                    sslowpx = p(sshighidx,4);
                    if hh(end) <= sslowpx
                        signal_(1) = 0;
                        signal_(4) = 0;
                        stratfractal.unwindpositions(instrument,'closestr','fracal hh is too low');
                    end
                else
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),op.comment,100*kelly,100*wprob);
                end
            end
        elseif strcmpi(op.comment,'breachup-highsc13')
            vlookuptbl = kellytable.breachuphighsc13;
            idx = strcmpi(vlookuptbl.asset,assetname);
            try
                kelly = vlookuptbl.K(idx);
                wprob = vlookuptbl.W(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                end
            catch
                kelly = -9.99;
                wprob = 0;
            end
            if ~(kelly >= 0.145 || (kelly > 0.1 && wprob > 0.41))
                signal_(1) = 0;
                signal_(4) = 0;
                stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
            end
            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),op.comment,100*kelly,100*wprob);
        else
            if ~isempty(strfind(op.comment,'breachup-lvlup'))
                if ~status.istrendconfirmed
                    vlookuptbl = kellytable.breachuplvlup_tb;
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    try
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            kelly = -9.99;
                            wprob = 0;
                        end
                    catch
                        kelly = -9.99;
                        wprob = 0;
                    end
                    if ~(kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41) || (kelly > 0.09 && wprob > 0.455))
                        signal_(1) = 0;
                        signal_(4) = 0;
                        stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                    end
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),'breachup-lvlup-tb',100*kelly,100*wprob);
                else
                    if hh(end) >= lvlup(end)
                        vlookuptbl = kellytable.breachuplvlup_tc;
                    else
                        vlookuptbl = kellytable.breachuplvlup_tc_all;
                    end
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    try
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            kelly = -9.99;
                            wprob = 0;
                        end
                    catch
                        kelly = -9.99;
                        wprob = 0;
                    end
                    if ~(kelly > 0.1 && wprob >= 0.40)
                        signal_(1) = 0;
                        signal_(4) = 0;
                        %unwind position as the kelly or
                        %winning probability is low
                        %in case there are any positions
                        stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                    end
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),'breachup-lvlup-tc',100*kelly,100*wprob);
                end
            elseif ~isempty(strfind(op.comment,'breachup-sshighvalue'))
                if ~status.istrendconfirmed
                    vlookuptbl = kellytable.breachupsshighvalue_tb;
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    try
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            kelly = -9.99;
                            wprob = 0;
                        end
                    catch
                        kelly = -9.99;
                        wprob = 0;
                    end
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),'breachup-sshighvalue-tb',100*kelly,100*wprob);
                    if kelly < 0.145 || wprob < 0.41
                        signal_(1) = 0;
                        signal_(4) = 0;
                        stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                    end
                else
                    vlookuptbl = kellytable.breachupsshighvalue_tc;
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    try
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            kelly = -9.99;
                            wprob = 0;
                        end
                    catch
                        kelly = -9.99;
                        wprob = 0;
                    end
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),'breachup-sshighvalue-tc',100*kelly,100*wprob);
                    if ~(kelly >= 0.145 || (kelly > 0.1 && wprob > 0.41))
                        signal_(1) = 0;
                        signal_(4) = 0;
                        %unwind position as the kelly or
                        %winning probability is low
                        %in case there are any positions
                        stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                    end
                end
            else
                %not trending signals
                try
                    kelly = kelly_k(op.comment,assetname,kellytable.signal_l,kellytable.asset_list,kellytable.kelly_matrix_l,0);
                    wprob = kelly_w(op.comment,assetname,kellytable.signal_l,kellytable.asset_list,kellytable.winprob_matrix_l,0);
                catch
                    idx = strcmpi(op.comment,kellytable.kelly_table_l.opensignal_unique_l);
                    kelly = kellytable.kelly_table_l.kelly_unique_l(idx);
                    wprob = kellytable.kelly_table_l.winp_unique_l(idx);
                    signal_(1) = 0;
                    signal_(4) = 0;
                    stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                end
                if ~isempty(strfind(op.comment,'volblowup-')) || strcmpi(op.comment,'strongbreach-trendbreak')
                    if wprob > 0.5
                        if kelly <= 0.05
                            signal_(1) = 0;
                            signal_(4) = 0;
                            stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                        else
                            signal_(1) = 1;
                            signal_(4) = 1;
                        end
                    else
                        if kelly < 0.145 || wprob < 0.4
                            signal_(1) = 0;
                            signal_(4) = 0;
                            stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                        end
                    end
                else
                    if kelly < 0.145 || wprob < 0.4
                        signal_(1) = 0;
                        signal_(4) = 0;
                        stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                    end
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),op.comment,100*kelly,100*wprob);
                end
            end
        end
        %
    elseif signal_(1) == -1
        %20230613:further check of signals
        if strcmpi(op.comment,'volblowup') || strcmpi(op.comment,'volblowup2') || ...
                strcmpi(op.comment,'strongbreach-trendconfirmed') || strcmpi(op.comment,'mediumbreach-trendconfirmed')
            %do nothing as this is for sure trending trades
            try
                kelly = kelly_k(op.comment,assetname,kellytable.signal_s,kellytable.asset_list,kellytable.kelly_matrix_s,0);
                wprob = kelly_w(op.comment,assetname,kellytable.signal_s,kellytable.asset_list,kellytable.winprob_matrix_s,0);
            catch
                idxvolblowup2 = strcmpi(kellytable.kelly_table_s.opensignal_unique_s,op.comment);
                kelly = kellytable.kelly_table_s.kelly_unique_s(idxvolblowup2);
                wprob = kellytable.kelly_table_s.winp_unique_s(idxvolblowup2);
            end
            %
            if ~(kelly>=0.145 || (kelly>0.11 && wprob>0.41) || (kelly>0.10 && wprob>0.45))
                if stratfractal.helper_.book_.hasposition(instrument)
                    %in case the conditional dntrend was opened
                    %with breachdnbshighvalue but it turns out
                    %to be a normal trend trend, e.g zn2403 on
                    %20240117
                    %yet!!!
                    if bs(end) >= 9 || bs(end-1) >= 9 && ~strcmpi(op.comment,'volblowup') 
                        idxbs9 = find(bs == 9,1,'last');
                        pxlowtillbs9 = min(p(idxbs9-8:idxbs9,4));
                        if pxlowtillbs9 == ll(end)
                            op.comment = 'breachdn-bshighvalue';
                            vlookuptbl = kellytable.breachdnbshighvalue_tc;
                            idx = strcmpi(vlookuptbl.asset,assetname);
                            kelly = vlookuptbl.K(idx);
                            wprob = vlookuptbl.W(idx);
                            if isempty(kelly)
                                kelly = -9.99;
                                wprob = 0;
                            end
                            if ~(kelly>=0.145 || (kelly>0.11 && wprob>0.41) || (kelly>0.10 && wprob>0.45))
                                signal_(1) = 0;
                                signal_(4) = 0;
                                stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                            end
                        else
                            lastll = find(idxLL == -1,1,'last');
                            if lastll < idxbs9 - bs(idxbs9)+1
                                %the lastest LL was formed
                                %before the latest buy setup
                                %sequential
                                op.comment = 'breachdn-bshighvalue';
                                vlookuptbl = kellytable.breachdnbshighvalue_tc;
                                idx = strcmpi(vlookuptbl.asset,assetname);
                                kelly = vlookuptbl.K(idx);
                                wprob = vlookuptbl.W(idx);
                                if isempty(kelly)
                                    kelly = -9.99;
                                    wprob = 0;
                                end
                                if ~(kelly>=0.145 || (kelly>0.11 && wprob>0.41) || (kelly>0.10 && wprob>0.45))
                                    signal_(1) = 0;
                                    signal_(4) = 0;
                                    stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                                end
                            else
                                signal_(1) = 0;
                                signal_(4) = 0;
                                stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                            end
                        end
                    else
                        %unwind position as the kelly or
                        %winning probability is low
                        if kelly <= 0
                            signal_(1) = 0;
                            signal_(4) = 0;
                            stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                        else
                            if ~(wprob > 0.45 && kelly > 0.0833)
                                signal_(1) = 0;
                                signal_(4) = 0;
                                stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                            end
                        end
                    end
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),op.comment,100*kelly,100*wprob);
                else
                    signal_(1) = 0;
                    signal_(4) = 0;
                end
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),op.comment,100*kelly,100*wprob);
            else
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),op.comment,100*kelly,100*wprob);
            end
            %
        elseif strcmpi(op.comment,'breachdn-lowbc13')
            vlookuptbl = kellytable.breachdnlowbc13;
            idx = strcmpi(vlookuptbl.asset,assetname);
            try
                kelly = vlookuptbl.K(idx);
                wprob = vlookuptbl.W(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                end
            catch
                kelly = -9.99;
                wprob = 0;
            end
            if ~(kelly >= 0.145 || (kelly > 0.1 && wprob > 0.41))
                signal_(1) = 0;
                signal_(4) = 0;
                stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
            end
            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),'breachdn-lowbc13',100*kelly,100*wprob);
        else
            if ~isempty(strfind(op.comment,'breachdn-lvldn'))
                if ~status.istrendconfirmed
                    vlookuptbl = kellytable.breachdnlvldn_tb;
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    try
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            kelly = -9.99;
                            wprob = 0;
                        end
                    catch
                        kelly = -9.99;
                        wprob = 0;
                    end
                    if ~(kelly >= 0.145 || (kelly > 0.1 && wprob > 0.41))
                        signal_(1) = 0;
                        signal_(4) = 0;
                    end
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),'breachdn-lvldn-tb',100*kelly,100*wprob);
                else
                    vlookuptbl = kellytable.breachdnlvldn_tc_all;
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    try
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            kelly = -9.99;
                            wprob = 0;
                        end
                    catch
                        kelly = -9.99;
                        wprob = 0;
                    end
                    if ~(kelly >= 0.145 || (kelly > 0.1 && wprob > 0.41))
                        signal_(1) = 0;
                        signal_(4) = 0;
                        stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                    end
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),'breachdn-lvldn-tc',100*kelly,100*wprob);
                end
            elseif ~isempty(strfind(op.comment,'breachdn-bshighvalue'))
                if ~status.istrendconfirmed
                    vlookuptbl = kellytable.breachdnbshighvalue_tb;
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    try
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            kelly = -9.99;
                            wprob = 0;
                        end
                    catch
                        kelly = -9.99;
                        wprob = 0;
                    end
                    if kelly < 0.145 || wprob < 0.41
                        signal_(1) = 0;
                        signal_(4) = 0;
                        stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                        stratfractal.withdrawcondentrust(instrument);
                    end
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),'breachdn-bshighvalue-tb',100*kelly,100*wprob);
                else
                    vlookuptbl = kellytable.breachdnbshighvalue_tc;
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    try
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            kelly = -9.99;
                            wprob = 0;
                        end
                    catch
                        kelly = -9.99;
                        wprob = 0;
                    end
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),'breachdn-bshighvalue-tc',100*kelly,100*wprob);
                    if ~(kelly >= 0.145 || (kelly > 0.1 && wprob > 0.41))
                        signal_(1) = 0;
                        signal_(4) = 0;
                        %unwind position as the kelly or
                        %winning probability is low
                        %in case there are any positions
                        %special treatment???
                        if stratfractal.helper_.book_.hasposition(instrument) && kelly < 0.1
                            stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                        end
                    end
                end
            else
                try
                    kelly = kelly_k(op.comment,assetname,kellytable.signal_s,kellytable.asset_list,kellytable.kelly_matrix_s,0);
                    wprob = kelly_w(op.comment,assetname,kellytable.signal_s,kellytable.asset_list,kellytable.winprob_matrix_s,0);
                    if kelly < 0.145 || wprob < 0.41
                        signal_(1) = 0;
                        signal_(4) = 0;
                        stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                    end
                catch
                    idx = strcmpi(op.comment,kellytable.kelly_table_s.opensignal_unique_s);
                    kelly = kellytable.kelly_table_s.kelly_unique_s(idx);
                    wprob = kellytable.kelly_table_s.winp_unique_s(idx);
                    signal_(1) = 0;
                    signal_(4) = 0;
                    stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                end
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_(1)),op.comment,100*kelly,100*wprob);
            end
        end
        %
    else
        %do nothing
        %internal errror
    end
    if signal_(1) == 1
        if ~isempty(strfind(op.comment,'breachup-sshighvalue'))
            sshighidx = find(ss >= 9,1,'last');
            sshighval = ss(sshighidx);
            sshighpx = max(extrainfo.px(sshighidx-sshighval+1:sshighidx,3));
            highpxidx = sshighidx-sshighval+find(extrainfo.px(sshighidx-sshighval+1:sshighidx,3) == sshighpx,1,'last');
            lowpx = extrainfo.px(highpxidx,4);
            signal_(7) = max(lowpx,signal_(7));
        end
        signals{1,1} = signal_;
    else
        if ~isempty(strfind(op.comment,'breachdn-bshighvalue'))
            bshighidx = find(bs >= 9,1,'last');
            bshighval = bs(bshighidx);
            bslowpx = min(extrainfo.px(bshighidx-bshighval+1:bshighidx,4));
            lowpxidx = bshighidx-bshighval+find(extrainfo.px(bshighidx-bshighval+1:bshighidx,4) == bslowpx,1,'last');
            highpx = extrainfo.px(lowpxidx,3);
            signal_(7) = min(highpx,signal_(7));
        end
        signals{1,2} = signal_;
    end
else
    %EMPTY RETURNS FROM UNCONDITIONAL SIGNAL CALCULATION
    try
        stratfractal.processcondentrust(instrument,'techvar',techvar);
    catch e
        fprintf('gensignalsingle:processcondentrust called in gensignals but failed:%s\n', e.message);
        stratfractal.stop;
    end
    %
    %
    [signal_cond_i,op_cond_i,flags_i] = fractal_signal_conditional(extrainfo,ticksize,nfractal);
    %20230613:further check of conditional signals
    if ~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,1}) && signal_cond_i{1,1}(1) == 1
        %
        isbreachuplvlup = flags_i.islvlupbreach;
        isbreachupsshigh = flags_i.issshighbreach;
        isbreachupschigh = flags_i.isschighbreach;
        %
        if isbreachuplvlup || isbreachupsshigh || isbreachupschigh
            if isbreachuplvlup
                vlookuptbl = kellytable.breachuplvlup_tc;
                op_cond_i{1,1} = [op_cond_i{1,1},'-1'];
            elseif isbreachupsshigh
                vlookuptbl = kellytable.breachupsshighvalue_tc;
                op_cond_i{1,1} = [op_cond_i{1,1},'-2'];
            elseif isbreachupschigh
                vlookuptbl = kellytable.breachuphighsc13;
                op_cond_i{1,1} = [op_cond_i{1,1},'-3'];
            end
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly)
                kelly = -9.99;
                wprob = 0;
            end
            if isbreachuplvlup
                if kelly > 0.088 && wprob >= 0.4
                    signal_cond_i{1,1}(1) = 1;
                else
                    signal_cond_i{1,1}(1) = 0;
                    stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                end
            else
                if kelly >= 0.145 || (kelly > 0.1 && wprob > 0.41)
                    signal_cond_i{1,1}(1) = 1;
                else
                    signal_cond_i{1,1}(1) = 0;
                    if ~(kelly >= 0.1 || (kelly > 0.088 && wprob >= 0.499))
                        stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                    end
                end
            end
        else
            %HERE we cannot identify whether it is volblowup or
            %ordinary trending breaks
            if strcmpi(op_cond_i{1,1},'conditional:mediumbreach-trendconfirmed')
                vlookuptbl = kellytable.bmtc;
                try
                    kelly2 = kelly_k('mediumbreach-trendconfirmed',assetname,kellytable.signal_l,kellytable.asset_list,kellytable.kelly_matrix_l,0);
                    wprob2 = kelly_w('mediumbreach-trendconfirmed',assetname,kellytable.signal_l,kellytable.asset_list,kellytable.winprob_matrix_l,0);
                catch
                    kelly2 = -9.99;
                    wprob2 = 0;
                end
                try
                    kelly3 = kelly_k('volblowup',assetname,kellytable.signal_l,kellytable.asset_list,kellytable.kelly_matrix_l,0);
                    wprob3 = kelly_w('volblowup',assetname,kellytable.signal_l,kellytable.asset_list,kellytable.winprob_matrix_l,0);
                catch
                    kelly3 = -9.99;
                    wprob3 = 0;
                end
                %
            elseif strcmpi(op_cond_i{1,1},'conditional:strongbreach-trendconfirmed')               
                vlookuptbl = kellytable.bstc;
                try
                    kelly2 = kelly_k('strongbreach-trendconfirmed',assetname,kellytable.signal_l,kellytable.asset_list,kellytable.kelly_matrix_l,0);
                    wprob2 = kelly_w('strongbreach-trendconfirmed',assetname,kellytable.signal_l,kellytable.asset_list,kellytable.winprob_matrix_l,0);
                catch
                    kelly2 = -9.99;
                    wprob2 = 0;
                end
                try
                    kelly3 = kelly_k('volblowup',assetname,kellytable.signal_l,kellytable.asset_list,kellytable.kelly_matrix_l,0);
                    wprob3 = kelly_w('volblowup',assetname,kellytable.signal_l,kellytable.asset_list,kellytable.winprob_matrix_l,0);
                catch
                    kelly3 = -9.99;
                    wprob3 = 0;
                end
                %
            end
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            %kelly and wprob are conditional kelly and win prob
            if isempty(kelly)
                kelly = -9.99;
                wprob = 0;
            end
            if kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41)
                signal_cond_i{1,1}(1) = 1;
            else
                %here we need to compare with unconditional
                %mediumbreach-trendconfirmed or
                %strongbreach-trendconfirmed since it is not
                %known whether the conditional bid would turn
                %out to be a volblowup or volblowup2
                if kelly3 >= 0.145 || (kelly3 > 0.11 && wprob3 > 0.41) || (kelly3 > 0.1 && wprob3 > 0.5)
                    signal_cond_i{1,1}(1) = 1;
                    fprintf('\tpotential high kelly with volblowup breach up...\n');
                elseif kelly2 >= 0.145 || (kelly2 > 0.11 && wprob2 > 0.41)
                    signal_cond_i{1,1}(1) = 1;
                    fprintf('\tpotential high kelly with ordinary trending breach up...\n');
                else
                    signal_cond_i{1,1}(1) = 0;
                    if extrainfo.hh(end) >= extrainfo.hh(end-1) && ~(kelly >= 0.1 || (kelly > 0.088 && wprob >= 0.499))
                        stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                    end
                end
            end
        end
        %
        %
        if signal_cond_i{1,1}(1) == 0
            if isbreachuplvlup
                fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(1),'conditional breachup-lvlup',100*kelly,100*wprob);
            elseif isbreachupsshigh
                fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(1),'conditional breachup-sshighvalue',100*kelly,100*wprob);
            elseif isbreachupschigh
                fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(1),'conditional breachup-highsc13',100*kelly,100*wprob);
            else
                fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(1),op_cond_i{1,1},100*kelly,100*wprob);
            end
            %                         stratfractal.unwindpositions(instruments{i});
            condentrusts2remove = EntrustArray;
            ne = stratfractal.helper_.condentrustspending_.latest;
            for jj = 1:ne
                e = stratfractal.helper_.condentrustspending_.node(jj);
                if e.offsetFlag ~= 1, continue; end
                if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                if e.direction ~= 1,continue;end
                condentrusts2remove.push(e);
            end
            if condentrusts2remove.latest > 0
                stratfractal.removecondentrusts(condentrusts2remove);
                fprintf('\t%6s:%4s\t%10s cancled as new mode with low kelly....\n',instrument.code_ctp,num2str(1),e.signalinfo_.mode);
            end
        end
    end
    if ~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,2}) && signal_cond_i{1,2}(1) == -1
        %
        isbreachdnlvldn = flags_i.islvldnbreach;
        isbreachdnbslow = flags_i.isbslowbreach;
        isbreachdnbclow = flags_i.isbclowbreach;
        %
        if isbreachdnlvldn || isbreachdnbslow || isbreachdnbclow
            if isbreachdnlvldn
                vlookuptbl = kellytable.breachdnlvldn_tc;
                op_cond_i{1,2} = [op_cond_i{1,2},'-1'];
            elseif isbreachdnbslow
                vlookuptbl = kellytable.breachdnbshighvalue_tc;
                op_cond_i{1,2} = [op_cond_i{1,2},'-2'];
            elseif isbreachdnbclow
                vlookuptbl = kellytable.breachdnlowbc13;
                op_cond_i{1,2} = [op_cond_i{1,2},'-3'];
            end
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly)
                kelly = -9.99;
                wprob = 0;
            end
            if kelly >= 0.145 || (kelly > 0.1 && wprob > 0.41)
                signal_cond_i{1,2}(1) = -1;
            else
                signal_cond_i{1,2}(1) = 0;
                if ~(kelly >= 0.1 || (kelly > 0.088 && wprob >= 0.499))
                    stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                end
            end
        else
            if strcmpi(op_cond_i{1,2},'conditional:mediumbreach-trendconfirmed')
                vlookuptbl = kellytable.smtc;
                try
                    kelly2 = kelly_k('mediumbreach-trendconfirmed',assetname,kellytable.signal_s,kellytable.asset_list,kellytable.kelly_matrix_s,0);
                    wprob2 = kelly_w('mediumbreach-trendconfirmed',assetname,kellytable.signal_s,kellytable.asset_list,kellytable.winprob_matrix_s,0);
                catch
                    kelly2 = -9.99;
                    wprob2 = 0;
                end
                try
                    kelly3 = kelly_k('volblowup',assetname,kellytable.signal_s,kellytable.asset_list,kellytable.kelly_matrix_s,0);
                    wprob3 = kelly_w('volblowup',assetname,kellytable.signal_s,kellytable.asset_list,kellytable.winprob_matrix_s,0);
                catch
                    kelly3 = -9.99;
                    wprob3 = 0;
                end
            elseif strcmpi(op_cond_i{1,2},'conditional:strongbreach-trendconfirmed')
                vlookuptbl = kellytable.sstc;
                try
                    kelly2 = kelly_k('strongbreach-trendconfirmed',assetname,kellytable.signal_s,kellytable.asset_list,kellytable.kelly_matrix_s,0);
                    wprob2 = kelly_w('strongbreach-trendconfirmed',assetname,kellytable.signal_s,kellytable.asset_list,kellytable.winprob_matrix_s,0);
                catch
                    kelly2 = -9.99;
                    wprob2 = 0;
                end
                try
                    kelly3 = kelly_k('volblowup',assetname,kellytable.signal_s,kellytable.asset_list,kellytable.kelly_matrix_s,0);
                    wprob3 = kelly_w('volblowup',assetname,kellytable.signal_s,kellytable.asset_list,kellytable.winprob_matrix_s,0);
                catch
                    kelly3 = -9.99;
                    wprob3 = 0;
                end
            end
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly)
                kelly = -9.99;
                wprob = 0;
            end
            if kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41)
                signal_cond_i{1,2}(1) = -1;
            else
                %here we need to compare with unconditional
                %mediumbreach-trendconfirmed or
                %strongbreach-trendconfirmed since it is not
                %known whether the conditional bid would turn
                %out to be a volblowup or volblowup2
                if kelly3 >= 0.145 || (kelly3 > 0.11 && wprob3 > 0.41)
                    if kelly < 0
                        extracheck = isempty(find(extrainfo.px(end-2*nfractal+1:end,5)-extrainfo.teeth(end-2*nfractal+1:end)+ticksize>0,1,'first'));
                        if extracheck
                            signal_cond_i{1,2}(1) = -1;
                            fprintf('\tpotential high kelly with volblowup breach dn...\n');
                        else
                            signal_cond_i{1,2}(1) = 0;
                             if extrainfo.ll(end) <= extrainfo.ll(end-1) && ~(kelly >= 0.1 || (kelly > 0.088 && wprob >= 0.499))
                                 stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                             end
                        end
                    else
                        signal_cond_i{1,2}(1) = -1;
                        fprintf('\tpotential high kelly with volblowup breach dn...\n');
                    end
                elseif kelly2 >= 0.145 || (kelly2 > 0.11 && wprob2 > 0.41)
                    if kelly < 0
                        extracheck = isempty(find(extrainfo.px(end-2*nfractal+1:end,5)-extrainfo.teeth(end-2*nfractal+1:end)+ticksize>0,1,'first'));
                        if extracheck
                            signal_cond_i{1,2}(1) = -1;
                            fprintf('\tpotential high kelly with ordinary trending breach dn...\n');
                        else
                            signal_cond_i{1,2}(1) = 0;
                            if extrainfo.ll(end) <= extrainfo.ll(end-1) && ~(kelly >= 0.1 || (kelly > 0.088 && wprob >= 0.499))
                                stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                            end
                        end
                    else
                        signal_cond_i{1,2}(1) = -1;
                        fprintf('\tpotential high kelly with ordinary trending breach dn...\n');
                    end
                else
                    signal_cond_i{1,2}(1) = 0;
                    if extrainfo.ll(end) <= extrainfo.ll(end-1) && ~(kelly >= 0.1 || (kelly > 0.088 && wprob >= 0.499))
                        stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
                    end
                end
            end
        end
        %
        %
        if signal_cond_i{1,2}(1) == 0
            if isbreachdnlvldn
                fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(-1),'conditional breachdn-lvldn',100*kelly,100*wprob);
            elseif isbreachdnbslow
                fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(-1),'conditional breachdn-bshighvalue',100*kelly,100*wprob);
            elseif isbreachdnbclow
                fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(-1),'conditional breachdn-lowbc13',100*kelly,100*wprob);
            else
                fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(-1),op_cond_i{1,2},100*kelly,100*wprob);
            end
            %                         stratfractal.unwindpositions(instruments{i});
            condentrusts2remove = EntrustArray;
            ne = stratfractal.helper_.condentrustspending_.latest;
            for jj = 1:ne
                e = stratfractal.helper_.condentrustspending_.node(jj);
                if e.offsetFlag ~= 1, continue; end
                if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                if e.direction ~= -1,continue;end
                condentrusts2remove.push(e);
            end
            if condentrusts2remove.latest > 0
                stratfractal.removecondentrusts(condentrusts2remove);
                fprintf('\t%6s:%4s\t%10s cancled as new mode with low kelly....\n',instrument.code_ctp,num2str(-1),e.signalinfo_.mode);
            end
        end
    end
    %
    %
    [hhstatus,llstatus] = fractal_barrier_status(extrainfo,ticksize);
    hhupward = strcmpi(hhstatus,'upward');
    lldnward = strcmpi(llstatus,'dnward');
    
    %1b.HH is above TDST level-up
    %HH is also above alligator's teeth
    %the latest close price is still below HH
    %the alligator's lips is above alligator's teeth OR
    %HH is well above jaw
    %some of the last 2*nfracal candles' low price was below TDST level-up
    %some of the last 2*nfractal candles' close was below TDST level-up
    %i.e.not all candles above TDST level-up
    %if HH is breached, it shall also breach TDST level up
    hhabovelvlup = hh(end)>=lvlup(end) ...
        & hh(end)>teeth(end) ...
        & p(end,5)<hh(end) ...
        & p(end,5)<=lvlup(end) ...
        & (lips(end)>teeth(end) || (lips(end)<=teeth(end) && hh(end)>jaw(end))) ...
        & ~isempty(find(p(end-2*nfractal+1:end,4)-lvlup(end)+2*ticksize<0,1,'first')) ...
        & ~isempty(find(p(end-2*nfractal+1:end,5)-lvlup(end)+2*ticksize<0,1,'first')) ...
        & tick(4) >= min(lips(end),teeth(end));
    if hhabovelvlup
        if p(end,5)<=lvlup(end)
            hhabovelvlup = true;
        else
            hhabovelvlup = ss(end)>1 & ss(end)<9 & ~isempty(find(p(end-ss(end)+1:end,5)-lvlup(end)+ticksize<0,1,'first'));
        end
    end   
    if ~hhabovelvlup && p(end,5) < hh(end) && p(end,5)<=lvlup(end)
        sslast = find(ss==9,1,'last');
        if ~isempty(sslast)
            sslastval = ss(sslast);
            for kk = sslast+1:size(ss,1)
                if ss(kk) == 0
                    sslast = kk-1;
                    sslastval = ss(sslast);
                    break
                end
            end
            sshigh = max(p(sslast-sslastval+1:sslast,3));
            if hh(end)>=sshigh && hh(end)>=lvlup(end) && tick(4) >= min(lips(end),teeth(end))
                hhabovelvlup = true;
            end
        end
    end
    %the latest HH is above the previous, indicating an
    %upper-trend
    if hhabovelvlup
        if ~hhupward
            %we regard the upper trend is valid if nfractal+1
            %candle close above the alligator's lips
            hhabovelvlup = isempty(find(p(end-nfractal:end,5)-lips(end-nfractal:end)+2*ticksize<0,1,'first'));
            %also need at least nfractal+1 alligator's lips
            %above teeth
            hhabovelvlup = hhabovelvlup & isempty(find(lips(end-nfractal:end)-teeth(end-nfractal:end)+ticksize<0,1,'first'));
        end
        if ~hhabovelvlup && ss(end) >= 4
            hhabovelvlup = isempty(find(p(end-ss(end)+1:end,5)-lips(end-ss(end)+1:end)<0,1,'first'));
        end
    end
    if hhabovelvlup
        if lvlup(end) > lvldn(end)
            hhabovelvlup = p(end,3) >= lvldn(end);
        end
    end
    %
    %1c.HH is below TDST level up
    %HH is also above alligator's teeth
    %the alligator's lips is above alligator's teeth
    %the latest close price is still below HH
    hhbelowlvlup = hh(end)<lvlup(end) ...
        & hh(end)>teeth(end) ...
        & lips(end)>teeth(end) ...
        & p(end,5)<hh(end) ...
        & p(end,5)>teeth(end);
    
    if ~hhabovelvlup
        %we shall withdraw any pending conditional entrsut with
        %mode 'conditional-breachup'
        if ~hhbelowlvlup
            ne = stratfractal.helper_.condentrustspending_.latest;
            condentrusts2remove = EntrustArray;
            for jj = 1:ne
                e = stratfractal.helper_.condentrustspending_.node(jj);
                if e.offsetFlag ~= 1, continue; end
                if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                if ~strcmpi(e.signalinfo_.mode,'conditional-breachuplvlup'),continue;end
                condentrusts2remove.push(e);
            end
            if condentrusts2remove.latest > 0
                stratfractal.removecondentrusts(condentrusts2remove);
                fprintf('\t%s:conditional-breachuplvlup cancled as fractal hh is not above lvlup....\n',instrument.code_ctp);
            end
        else
            if ~isempty(status) && ~status.istrendconfirmed
                vlookuptbl = kellytable.breachuplvlup_tb;
                idx = strcmpi(vlookuptbl.asset,assetname);
                try
                    kelly = vlookuptbl.K(idx);
                    wprob = vlookuptbl.W(idx);
                    if isempty(kelly)
                        kelly = -9.99;
                        wprob = 0;
                    end
                catch
                    kelly = -9.99;
                    wprob = 0;
                end
                if kelly < 0.4
                    ne = stratfractal.helper_.condentrustspending_.latest;
                    condentrusts2remove = EntrustArray;
                    for jj = 1:ne
                        e = stratfractal.helper_.condentrustspending_.node(jj);
                        if e.offsetFlag ~= 1, continue; end
                        if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                        if ~strcmpi(e.signalinfo_.mode,'conditional-breachuplvlup'),continue;end
                        condentrusts2remove.push(e);
                    end
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    try
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                    catch
                        kelly = -9.99;
                        wprob = 0;
                    end
                    if kelly < 0.4
                        ne = stratfractal.helper_.condentrustspending_.latest;
                        condentrusts2remove = EntrustArray;
                        for jj = 1:ne
                            e = stratfractal.helper_.condentrustspending_.node(jj);
                            if e.offsetFlag ~= 1, continue; end
                            if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                            if ~strcmpi(e.signalinfo_.mode,'conditional-breachuplvlup'),continue;end
                            condentrusts2remove.push(e);
                        end
                        if condentrusts2remove.latest > 0
                            stratfractal.removecondentrusts(condentrusts2remove);
                            fprintf('\t%s:conditional-breachuplvlup cancled as kelly is below 0.4....\n',instrument.code_ctp);
                        end
                    end
                end
            end
        end
    end
    
    if ~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,1}) && signal_cond_i{1,1}(1) == 1 && p(end,5) > teeth(end)
        %TREND has priority over TDST breakout
        %note:20211118
        %it is necessary to withdraw pending conditional
        %entrust with higher price to long
        ne = stratfractal.helper_.condentrustspending_.latest;
        if ne > 0
            condentrusts2remove = EntrustArray;
            for jj = 1:ne
                e = stratfractal.helper_.condentrustspending_.node(jj);
                if e.offsetFlag ~= 1, continue; end
                if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                if e.direction ~= 1, continue;end %the same direction
                if e.price <= hh(end)+ticksize,continue;end
                %if the code reaches here, the existing entrust shall be canceled
                condentrusts2remove.push(e);
            end
            if condentrusts2remove.latest > 0
                stratfractal.removecondentrusts(condentrusts2remove);
            end
        end
        %
        if p(end,5) < lips(end) && hh(end) < lips(end) && ~isnan(lvlup(end)) && p(end,5) < lvlup(end)
            signal_cond_i{1,1}(1) = 0;
            if isbreachuplvlup
                fprintf('\t%6s:%4s\t%10s\n',instrument.code_ctp,num2str(0),'conditional:breachup-lvlup-tc not to placed as price and hh is below lips...');
            elseif isbreachupsshigh
                fprintf('\t%6s:%4s\t%10s\n',instrument.code_ctp,num2str(0),'conditional:breachup-sshighvalue-tc not to placed as price and hh is below lips...');
            elseif isbreachupschigh
                fprintf('\t%6s:%4s\t%10s\n',instrument.code_ctp,num2str(0),'conditional:breachup-highsc13-tc not to placed as price and hh is below lips...');
            else
                fprintf('\t%6s:%4s\t%10s\n',instrument.code_ctp,num2str(0),[op_cond_i{1,1},' not to placed as price and hh is below lips...']);
            end
        end
        %
        signals{1,1} = signal_cond_i{1,1};
        if signal_cond_i{1,1}(1)
            if isbreachuplvlup
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(1),'conditional:breachup-lvlup-tc',100*kelly,100*wprob);
            elseif isbreachupsshigh
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(1),'conditional:breachup-sshighvalue-tc',100*kelly,100*wprob);
            elseif isbreachupschigh
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(1),'conditional:breachup-highsc13',100*kelly,100*wprob);
            else
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(1),op_cond_i{1,1},100*kelly,100*wprob);
            end
        end
    elseif ~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,1}) && signal_cond_i{1,1}(1) == 0 && p(end,5) > teeth(end)
        if hhbelowlvlup
            vlookuptbl = kellytable.breachuplvlup_tc_all;
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly)
                kelly = -9.99;
                wprob = 0;
            end
            if kelly > 0.3 && wprob > 0.5
                signal_cond_i{1,1}(1) = 1;
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(1),'conditional:breachup-lvlup-tc',100*kelly,100*wprob);
            end
            signals{1,1} = signal_cond_i{1,1};
        end
    elseif ~(~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,1}))
        if hhabovelvlup
%             vlookuptbl = kellytable.breachuplvlup_tb;
%             idx = strcmpi(vlookuptbl.asset,assetname);
%             try
%                 kelly = vlookuptbl.K(idx);
%                 wprob = vlookuptbl.W(idx);
%                 if isempty(kelly)
%                     kelly = -9.99;
%                     wprob = 0;
%                 end
%             catch
%                 kelly = -9.99;
%                 wprob = 0;
%             end
%             %here we change rule for breachup-lvlup
%             %generally we take it as kelly is greater than 0.145
%             if kelly >= 0.145 && wprob >= 0.41
%                 this_signal = zeros(1,7);
%                 this_signal(1,1) = 1;
%                 this_signal(1,2) = hh(end);                             %HH is already above TDST-lvlup
%                 this_signal(1,3) = ll(end);
%                 this_signal(1,5) = p(end,3);
%                 this_signal(1,6) = p(end,4);
%                 this_signal(1,7) = lips(end);
%                 this_signal(1,4) = 4;
%                 fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(1),'conditional:breachup-lvlup',100*kelly,100*wprob);
%                 signals{1,1} = this_signal;
%             end
        elseif hhbelowlvlup && (p(end,3)>lvldn(end) || isnan(lvldn(end)))
%             vlookuptbl = kellytable.breachuplvlup_tb;
%             idx = strcmpi(vlookuptbl.asset,assetname);
%             try
%                 kelly = vlookuptbl.K(idx);
%                 wprob = vlookuptbl.W(idx);
%                 if isempty(kelly)
%                     kelly = -9.99;
%                     wprob = 0;
%                 end
%             catch
%                 kelly = -9.99;
%                 wprob = 0;
%             end
%             if kelly > 0.3 && wprob > 0.5
%                 this_signal = zeros(1,7);
%                 this_signal(1,1) = 1;
%                 this_signal(1,2) = lvlup(end);                          %HH is still below TDST-lvlup
%                 this_signal(1,3) = ll(end);
%                 this_signal(1,5) = p(end,3);
%                 this_signal(1,6) = p(end,4);
%                 this_signal(1,7) = lips(end);
%                 this_signal(1,4) = 4;
%                 fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(1),'conditional:breachup-lvlup',100*kelly,100*wprob);
%                 signals{1,1} = this_signal;
%             end
        end
    end
    %
    %
    %2b.LL is below TDST level-dn
    %LL is also below alligator's teeth
    %the latest close price is still above LL
    %the alligator's lips is below alligator's teeth
    %some of the latest 2*nfractal candle's high price was
    %above TDST level-dn
    llbelowlvldn = ll(end)<=lvldn(end) ...
        & ll(end)<teeth(end) ...
        & p(end,5)>ll(end) ...
        & p(end,5)>=lvldn(end) ...
        & lips(end)<teeth(end) ...
        & ~isempty(find(lvldn(end)-p(end-2*nfractal+1:end,3)+2*ticksize<0,1,'first'))...
        & ~isempty(find(lvldn(end)-p(end-2*nfractal+1:end,5)+2*ticksize<0,1,'first')) ...
        & tick(4) <= max(lips(end),teeth(end));
    if ~llbelowlvldn && p(end,5) > ll(end) && p(end,5)>=lvldn(end)
        bslast = find(bs==9,1,'last');
        if ~isempty(bslast)
            bslastval = bs(bslast);
            for kk = bslast+1:size(bs,1)
                if bs(kk) == 0
                    bslast = kk-1;
                    bslastval = bs(bslast);
                    break
                end
            end
            bslow = min(p(bslast-bslastval+1:bslast,4));
            if ll(end) <= bslow && ll(end)<=lvldn(end) && tick(4) <= max(lips(end),teeth(end))
                llbelowlvldn = true;
            end
        end
    end
    
    %the latest LL is below the previous, indicating a
    %down-trend
    if llbelowlvldn
        if ~lldnward
            %we regard the down trend is valid if nfractal+1
            %candle close below the alligator's lips
            llbelowlvldn = isempty(find(p(end-nfractal:end,5)-lips(end-nfractal:end)-2*ticksize>0,1,'first'));
            %also need at least nfractal+1 alligator's lips
            %below teeth
            llbelowlvldn = llbelowlvldn & isempty(find(lips(end-nfractal:end)-teeth(end-nfractal:end)-ticksize>0,1,'first'));
        end
    end
    if llbelowlvldn
        if lvlup(end) > lvldn(end)
            llbelowlvldn = p(end,4) <= lvlup(end);
        end
    end
    if ~llbelowlvldn
        %we shall withdraw any pending conditional entrust with
        %mode 'conditional-breachdn'
        ne = stratfractal.helper_.condentrustspending_.latest;
        condentrusts2remove = EntrustArray;
        for jj = 1:ne
            e = stratfractal.helper_.condentrustspending_.node(jj);
            if e.offsetFlag ~= 1, continue; end
            if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
            if ~strcmpi(e.signalinfo_.mode,'conditional-breachdnlvldn'),continue;end
            condentrusts2remove.push(e);
        end
        if condentrusts2remove.latest > 0
            stratfractal.removecondentrusts(condentrusts2remove);
            fprintf('\t%s:conditional-breachdnlvldn cancled as fractal ll is not below lvldn....\n',instrument.code_ctp);
        end
    end
    %
    %2c.LL is above TDST level dn
    %LL is also below alligator's teeth
    %the alligator's lips is below alligator's teeth
    %the latest close price is still above LL
    llabovelvldn = ll(end)>lvldn(end) ...
        & ll(end)<teeth(end) ...
        & lips(end)<teeth(end) -2*ticksize...
        & p(end,5)>ll(end);
    
    if ~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,2}) && signal_cond_i{1,2}(1) == -1 && p(end,5) < teeth(end)
        %TREND has priority over TDST breakout
        %note:20211118
        %it is necessary to withdraw pending conditional
        %entrust with lower price to short
        ne = stratfractal.helper_.condentrustspending_.latest;
        if ne > 0
            condentrusts2remove = EntrustArray;
            for jj = 1:ne
                e = stratfractal.helper_.condentrustspending_.node(jj);
                if e.offsetFlag ~= 1, continue; end
                if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                if e.direction ~= -1, continue;end %the same direction
                if e.price >= ll(end)-ticksize,continue;end
                %if the code reaches here, the existing entrust shall be canceled
                condentrusts2remove.push(e);
            end
            if condentrusts2remove.latest > 0
                stratfractal.removecondentrusts(condentrusts2remove);
            end
        end
        signals{1,2} = signal_cond_i{1,2};
        if isbreachdnlvldn
            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(-1),'conditional:breachdn-lvldn-tc',100*kelly,100*wprob);
        elseif isbreachdnbslow
            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(-1),'conditional:breachdn-bshighvalue-tc',100*kelly,100*wprob);
        elseif isbreachdnbclow
            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(-1),'conditional:breachdn-bclow13',100*kelly,100*wprob);
        else
            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(-1),op_cond_i{1,2},100*kelly,100*wprob);
        end
    elseif ~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,2}) && signal_cond_i{1,2}(1) == 0 && p(end,5) < teeth(end)
        if llabovelvldn
            vlookuptbl = kellytable.breachdnlvldn_tc_all;
            idx = strcmpi(vlookuptbl.asset,assetname);
            try
                kelly = vlookuptbl.K(idx);
                wprob = vlookuptbl.W(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                end
            catch
                kelly = -9.99;
                wprob = 0;
            end
            if kelly > 0.3 && wprob > 0.5
                signal_cond_i{1,2}(1) = -1;
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(-1),'conditional:breachdn-lvldn',100*kelly,100*wprob);
            end
            signals{1,2} = signal_cond_i{1,2};
        end
    elseif ~(~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,2}))
        %NOT BELOW TEETH
        if llbelowlvldn
%             vlookuptbl = kellytable.breachdnlvldn_tb;
%             idx = strcmpi(vlookuptbl.asset,assetname);
%             try
%                 kelly = vlookuptbl.K(idx);
%                 wprob = vlookuptbl.W(idx);
%                 if isempty(kelly)
%                     kelly = -9.99;
%                     wprob = 0;
%                 end
%             catch
%                 kelly = -9.99;
%                 wprob = 0;
%             end
%             if kelly >= 0.145 && wprob >= 0.41
%                 this_signal = zeros(1,7);
%                 this_signal(1,1) = -1;
%                 this_signal(1,2) = hh(end);
%                 this_signal(1,3) = ll(end);                         %LL is already below TDST-lvldn
%                 this_signal(1,5) = p(end,3);
%                 this_signal(1,6) = p(end,4);
%                 this_signal(1,7) = lips(end);
%                 this_signal(1,4) = -4;
%                 signals{1,2} = this_signal;
%                 fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(-1),'conditional:breachdn-lvldn',100*kelly,100*wprob);
%             end
            %                     elseif llabovelvldn && p(end,4)<lvlup(end)
        elseif llabovelvldn
%             sflag1 = isempty(find(p(end-2*nfractal+1:end,5)-...
%                 teeth(end-2*nfractal+1:end)-2*ticksize>0,1,'first')) &...
%                 p(end,5)<teeth(end) & ...
%                 lvldn(end) > 2*ll(end)-hh(end) & ...
%                 p(end,4) < lvlup(end);
%             if sflag1
%                 vlookuptbl = kellytable.breachdnlvldn_tc;
%                 idx = strcmpi(vlookuptbl.asset,assetname);
%                 try
%                     kelly = vlookuptbl.K(idx);
%                     wprob = vlookuptbl.W(idx);
%                     if isempty(kelly)
%                         kelly = -9.99;
%                         wprob = 0;
%                     end
%                 catch
%                     kelly = -9.99;
%                     wprob = 0;
%                 end
%                 if  kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41)
%                     this_signal = zeros(1,7);
%                     this_signal(1,1) = -1;
%                     this_signal(1,2) = hh(end);
%                     this_signal(1,3) = ll(end);
%                     this_signal(1,5) = p(end,3);
%                     this_signal(1,6) = p(end,4);
%                     this_signal(1,7) = lips(end);
%                     this_signal(1,4) = -4;
%                     signals{1,2} = this_signal;
%                     fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(-1),'conditional:breachdn-lvldn',100*kelly,100*wprob);
%                 end
%             end
        end
    end
end
            %

end