function [trade] = fractal_gentrade3_mt4(resstruct,code,idx,freq,nfractal,kellytables)

if strcmpi(freq,'30m')
%     nfractal = 4;
    tickratio = 0.5;
elseif strcmpi(freq,'15m')
%     nfractal = 4;
    tickratio = 0.5;
elseif strcmpi(freq,'5m')
%     nfractal = 6;
    tickratio = 0;
elseif strcmpi(freq,'1440m') || strcmpi(freq,'daily')
%     nfractal = 2;
    tickratio = 1;
else
%     nfractal = 4;
    tickratio = 0.5;
end

fut = code2instrument(code);

ei = fractal_truncate(resstruct,idx);
condsignal = fractal_signal_conditional2('extrainfo',ei,'ticksize',fut.tick_size,...
    'nfractal',nfractal,'kellytables',kellytables,'assetname',fut.asset_name,...
    'ticksizeratio',tickratio);

%1.first check whether kelly is big enough for place an conditional entrust
if isempty(condsignal)
    trade = {};
    return
end
%
%
if condsignal.directionkellied == 0
    trade = {};
    return
elseif condsignal.directionkellied == 1
    if condsignal.signalkellied(4) == 2
        td13high_ = NaN;
        td13low_ = NaN;
        tdlow_ = NaN;
        tdhigh_ = NaN;
        if condsignal.signalkellied(9) == 21
            mode = 'conditional-uptrendconfirmed-1';
        elseif condsignal.signalkellied(9) == 22
            mode = 'conditional-uptrendconfirmed-2';
            sslastidx = find(ei.ss>=9,1,'last');
            sslastval = ei.ss(sslastidx);
            tdhigh_ = max(ei.px(sslastidx-sslastval+1:sslastidx,3));
            tdidx_ = find(ei.px(sslastidx-sslastval+1:sslastidx,3) == tdhigh_,1,'last') + sslastidx-sslastval;
            tdlow_ = ei.px(tdidx_,4);
        elseif condsignal.signalkellied(9) == 23
            mode = 'conditional-uptrendconfirmed-3';
            sclastidx = find(ei.sc==13,1,'last');
            td13low_ = ei.px(sclastidx,4);
        else
            mode = 'conditional-uptrendconfirmed';
        end
        signalinfo = struct('name','fractal','type','breachup-B',...
            'hh', condsignal.signalkellied(2),...
            'll', condsignal.signalkellied(3),...
            'mode',mode,'nfractal',nfractal,...
            'frequency',freq,...
            'hh1', condsignal.signalkellied(5),...
            'll1', condsignal.signalkellied(6),...
            'kelly',condsignal.kelly);
        %
        riskmanager = struct('hh0_',signalinfo.hh,'hh1_',signalinfo.hh,...
            'll0_',signalinfo.ll,'ll1_',signalinfo.ll,...
            'type_','breachup-B',...
            'wadopen_',resstruct.wad(idx),...
            'cpopen_',resstruct.px(idx,5),'wadhigh_',resstruct.wad(idx),...
            'cphigh_',resstruct.px(idx,5),'wadlow_',resstruct.wad(idx),...
            'fibonacci1_',0.618*signalinfo.hh+0.382*signalinfo.hh1,...
            'fibonacci0_',signalinfo.ll,...
            'status_','unset',...
            'pxtarget_',-9.99,...
            'pxstoploss_',-9.99,...
            'tdlow_',tdlow_,...
            'tdhigh_',tdhigh_,...
            'td13high_',td13high_,...
            'td13low_',td13low_,...
            'closestr_','none');
        %
        if tickratio == 0
            tickratio_ = 0;
        else
            tickratio_ = 1;
        end
        %
        trade = cTradeOpen('id',idx,'code',code,...
            'opendatetime', resstruct.px(idx,1),...
            'openprice',condsignal.signalkellied(2)+tickratio_*fut.tick_size,...
            'opendirection',2,...
            'openvolume',1);
        trade.setsignalinfo('name','fractal','extrainfo',signalinfo);
        trade.setriskmanager('name','spiderman','extrainfo',riskmanager);
        trade.riskmanager_.setusefractalupdateflag(0);
        trade.riskmanager_.setusefibonacciflag(1);
        %
        trade.riskmanager_.pxstoploss_ = floor(resstruct.teeth(idx-1)/fut.tick_size)*fut.tick_size;
        trade.riskmanager_.closestr_ = 'fractal:teeth';
        %
        trade.status_ = 'unset';
        trade.riskmanager_.status_ = 'unset';
    elseif condsignal.signalkellied(4) ~= 2
        error('not implemented yet!!!')
    end
