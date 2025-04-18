function [] = onNewData(obj,~,eventData)
% a charlotteDataProcessorFut function
    data = eventData.MarketData;
    ncodes = size(obj.codes_,1);
    for i = 1:ncodes
        try
            data_i = data{i};
        catch
            data_i = [];
        end
        if ~isempty(data_i)
            obj.tickcounts_(i) = obj.tickcounts_(i) + 1;
            newdata_i = [data_i.time,data_i.lasttrade];
            if isempty(obj.ticks_{i})
                obj.ticks_{i} = newdata_i;
            else
                obj.ticks_{i} = [obj.ticks_{i};newdata_i];
            end
        else
            
        end
    end
    obj.updatecandles;
    
%     fprintf('\n');
    
end