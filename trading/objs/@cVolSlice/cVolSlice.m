classdef cVolSlice < handle
    properties
        underlier_@cFutures
        underlier_spot_@double
        options_@cInstrumentArray
        strikes_@double
        moneyness_@double
        type_@char
        update_date1_@double
        update_date2_@char
        update_time1_@double
        update_time2_@char
        expiry1_@double
        expiry2_@char
        calendar_tau_@double
        business_tau_@double
        ivs_@double
    end
    
    methods
        [] = registeroption(obj,opt)
        [] = refresh(obj,qms)
        atmvol = getatmvol(obj)
        
%         [] = 
        
    end
end