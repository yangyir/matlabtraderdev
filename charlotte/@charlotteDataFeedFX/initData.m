function [] = initData(obj)
%a charlotteDataFeedFX function
    try
        ncodes = size(obj.codes_,1);
        for i = 1:ncodes
            data =  readtable(obj.fn_{i},'readvariablenames',1);
            idxlast = find(~isnan(data.Close),1,'last');
        
            lastbardate = data.Date{idxlast};
            lastbardatestr = [lastbardate(1:4),lastbardate(6:7),lastbardate(9:10)];
            obj.lastbartime_(i) = datenum([lastbardatestr,' ',data.Time{idxlast}],'yyyymmdd HH:MM');
        end
    catch ME
        % error happened and event is triggered
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData(ME.message));
    end
end