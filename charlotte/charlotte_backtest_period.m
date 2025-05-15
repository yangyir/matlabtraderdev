function [unwindedtrades,carriedtrades,tbl2check] = charlotte_backtest_period(varargin)
%function to run the backest for an instrument within a specified period of
%time
p = inputParser;
p.addParameter('code','',@ischar);
p.addParameter('frequency','30m',@ischar);
p.addParameter('nfractal',[],@isnumeric);
p.addParameter('fromdate','',@ischar);
p.addParameter('todate','',@ischar);
p.addParameter('kellytables','',@isstruct);
p.addParameter('showlogs',true,@islogical);
p.addParameter('figureidx',4,@isnumeric);
p.addParameter('doplot',true,@islogical);
p.parse(varargin{:});
codein = p.Results.code;
freq = p.Results.frequency;
nfractal = p.Results.nfractal;
if strcmpi(freq,'30m') || strcmpi(freq,'15m') || strcmpi(freq,'m30') || strcmpi(freq,'m15')
    if isempty(nfractal), nfractal = 4;end
    tickratio = 0.5;
elseif strcmpi(freq,'5m') || strcmpi(freq,'m5')
    if isempty(nfractal), nfractal = 6;end
    tickratio = 0;
elseif strcmpi(freq,'daily') || strcmpi(freq,'1440m')
    if isempty(nfractal), nfractal = 2;end
    tickratio = 1;
else
    %default
    if isempty(nfractal), nfractal = 4;end
    tickratio = 0.5;
end
dt1 = p.Results.fromdate;
dt2 = p.Results.todate;
kellytables = p.Results.kellytables;
showlogsflag = p.Results.showlogs;
figureidx = p.Results.figureidx;
doplot = p.Results.doplot;
%
dt1 = datenum(dt1,'yyyy-mm-dd');
dt2 = datenum(dt2,'yyyy-mm-dd');
%
if isfx(codein)
    dt3 = [datestr(dt1,'yyyy-mm-dd'),' 00:00:00'];
    dt4 = [datestr(dt2,'yyyy-mm-dd'),' 23:59:59'];
elseif isinequitypool(codein)
    dt3 = [datestr(dt1,'yyyy-mm-dd'),' 00:00:00'];
    dt4 = [datestr(dt2,'yyyy-mm-dd'),' 23:59:59'];
else
    dt3 = [datestr(dt1,'yyyy-mm-dd'),' 09:00:00'];
    dt4 = [datestr(dateadd(dt2,'1d'),'yyyy-mm-dd'),' 02:30:00'];
end

fut = code2instrument(codein);
if isfx(codein)
    plotshift = 2*fut.tick_size;
else
    plotshift = 0.005;
end
resstruct = charlotte_plot('futcode',codein,'figureindex',figureidx,'datefrom',dt3,'dateto',dt4,'frequency',freq,'doplot',doplot,'plotshift',plotshift);
if doplot
    grid off;
end


