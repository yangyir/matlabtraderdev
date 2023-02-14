function [] = reload(obj,varargin)
%AShareWindIndustries
    n_index = size(obj.codes_index_,1);
    obj.dailybarmat_index_ = cell(n_index,1);
    obj.dailybarstruct_index_ = cell(n_index,1);
    obj.dailybarriers_conditional_index_ = nan(n_index,2);
    
    nfractal = 2;
    doplot = 0;
    for i = 1:n_index
        fn_i = [obj.codes_index_{i},'_daily.txt'];
        dailybar_i = cDataFileIO.loadDataFromTxtFile(fn_i);
        dailybar_i = dailybar_i(:,1:5);
        [obj.dailybarmat_index_{i},obj.dailybarstruct_index_{i}] = tools_technicalplot1(dailybar_i,nfractal,doplot);
        obj.dailybarmat_index_{i}(:,1) = x2mdate(obj.dailybarmat_index_{i}(:,1));
        [signal,~] = fractal_signal_conditional(obj.dailybarstruct_index_{i},0.001,nfractal);
        if ~isempty(signal)
            if ~isempty(signal{1,1})
                obj.dailybarriers_conditional_index_(i,1) = signal{1,1}(1,2);
                obj.dailystatus_index_(i,1) = 2;                            %conditional bullish
            end
            if ~isempty(signal{1,2})
                obj.dailybarriers_conditional_index_(i,2) = signal{1,2}(1,3);
                obj.dailystatus_index_(i,1) = -2;                           %conditional bearish
            end
        end
    end
    fprintf('AShareWindIndustries:init:daily bar of index:technical indicators calculated......\n');
    %
end