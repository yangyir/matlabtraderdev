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
    kellytables = stratfractal.tbl_all_intraday_;
    if strcmpi(freq,'5m')
        tickratio = 0;
    elseif strcmpi(freq,'15m')
        tickratio = 0.5;
    elseif strcmpi(freq,'30m')
        tickratio = 0.5;
    else
        tickratio = 0.5;
    end
else
    kellytables = stratfractal.tbl_all_daily_;
    tickratio = 1;
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

extrainfo = struct('px',p,...
    'ss',ss,'sc',sc,...
    'bs',bs,'bc',bc,...
    'lvlup',lvlup,'lvldn',lvldn,...
    'idxhh',idxHH,'hh',hh,...
    'idxll',idxLL,'ll',ll,...
    'lips',lips,'teeth',teeth,'jaw',jaw,...
    'wad',wad);

signaluncond = fractal_signal_unconditional2('extrainfo',extrainfo,...
    'ticksize',ticksize,...
    'nfractal',nfractal,...
    'assetname',assetname,...
    'kellytables',kellytables,...
    'ticksizeratio',tickratio);

if ~isempty(signaluncond)
    if signaluncond.directionkellied == 1
        signal_i = signaluncond.signalkellied;
        if signaluncond.status.istrendconfirmed && ~stratfractal.helper_.book_.haslongposition(instrument)
            %long trend case with good kelly but lack of prop
            %position, we shall double check with its previous
            %conditional setup
            ei_ = fractal_truncate(extrainfo,size(extrainfo.px,1)-1);
            signalcond_ = fractal_signal_conditional2('extrainfo',ei_,...
                'ticksize',ticksize,...
                'nfractal',nfractal,...
                'assetname',assetname,...
                'kellytables',kellytables,...
                'ticksizeratio',tickratio);
            if ~isempty(signalcond_)
                if signalcond_.directionkellied ~= 0
                    fprintf('gensignalssingle:further check with weired case...\n')
                end
                %there was a conditional signal with low kelly
                signal_i(1) = 0;
                signal_i(4) = 0;
                signals{1,1} = signal_i;
                fprintf('\t%6s:%4s\tup conditional:%10s with low kelly\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(0),signalcond_.opkellied,100*signalcond_.kelly,100*signalcond_.wprob);
            else
                %there wasn't any conditional
                %signal,i.e.alligator lines crossed and etc
                signal_i(1) = 0;
                signal_i(4) = 0;
                signals{1,1} = signal_i;
                fprintf('\t%6s:%4s\tup conditional %10s was invalid\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(0),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
            end
        else
            signals{1,1} = signal_i;
            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(1),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
        end
        %
        %
    elseif signaluncond.directionkellied == -1
        signal_i = signaluncond.signalkellied;
        if signaluncond.status.istrendconfirmed && ~stratfractal.helper_.book_.hasshortposition(instrument)
            %short trend case with good kelly but lack of prop
            %position, we shall double check with its previous
            %conditional setup
            ei_ = fractal_truncate(extrainfo,size(extrainfo.px,1)-1);
            signalcond_ = fractal_signal_conditional2('extrainfo',ei_,...
                'ticksize',ticksize,...
                'nfractal',nfractal,...
                'assetname',assetname,...
                'kellytables',kellytables,...
                'ticksizeratio',tickratio);
            if ~isempty(signalcond_)
                if signalcond_.directionkellied ~= 0
                    fprintf('gensignal_futmultifractal1:further check with weired case...\n')
                end
                %there was a conditional signal with low kelly
                signal_i(1) = 0;
                signal_i(4) = 0;
                signals{1,1} = signal_i;
                fprintf('\t%6s:%4s\tdn conditional:%10s with low kelly\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(0),signalcond_.opkellied,100*signalcond_.kelly,100*signalcond_.wprob);
            else
                %there wasn't any conditional
                %signal,i.e.alligator lines crossed and etc
                signal_i(1) = 0;
                signal_i(4) = 0;
                signals{1,1} = signal_i;
                fprintf('\t%6s:%4s\tdn conditional %10s was invalid\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(0),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
            end
        else
            signals{1,2} = signal_i;
            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(-1),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
        end
        %
        %
    else
        stratfractal.unwindpositions(instrument,'closestr','kelly is too low');
        try
            stratfractal.processcondentrust(instrument,'techvar',techvar);
        catch e
            fprintf('processcondentrust called in gensignals but failed:%s\n', e.message);
            stratfractal.stop;
        end
        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(0),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
    end
    %
    %
else
    %EMPTY RETURNS FROM UNCONDITIONAL SIGNAL CALCULATION
    try
        stratfractal.processcondentrust(instrument,'techvar',techvar);
    catch e
        fprintf('processcondentrust called in gensignals but failed:%s\n', e.message);
        stratfractal.stop;
    end
    %
    %
    signalcond = fractal_signal_conditional2('extrainfo',extrainfo,...
        'nfractal',nfractal,...
        'ticksize',ticksize,...
        'assetname',assetname,...
        'kellytables',kellytables,...
        'ticksizeratio',tickratio);
    if ~isempty(signalcond)
        if signalcond.directionkellied == 1 && p(end,5) > teeth(end)
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
                    if tickratio == 0
                        if e.price <= signalcond.signalkellied(2),continue;end
                    else
                        if e.price <= signalcond.signalkellied(2)+ticksize,continue;end
                    end
                    %if the code reaches here, the existing entrust shall be canceled
                    condentrusts2remove.push(e);
                end
                if condentrusts2remove.latest > 0
                    stratfractal.removecondentrusts(condentrusts2remove);
                end
            end
            %
            signals{1,1} = signalcond.signalkellied;
            fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,1,signalcond.opkellied,100*signalcond.kelly,100*signalcond.wprob);
            %
        elseif signalcond.directionkellied == -1 && p(end,5) < teeth(end)
            %it is necessary to withdraw pending conditional
            %entrust with higher price to long
            ne = stratfractal.helper_.condentrustspending_.latest;
            if ne > 0
                condentrusts2remove = EntrustArray;
                for jj = 1:ne
                    e = stratfractal.helper_.condentrustspending_.node(jj);
                    if e.offsetFlag ~= 1, continue; end
                    if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                    if e.direction ~= -1, continue;end %the same direction
                    if tickratio == 0
                        if e.price >= signalcond.signalkellied(3),continue;end
                    else
                        if e.price >= signalcond.signalkellied(3)-ticksize,continue;end
                    end
                    %if the code reaches here, the existing entrust shall be canceled
                    condentrusts2remove.push(e);
                end
                if condentrusts2remove.latest > 0
                    stratfractal.removecondentrusts(condentrusts2remove);
                end
            end
            %
            signals{1,2} = signalcond.signalkellied;
            fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,-1,signalcond.opkellied,100*signalcond.kelly,100*signalcond.wprob);
            %
        else
            stratfractal.unwindpositions(instrument,'closestr','conditional kelly is too low');
            fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,0,signalcond.opkellied,100*signalcond.kelly,100*signalcond.wprob);
            %
            condentrusts2remove = EntrustArray;
            ne = stratfractal.helper_.condentrustspending_.latest;
            for jj = 1:ne
                e = stratfractal.helper_.condentrustspending_.node(jj);
                if e.offsetFlag ~= 1, continue; end
                if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                condentrusts2remove.push(e);
            end
            if condentrusts2remove.latest > 0
                stratfractal.removecondentrusts(condentrusts2remove);
                fprintf('\t%6s:%4s\t%10s cancled as new mode with low kelly....\n',instrument.code_ctp,num2str(0),signalcond.opkellied);
            end
        end
    else
        %EMPTY RETURNS FROM CONDITIONAL SIGNAL CALCULATION
        try
            stratfractal.processcondentrust(instrument,'techvar',techvar);
        catch e
            fprintf('processcondentrust called in gensignals but failed:%s\n', e.message);
            stratfractal.stop;
        end
    end
    %
end


end