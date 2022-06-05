classdef cETFEntrust < handle
    % class of entrust specific to ETF/stock
    % ---------------------------------------
    % yangyir 20220425,
    
    
    properties (GetAccess = public, SetAccess = private)
        id_@char          % entrust id
        instrument_@cStock
    end
    
    properties
        volume_@double    % volume must be positive;
        price_@double     % price must be positive;
        direction_@double % buy = 1;sell = -1;
        offset_@double    % open = 1; close = -1; 
    end
    
    
    properties (GetAccess = public, SetAccess = private, Dependent = true)
       date2_@char
       time2_@char
    end
end