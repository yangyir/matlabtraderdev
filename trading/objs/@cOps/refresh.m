function [] = refresh(obj,varargin)
%cOps
%note:yangyiran 20180816
%here are the jobs that an ops needs to do
%1.regardless of 'realtime' or 'replay' mode, the ops will always keep
%updating its associated book with entrusts, i.e. process pending entrusts,
%and update trades array (this is implemented in updateentrustsandbook2

%2.print positions with pnl and also print entrust evey minute

%3.load trades array from file and update positions

%4.save trades array to file after market close after 3:25pm

    if ~isempty(obj.mdefut_)
        try
            if strcmpi(obj.mdefut_.timer_.running,'off')
                obj.status_ = 'sleep';
                obj.stop;
            end 
        catch e
            msg = ['error:cOps:refresh:check mdefut timer running or not:',e.message,'\n'];
            fprintf(msg);
        end
    end

    try
%         updateentrustsandbook(obj);
        updateentrustsandbook2(obj);
        %
        
    catch e
        msg = ['error:cOps:refresh:updateentrustsandbook:',e.message,'\n'];
        fprintf(msg);
    end
    
end