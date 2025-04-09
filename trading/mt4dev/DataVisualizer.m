classdef DataVisualizer < handle
    properties
        Figure
        PricePlot
        TimeStamps = []
        Prices = []
    end
    
    methods
        function obj = DataVisualizer()
            obj.Figure = figure('Name', 'DataVisualizer', 'NumberTitle', 'off');
            ax = axes('Parent', obj.Figure);
            obj.PricePlot = plot(ax, NaN, NaN, 'b-o');
            xlabel(ax, 'Time');
            ylabel(ax, 'Price');
            title(ax, 'Live Markt Price');
            grid(ax, 'on');
        end
        
        function onNewData(obj, ~, eventData)
            data = eventData.MarketData;
            
            % 更新数据
            obj.TimeStamps = [obj.TimeStamps; data.Timestamp];
            obj.Prices = [obj.Prices; data.Price];
            
            % 更新图表
            set(obj.PricePlot, 'XData', obj.TimeStamps, 'YData', obj.Prices);
            
            % 调整坐标轴
            ax = get(obj.PricePlot, 'Parent');
            if numel(obj.TimeStamps) > 1
                xlim(ax, [min(obj.TimeStamps) max(obj.TimeStamps)]);
                ylim(ax, [min(obj.Prices)*0.99 max(obj.Prices)*1.01]);
            end
            
            drawnow;
        end
    end
end