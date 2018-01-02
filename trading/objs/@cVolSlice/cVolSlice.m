classdef cVolSlice < handle
    properties
        underlier_@cFutures
        options_@cInstrumentArray
        strikes_@double
        moneyness_@double
        type_@char
        expiry1_@double
        expiry2_@char
        tau_@double
        ivs_@double
        
    end
    
    methods
        [] = registeroption(obj,opt)
        
    end
end