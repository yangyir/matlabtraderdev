%function marketDataEventDemo
    % �����г�����Դ
    feed = MarketDataFeed('AAPL');
    feed.UpdateInterval = 0.5; % ÿ0.5�����һ��
    
    % �����������ݴ�����
    processor1 = DataProcessor('Basic');
    processor2 = DataProcessor('Pro');
    
    % �������ӻ�����
    visualizer = DataVisualizer();
    
    % ��Ӽ�����
    addlistener(feed, 'NewDataArrived', @processor1.onNewData);
    addlistener(feed, 'NewDataArrived', @processor2.onNewData);
    addlistener(feed, 'NewDataArrived', @visualizer.onNewData);
    
    % �����������
    addlistener(feed, 'ErrorOccurred', @(src,evt) fprintf('Error: %s\n', evt.Message));
    
    % start data feed
    feed.start();
    
    % stop after running a while
    pause(10); % stop for 10 secs
    feed.stop();
    
    % ��ʾ����������
    disp('Basic processor collect data:');
    disp(struct2table(processor1.History));
    
    % ����ͼ���
    uiwait(visualizer.Figure);
%end