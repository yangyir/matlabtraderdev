% private function to get quotes from THS datasource
function quotes = getquotes_ths(watcher)
    ns = size(watcher.singles,1);

    list_ctp = cell(ns,1);
    for i = 1:ns
        list_ctp{i} = watcher.singles_ctp{i};
    end
    
    quotes = zeros(ns,7);

    data = watcher.ds.realtime(list_ctp,'latest');
    for i = 1:ns
        try
            quotes(i,1) = floor(data(i,1));
            quotes(i,2) = data(i,1);
            quotes(i,3:end) = data(i,2:end);
        catch
%             disp(data);
            quotes = [];
            return
        end
    end

end