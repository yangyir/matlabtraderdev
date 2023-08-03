function data = tickdata(obj,instrument,startdate,enddate)
%cTHS function
%some sanity check first
    data = [];
    if ~obj.isconnect,return;end
    if ~ischar(startdate), error('cTHS:tickdata:startdate must be char'); end
    if ~ischar(enddate), error('cTHS:tickdata:enddate must be char'); end
    
    %not implemented!!!

end
%end of tickdata