elseif condsignal.directionkellied == -1
    if condsignal.signalkellied(4) == -2
        td13high_ = NaN;
        td13low_ = NaN;
        tdlow_ = NaN;
        tdhigh_ = NaN;
        if condsignal.signalkellied(9) == -21
            mode = 'conditional-dntrendconfirmed-1';
        elseif condsignal.signalkellied(9) == -22
            mode = 'conditional-dntrendconfirmed-2';
            bslastidx = find(ei.bs>=9,1,'last');
            bslastval = ei.bs(bslastidx);
            tdlow_ = min(ei.px(bslastidx-bslastval+1:bslastidx,4));
            tdidx_ = find(ei.px(bslastidx-bslastval+1:bslastidx,4) == tdlow_,1,'last') + bslastidx-bslastval;
            tdhigh_ = ei.px(tdidx_,3);
        elseif condsignal.signalkellied(9) == -23
            mode = 'conditional-dntrendconfirmed-3';
            bclastidx = find(ei.bc==13,1,'last');
            td13high_ = ei.px(bclastidx,3);
        else
            mode = 'conditional-dntrendconfirmed';
        end
        signalinfo = struct('name','fractal','type','breachdn-S',...
            'hh', condsignal.signalkellied(2),...
            'll', condsignal.signalkellied(3),...
            'mode',mode,'nfractal',nfractal,...
            'frequency',freq,...
            'hh1', condsignal.signalkellied(5),...
            'll1', condsignal.signalkellied(6),...
            'kelly',condsignal.kelly);
        %
        riskmanager = struct('hh0_',signalinfo.hh,'hh1_',signalinfo.hh,...
            'll0_',signalinfo.ll,'ll1_',signalinfo.ll,...
            'type_','breachdn-S',...
            'wadopen_',resstruct.wad(idx),...
            'cpopen_',resstruct.px(idx,5),'wadhigh_',resstruct.wad(idx),...
            'cphigh_',resstruct.px(idx,5),'wadlow_',resstruct.wad(idx),...
            'cplow_',resstruct.px(idx,5),...
            'fibonacci1_',signalinfo.hh,...
            'fibonacci0_',0.618*signalinfo.ll+0.382*signalinfo.ll1,...
            'status_','unset',...
            'pxtarget_',-9.99,...
            'pxstoploss_',-9.99,...
            'tdlow_',tdlow_,...
            'tdhigh_',tdhigh_,...
            'td13high_',td13high_,...
            'td13low_',td13low_,...
            'closestr_','none');
        %
        if tickratio == 0
            tickratio_ = 0;
        else
            tickratio_ = 1;
        end
       %
        trade = cTradeOpen('id',idx,'code',code,...
            'opendatetime', resstruct.px(idx,1),...
            'openprice',condsignal.signalkellied(3)-tickratio_*fut.tick_size,...
            'opendirection',-2,...
            'openvolume',1);
        trade.setsignalinfo('name','fractal','extrainfo',signalinfo);
        trade.setriskmanager('name','spiderman','extrainfo',riskmanager);
        trade.riskmanager_.setusefractalupdateflag(0);
        trade.riskmanager_.setusefibonacciflag(1);
        %
        trade.riskmanager_.pxstoploss_ = ceil(resstruct.teeth(idx)/fut.tick_size)*fut.tick_size;
        trade.riskmanager_.closestr_ = 'fractal:teeth';
        %
        trade.status_ = 'unset';
        trade.riskmanager_.status_ = 'unset';
    elseif condsignal.signalkellied(4) ~= -2
        error('not implemented yet!!!')
    end
end
    
    
end






