function [] = refresh(obj,varargin)
%cOps
%note:yangyiran 20180816
%here are the jobs that an ops needs to do
%1.regardless of 'realtime' or 'replay' mode, the ops will always keep
%updating its associated book with entrusts, i.e. process pending entrusts,
%and update trades array (this is implemented in updateentrustsandbook2

%2.print positions with pnl and also print entrust evey minute

%3.load trades array from file and update positions

%4.save trades array to file after market close after 3pm 
    try
%         updateentrustsandbook(obj);
        updateentrustsandbook2(obj);
        %
%         if strcmpi(obj.mode_,'replay') && strcmpi(obj.status_,'working')
%             instruments = obj.mdefut_.qms_.instruments_.getinstrument;
%             lasttick = obj.mdefut_.getlasttick(instruments{1});
%             if isempty(lasttick), return; end
%             ticktime = lasttick(1);
%             if obj.displayinfo(ticktime) && obj.display_
%                 fprintf('\nprint book info at:%s\n',datestr(ticktime,'yyyy-mm-dd HH:MM'))
%                 obj.printrunningpnl('mdefut',obj.mdefut_);
%                 obj.printpendingentrusts;
%             end
%             %
%             if strcmpi(obj.mdefut_.status_,'sleeping')
%                 fprint('stop here\n');
%             end
%         else
%         end
        
    catch e
        msg = ['error:cOps:updateentrustsandbook:',e.message,'\n'];
        fprintf(msg);
    end
    
end