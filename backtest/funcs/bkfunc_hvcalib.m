function [res] = bkfunc_hvcalib(ret,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('ForecastPeriod',144,@isnumeric);
    p.addParameter('PrintResults',false,@islogical);
    p.addParameter('PlotConditonalVariance',false,@islogical);
    p.addParameter('ScaleFactor',1,@isnumeric);
    p.parse(varargin{:});
    printResults = p.Results.PrintResults;
    nForecastPeriod = p.Results.ForecastPeriod;
    plotConditionalVariance = p.Results.PlotConditonalVariance;
    scaleFactor = p.Results.ScaleFactor;
    
    model = arima('ARLags',1,'Variance',garch(1,1));
    modelEstimate = estimate(model,ret(:,end),'print',printResults);
    paramGarch = modelEstimate.Variance.GARCH{1};
    paramArch = modelEstimate.Variance.ARCH{1};
    paramConst = modelEstimate.Variance.Constant;
    lv = sqrt(paramConst/(1-paramGarch-paramArch));
    [E0,V0,~] = infer(modelEstimate,ret(:,end));
    [Y,YMSE,V] = forecast(modelEstimate,nForecastPeriod,'Y0',ret(:,end),'E0',E0,'V0',V0);
    upper = Y + 1.96*sqrt(YMSE);
    lower = Y - 1.96*sqrt(YMSE);
    fv = sqrt(sum(V)/nForecastPeriod);
    
    hv = std(ret(end-nForecastPeriod+1:end,end));
    lambda = modelEstimate.Variance.GARCH{1};
    ewmav = abs(ret(end-nForecastPeriod+1,end));
    for i = 2:nForecastPeriod
        ewmav = ewmav^2*lambda+ret(end-nForecastPeriod+i,end)^2*(1-lambda);
        ewmav = sqrt(ewmav);
    end
    
    res = struct('LongTermVol',lv*scaleFactor,...
        'HistoricalVol',hv*scaleFactor,...
        'EWMAVol',ewmav*scaleFactor,...
        'ForecastedVol',fv*scaleFactor,...
        'ForecastedVariance',V,...
        'ForecastedReturn',Y,...
        'ForecastedReturnError',YMSE,...
        'VaRdn',quantile(ret(:,end),0.005),...
        'VaRup',quantile(ret(:,end),0.995));
    
    if plotConditionalVariance
        N = size(E0,1);
        figure
        subplot(2,1,1)
        plot(E0,'Color',[.75,.75,.75])
        hold on
        plot(N+1:N+nForecastPeriod,Y,'r','LineWidth',2)
        plot(N+1:N+nForecastPeriod,[upper,lower],'k--','LineWidth',1.5)
        xlim([0,N+nForecastPeriod])
%         title(['Forecasted Returns (',assetName,')'])
        hold off
        %
        xgrid = get(gca,'XTick');
        xgrid = xgrid';
        idx = xgrid < N;
        xgrid = xgrid(idx,:);
        t_num = zeros(1,length(xgrid));
        for i = 1:length(t_num)
            if xgrid(i) == 0
                t_num(i) = ret(1,1);
            elseif xgrid(i) > size(ret,1)
                t_start = ret(1,1);
                t_last = ret(end,1);
                t_num(i) = t_last + (xgrid(i)-size(ret,1))*...
                    (t_last - t_start)/size(ret,1);
            else
                t_num(i) = ret(xgrid(i),1);
            end
        end
        t_str = datestr(t_num,'mmm-yy');
        set(gca,'XTick',xgrid);
        set(gca,'XTickLabel',t_str);
        %
        subplot(2,1,2)
        plot(V0,'Color',[.75,.75,.75])
        hold on
        plot(N+1:N+nForecastPeriod,V,'r','LineWidth',2);
        xlim([0,N+nForecastPeriod])
%         title(['Forecasted Conditional Variances (',assetName,')'])
        hold off
        %
        xgrid = get(gca,'XTick');
        xgrid = xgrid';
        idx = xgrid < N;
        xgrid = xgrid(idx,:);
        t_num = zeros(1,length(xgrid));
        for i = 1:length(t_num)
            if xgrid(i) == 0
                t_num(i) = ret(1,1);
            elseif xgrid(i) > size(ret,1)
                t_start = ret(1,1);
                t_last = ret(end,1);
                t_num(i) = t_last + (xgrid(i)-size(ret,1))*...
                    (t_last - t_start)/size(ret,1);
            else
                t_num(i) = ret(xgrid(i),1);
            end
        end
        t_str = datestr(t_num,'mmm-yy');
        set(gca,'XTick',xgrid);
        set(gca,'XTickLabel',t_str);
        %
    end
    
end