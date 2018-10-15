classdef cStratConfigBatman < cStratConfig
    %class cStratConfigWR
    %used in trading with cStratFutMultiBatman
    properties (GetAccess = public, SetAccess = private)
        bandwidthmin_@double = 0.01
        bandwidthmax_@double = 0.02
    end
    
end