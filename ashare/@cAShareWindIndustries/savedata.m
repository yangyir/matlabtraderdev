function [] = savedata(obj,varargin)
%cAShareWindIndustries
    n_index = size(obj.codes_index_,1);
    %save daily data
    for i = 1:n_index, savedailybarfromwind2(obj.conn_,obj.codes_index_{i});end
    fprintf('daily bar data saved......\n');
    %
end