if showlogsflag
    fprintf('\n\n');
    idxstart = find(resstruct.px(:,1) >= datenum(dt3,'yyyy-mm-dd HH:MM'),1,'first');
    idxend = find(resstruct.px(:,1) <= datenum(dt4,'yyyy-mm-dd HH:MM'),1,'last');
    for i = idxstart:idxend
        %1st check whether is any conditional open entrust
        ei1 = fractal_truncate(resstruct,i-1);
        ei2 = fractal_truncate(resstruct,i);
        output1 = fractal_signal_conditional2('extrainfo',ei1,...
            'nfractal',nfractal,...
            'ticksize',fut.tick_size,...
            'kellytables',kellytables,...
            'assetname',fut.asset_name,...
            'ticksizeratio',tickratio);
        output2 = fractal_signal_conditional2('extrainfo',ei2,...
            'nfractal',nfractal,...
            'ticksize',fut.tick_size,...
            'kellytables',kellytables,...
            'assetname',fut.asset_name,...
            'ticksizeratio',tickratio);
        %
        if ~isempty(output1)
            if output1.directionkellied == 1
                %up-trend conditional signal
                if ei2.px(end,3) > output1.signal{1,1}(2)
                    if ei2.px(end,5) - output1.signal{1,1}(2) - tickratio * fut.tick_size >= -1e-6
                        signaluncond = fractal_signal_unconditional2('extrainfo',ei2,...
                            'ticksize',fut.tick_size,...
                            'nfractal',nfractal,...
                            'assetname',fut.asset_name,...
                            'kellytables',kellytables,...
                            'ticksizeratio',tickratio);
                        if ~isempty(signaluncond)
                            fprintf('%6s:\t%s:%2d\t%s with %s:%2.1f%%\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),signaluncond.directionkellied,[output1.opkellied,' success'],signaluncond.op.comment,100*signaluncond.kelly);
                        else
                            %there was not a valid breach,i.e.the fractal hh
                            %was updated
                            fprintf('%6s:\t%s:%2d\t%s but invalid...\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),1,[output1.opkellied,' success']);
                        end
                    else
                        fprintf('%6s:\t%s:%2d\t%s\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),output1.directionkellied,[output1.opkellied,' failed...']);
                    end
                else
                    if ~isempty(output2)
                        fprintf('%6s:\t%s:%2d\t%s:%2.1f%%\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),output2.directionkellied,output2.opkellied,100*output2.kelly);
                    else
                        signaluncond = fractal_signal_unconditional2('extrainfo',ei2,...
                            'ticksize',fut.tick_size,...
                            'nfractal',nfractal,...
                            'assetname',fut.asset_name,...
                            'kellytables',kellytables,...
                            'ticksizeratio',tickratio);
                        if ~isempty(signaluncond)
                            fprintf('%6s:\t%s:%2d\t%s:%2.1f%%\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),signaluncond.directionkellied,signaluncond.op.comment,100*signaluncond.kelly);
                        else
                            fprintf('%6s:\t%s:%2d\t%s\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),0,'no signal');
                        end
                    end
                end
            elseif output1.directionkellied == -1
                %dn-trend conditional signal
                if ei2.px(end,4) < output1.signal{1,2}(3)
                    if ei2.px(end,5) - output1.signal{1,2}(3) + tickratio * fut.tick_size <= 1e-6
                        signaluncond = fractal_signal_unconditional2('extrainfo',ei2,...
                            'ticksize',fut.tick_size,...
                            'nfractal',nfractal,...
                            'assetname',fut.asset_name,...
                            'kellytables',kellytables,...
                            'ticksizeratio',tickratio);
                        if ~isempty(signaluncond)
                            fprintf('%6s:\t%s:%2d\t%s with %s:%2.1f%%\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),signaluncond.directionkellied,[output1.opkellied,' success'],signaluncond.op.comment,100*signaluncond.kelly);
                        else
                            %there was not a valid breach,i.e.the fractal ll
                            %was updated
                            fprintf('%6s:\t%s:%2d\t%s but invalid as ll updates...\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),-1,[output1.opkellied,' success']);
                        end
                    else
                        fprintf('%6s:\t%s:%2d\t%s\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),output1.directionkellied,[output1.opkellied,' failed...']);
                    end
                else
                    if ~isempty(output2)
                        fprintf('%6s:\t%s:%2d\t%s:%2.1f%%\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),output2.directionkellied,output2.opkellied,100*output2.kelly);
                    else
                        signaluncond = fractal_signal_unconditional2('extrainfo',ei2,...
                            'ticksize',fut.tick_size,...
                            'nfractal',nfractal,...
                            'assetname',fut.asset_name,...
                            'kellytables',kellytables,...
                            'ticksizeratio',tickratio);
                        if ~isempty(signaluncond)
                            fprintf('%6s:\t%s:%2d\t%s:%2.1f%%\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),signaluncond.directionkellied,signaluncond.op.comment,100*signaluncond.kelly);
                        else
                            fprintf('%6s:\t%s:%2d\t%s\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),0,'no signal');
                        end
                    end
                end
            elseif output1.directionkellied == 0
                %conditional signal with insuffient conditions to be placed
                if ~isempty(output2)
                    fprintf('%6s:\t%s:%2d\t%s:%2.1f%%\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),output2.directionkellied,output2.opkellied,100*output2.kelly);
                else
                    signaluncond = fractal_signal_unconditional2('extrainfo',ei2,...
                        'ticksize',fut.tick_size,...
                        'nfractal',nfractal,...
                        'assetname',fut.asset_name,...
                        'kellytables',kellytables,...
                        'ticksizeratio',tickratio);
                
                    if ~isempty(signaluncond)
                        fprintf('%6s:\t%s:%2d\t%s:%2.1f%%\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),signaluncond.directionkellied,signaluncond.op.comment,100*signaluncond.kelly);
                    else
                        fprintf('%6s:\t%s:%2d\t%s\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),0,'no signal');
                    end
                end
                
            end
        else
            %no conditional signal was placed before-hand
            signaluncond = fractal_signal_unconditional2('extrainfo',ei2,...
                'ticksize',fut.tick_size,...
                'nfractal',nfractal,...
                'assetname',fut.asset_name,...
                'kellytables',kellytables,...
                'ticksizeratio',tickratio);
            if isempty(signaluncond)
                if ~isempty(output2)
                    fprintf('%6s:\t%s:%2d\t%s:%2.1f%%\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),output2.directionkellied,output2.opkellied,100*output2.kelly);
                else
                    fprintf('%6s:\t%s:%2d\t%s\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),0,'no signal');
                end
            else
                fprintf('%6s:\t%s:%2d\t%s:%2.1f%%\n',codein,datestr(ei2.px(end,1),'yyyy-mm-dd HH:MM'),signaluncond.directionkellied,signaluncond.opkellied,100*signaluncond.kelly);
            end
        end
    end
end
    
%
%
if ~isfx(codein)
    dts = gendates('fromdate',dt1,'todate',dt2);
else
    idxstart = find(resstruct.px(:,1) >= datenum(dt3,'yyyy-mm-dd HH:MM'),1,'first');
    idxend = find(resstruct.px(:,1) <= datenum(dt4,'yyyy-mm-dd HH:MM'),1,'last');
    dts = resstruct.px(idxstart:idxend,1);
    if ~(strcmpi(freq,'daily') || strcmpi(freq,'1440m'))
        dts = floor(dts);
        dts = unique(dts);
    end
    
end
unwindedtrades = cTradeOpenArray;
carriedtrades = cTradeOpenArray;

for i = 1:length(dts)
    if i == 1
        [~,ct_i,ut_i] = charlotte_backtest_daily('code',codein,'date',datestr(dts(i),'yyyy-mm-dd'),'frequency',freq,'nfractal',nfractal,'kellytables',kellytables);
    else
        if ct_i.latest_ > 0
            carriedtrade = ct_i.node_(1);
            [~,ct_i,ut_i] = charlotte_backtest_daily('code',codein,'date',datestr(dts(i),'yyyy-mm-dd'),'frequency',freq,'nfractal',nfractal,'carriedtrade',carriedtrade,'kellytables',kellytables);
        else
            [~,ct_i,ut_i] = charlotte_backtest_daily('code',codein,'date',datestr(dts(i),'yyyy-mm-dd'),'frequency',freq,'nfractal',nfractal,'kellytables',kellytables);
        end     
    end
    for j = 1:ut_i.latest_
        unwindedtrades.push(ut_i.node_(j));
    end
    if i == length(dts)
        for j = 1:ct_i.latest_
            carriedtrades.push(ct_i.node_(j));
        end
    end
end
%print backtest trades results
if showlogsflag
    fprintf('\n');
end
if unwindedtrades.latest_ == 0 &&  carriedtrades.latest_ == 0
    if showlogsflag,fprintf('there were no trades...\n');end
    tbl2check = {};
else
    n = unwindedtrades.latest_;
    code = cell(n,1);
    direction = zeros(n,1);
    opendatetime = cell(n,1);
    openprice = zeros(n,1);
    closedatetime = cell(n,1);
    closeprice = zeros(n,1);
    opensignal = cell(n,1);
    closestr = cell(n,1);
    closepnl = zeros(n,1);
    opennotional = zeros(n,1);
    pnlrel = zeros(n,1);
    if showlogsflag,fprintf('unwinded trades:\n');end
    for i = 1:n
        t_i = unwindedtrades.node_(i);
        if showlogsflag
            if ~isfx(t_i.code_)
                fprintf('\t%6s\t%3d\t%20s\t%3.3f\t%20s\t%3.3f\t%30s\t%40s\n',t_i.code_,t_i.opendirection_,t_i.opendatetime2_,t_i.openprice_,t_i.closedatetime2_,t_i.closeprice_,t_i.opensignal_.mode_,t_i.closestr_);
            else
                if strcmpi(t_i.code_,'xauusd') || strcmpi(t_i.code_,'xagusd')
                    fprintf('\t%6s\t%3d\t%20s\t%3.2f\t%20s\t%3.2f\t%30s\t%40s\n',t_i.code_,t_i.opendirection_,t_i.opendatetime2_,t_i.openprice_,t_i.closedatetime2_,t_i.closeprice_,t_i.opensignal_.mode_,t_i.closestr_);
                elseif strcmpi(t_i.code_,'usdjpy')
                    fprintf('\t%6s\t%3d\t%20s\t%3.3f\t%20s\t%3.3f\t%30s\t%40s\n',t_i.code_,t_i.opendirection_,t_i.opendatetime2_,t_i.openprice_,t_i.closedatetime2_,t_i.closeprice_,t_i.opensignal_.mode_,t_i.closestr_);
                else
                    fprintf('\t%6s\t%3d\t%20s\t%3.4f\t%20s\t%3.4f\t%30s\t%40s\n',t_i.code_,t_i.opendirection_,t_i.opendatetime2_,t_i.openprice_,t_i.closedatetime2_,t_i.closeprice_,t_i.opensignal_.mode_,t_i.closestr_);
                end
            end
        end
        code{i} = t_i.code_;
        direction(i) = t_i.opendirection_;
        opendatetime{i} = t_i.opendatetime2_;
        openprice(i) = t_i.openprice_;
        closedatetime{i} = t_i.closedatetime2_;
        closeprice(i) = t_i.closeprice_;
        opensignal{i} = t_i.opensignal_.mode_;
        closestr{i} = t_i.closestr_;
        closepnl(i) = t_i.closepnl_;
        opennotional(i) = t_i.openprice_*t_i.instrument_.contract_size;
        pnlrel(i) = closepnl(i)/opennotional(i);
    end
    tbl2check = table(code,direction,opendatetime,openprice,closedatetime,closeprice,opensignal,closestr,closepnl,pnlrel,opennotional);
    %
    if carriedtrades.latest_ > 0
        if showlogsflag, fprintf('carried trade:\n');end
        t_i = carriedtrades.node_(1);
        if showlogsflag
            if ~isfx(t_i.code_)
                fprintf('\t%6s\t%3d\t%20s\t%3.3f\t%20s\t%3.3f\t%30s\n',t_i.code_,t_i.opendirection_,t_i.opendatetime2_,t_i.openprice_,'still live',9.99,t_i.opensignal_.mode_);
            else
                if strcmpi(t_i.code_,'xauusd') || strcmpi(t_i.code_,'xagusd')
                    fprintf('\t%6s\t%3d\t%20s\t%3.2f\t%20s\t%3.2f\t%30s\n',t_i.code_,t_i.opendirection_,t_i.opendatetime2_,t_i.openprice_,'still live',9.99,t_i.opensignal_.mode_);
                elseif strcmpi(t_i.code_,'usdjpy')
                    fprintf('\t%6s\t%3d\t%20s\t%3.3f\t%20s\t%3.3f\t%30s\n',t_i.code_,t_i.opendirection_,t_i.opendatetime2_,t_i.openprice_,'still live',9.99,t_i.opensignal_.mode_);
                else
                    fprintf('\t%6s\t%3d\t%20s\t%3.4f\t%20s\t%3.4f\t%30s\n',t_i.code_,t_i.opendirection_,t_i.opendatetime2_,t_i.openprice_,'still live',9.99,t_i.opensignal_.mode_);
                end
            end
        end
    end
end
%
fprintf('charlotte_backtest_period accomplised on %6s between %s and %s...\n',codein,datestr(dt1,'yyyy-mm-dd'),datestr(dt2,'yyyy-mm-dd'));

end