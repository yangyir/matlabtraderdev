%function marketDataEventDemo
    % 创建市场数据源
    feed = MarketDataFeed('AAPL');
    feed.UpdateInterval = 0.5; % 每0.5秒更新一次
    
    % 创建两个数据处理器
    processor1 = DataProcessor('Basic');
    processor2 = DataProcessor('Pro');
    
    % 创建可视化工具
    visualizer = DataVisualizer();
    
    % 添加监听器
    addlistener(feed, 'NewDataArrived', @processor1.onNewData);
    addlistener(feed, 'NewDataArrived', @processor2.onNewData);
    addlistener(feed, 'NewDataArrived', @visualizer.onNewData);
    
    % 错误处理监听器
    addlistener(feed, 'ErrorOccurred', @(src,evt) fprintf('Error: %s\n', evt.Message));
    
    % start data feed
    feed.start();
    
    % stop after running a while
    pause(10); % stop for 10 secs
    feed.stop();
    
    % 显示处理后的数据
    disp('Basic processor collect data:');
    disp(struct2table(processor1.History));
    
    % 保持图表打开
    uiwait(visualizer.Figure);
%end