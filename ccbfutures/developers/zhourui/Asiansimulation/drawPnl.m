function [ result ] = drawPnl( indexPercent,TotalPnl, UnderlyingPnl,OptionPnl,UnderlyingPath,Delta,PerdayPnl,TotalFee,StrikePath,AveragePath,p,RealUVol,cellTag)
    % 100% 75% 50% 25% 0%
    [row,~] = size(TotalPnl);
    if (cellTag == 0)
        col = length(TotalPnl(:,1));
        TotalPnlIndex = ones(length(TotalPnl(:,end)),2);
        TotalPnlIndex(:,2) = (1:1:length(TotalPnl(:,end)))';
        TotalPnlIndex(:,1) = TotalPnl(:,end);
        TotalPnlIndex = sortrows(TotalPnlIndex);
        % 100%
        t = max(floor(1 * indexPercent * col),1);
        tIndex = TotalPnlIndex(t,2);

        figure;

        subplot(2,2,1);
        hold on;
        p1 = plot(TotalPnl(tIndex,:));
        p2 = plot(UnderlyingPnl(tIndex,:));
        p3 = plot(OptionPnl(tIndex,:));
        reaVolativity = RealUVol(tIndex);
        hold off;
        titlestr = strcat(' percent ',num2str(indexPercent*100),'% TotalPnl= ',num2str(TotalPnl(tIndex,end)),' TotalFee=',num2str(TotalFee(tIndex)) , ' RV: ' ,num2str(reaVolativity));

        title(titlestr);
        legend([p1,p2,p3],'TotalPnl','UnderlyingPnl','OptionPnl');

        subplot(2,2,2);
        hold on;
        p1 = plot(UnderlyingPath(tIndex,:));
        p2 = plot(StrikePath(tIndex,:));
        aArray = AveragePath(tIndex,:);
        averageValue = aArray(aArray>0);
        averageIndex = find(aArray>0);
        p3 = plot(averageIndex,averageValue);
        hold off;
        Parameters = p;
        titlestr = strcat('S : ' , Parameters.StartDate, '  A: ', Parameters.AverageStartDate, ' E: ', Parameters.EndDate);
        title(titlestr);
        legend([p1,p2,p3],'UPath','StrikePath','AveragePath');
        subplot(2,2,3);
        plot(Delta(:,tIndex));title('Delta');
        legend('Delta');

        subplot(2,2,4);
        bar(PerdayPnl(tIndex,:));title('PerDayPnl');
        legend('perDaypnl')
    else
        TotalPnlIndex = ones(row,2);
        for i = 1:row
            TotalPnlIndex(i,2) = i;
            TotalPnlIndex(i,1) = TotalPnl{i}(end);
        end
        TotalPnlIndex = sortrows(TotalPnlIndex);
        % 100%
        t = max(floor(1 * indexPercent * row),1);
        tIndex = TotalPnlIndex(t,2);

        figure;

        subplot(2,2,1);
        hold on;
        p1 = plot(TotalPnl{tIndex,:});
        p2 = plot(UnderlyingPnl{tIndex,:});
        p3 = plot(OptionPnl{tIndex,:});
        hold off;
        titlestr = strcat(' percent ',num2str(indexPercent*100),'% TotalPnl= ',num2str(TotalPnl{tIndex}(end)),' TotalFee=',num2str(TotalFee(tIndex)));

        title(titlestr);
        legend([p1,p2,p3],'TotalPnl','UnderlyingPnl','OptionPnl');

        subplot(2,2,2);
        hold on;
        p1 = plot(UnderlyingPath{tIndex,:});
        p2 = plot(StrikePath{tIndex,:});
        aArray = AveragePath{tIndex,:};
        averageValue = aArray(aArray>0);
        averageIndex = find(aArray>0);
        p3 = plot(averageIndex,averageValue);
        hold off;
        Parameters = p(tIndex);
        titlestr = strcat('S : ' , Parameters.StartDate, '  A: ', Parameters.AverageStartDate, ' E: ', Parameters.EndDate);
        title(titlestr);
        legend([p1,p2,p3],'UPath','StrikePath','AveragePath');

        subplot(2,2,3);
        plot(Delta{tIndex,:});title('Delta');
        legend('Delta');

        subplot(2,2,4);
        bar(PerdayPnl{tIndex,:});title('PerDayPnl');
        legend('perDaypnl')
    end
    result = 0;
end

