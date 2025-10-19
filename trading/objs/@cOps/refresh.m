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
                fprintf('%s stops because %s is off\n',obj.timer_.Name,obj.mdefut_.timer_.Name);
                obj.stop;
                if ~isempty(obj.gui_)
                    set(obj.gui_.tradingstats.opsstatus_edit,'string',obj.status_);
                    set(obj.gui_.tradingstats.opsrunning_edit,'string',obj.timer_.running);
                end
                return
            end 
        catch e
            msg = ['error:cOps:refresh:check mdefut timer running or not:',e.message,'\n'];
            fprintf(msg);
            return
        end
    end
    
    if ~isempty(obj.mdeopt_)
        try
            if strcmpi(obj.mdeopt_.timer_.running,'off')
                fprintf('%s stops because %s is off\n',obj.timer_.Name,obj.mdeopt_.timer_.Name);
                obj.stop;
                if ~isempty(obj.gui_)
                    set(obj.gui_.tradingstats.opsstatus_edit,'string',obj.status_);
                    set(obj.gui_.tradingstats.opsrunning_edit,'string',obj.timer_.running);
                end
                return
            end 
        catch e
            msg = ['error:cOps:refresh:check mdeopt timer running or not:',e.message,'\n'];
            fprintf(msg);
            return
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
    
    if ~isempty(obj.gui_)
        set(obj.gui_.tradingstats.opsstatus_edit,'string',obj.status_);
        set(obj.gui_.tradingstats.opsrunning_edit,'string',obj.timer_.running);
        
        [runningpnl,closedpnl] = obj.calcpnl('mdefut',obj.mdefut_);
        val = sum(sum(runningpnl));
        if val >= 0
            set(obj.gui_.tradingstats.runningpnl_edit,'string',num2str(val),'foregroundcolor','b');
        else
            set(obj.gui_.tradingstats.runningpnl_edit,'string',num2str(val),'foregroundcolor','r');
        end
        val = sum(sum(closedpnl));
        if val >= 0
            set(obj.gui_.tradingstats.closedpnl_edit,'string',num2str(val),'foregroundcolor','b');
        else
            set(obj.gui_.tradingstats.closedpnl_edit,'string',num2str(val),'foregroundcolor','r');
        end

        %positions
        positions = obj.trades_.convert2positions;
        npos = size(positions,1);
        colnames = get(obj.gui_.positions.table,'ColumnName');
        if npos > 0
            rownames = cell(npos,1);
            data = cell(npos,length(colnames));
            for i = 1:npos
                rownames{i} = positions{i}.code_ctp_;
                data{i,1} = positions{i}.direction_;
                data{i,2} = positions{i}.position_total_;
                data{i,3} = positions{i}.position_today_;
                data{i,4} = positions{i}.cost_open_;
                [runningpnl,closedpnl] = obj.calcpnl('code',positions{i}.code_ctp_,'mdefut',obj.mdefut_);
                if positions{i}.direction_ == 1
                    data{i,5} = runningpnl(1);
                    data{i,6} = closedpnl(1);
                else
                    data{i,5} = runningpnl(2);
                    data{i,6} = closedpnl(2);
                end 
            end
            set(obj.gui_.positions.table,'Data',data,'RowName',rownames);
        else
            data = cell(1,length(colnames));
            set(obj.gui_.positions.table,'Data',data);
        end
        %
        entrustypes = get(obj.gui_.entrusts.popupmenu,'string');
        entrustidx = get(obj.gui_.entrusts.popupmenu,'value');
        entrusttype = entrustypes{entrustidx};
        if strcmpi(entrusttype,'all')
            entrusts = obj.entrusts_;
        elseif strcmpi(entrusttype,'pending')
            entrusts = obj.entrustspending_;
        elseif strcmpi(entrusttype,'finished')
            entrusts = obj.entrustsfinished_;
        end
        
        nentrust = entrusts.latest;
        entrustdata = cell(nentrust,9);

        for i = 1:nentrust
            entrustdata{i,1} = entrusts.node(i).entrustNo;%id
            entrustdata{i,2} = entrusts.node(i).instrumentCode;%instrument code
            if entrusts.node(i).direction == 1
                entrustdata{i,3} = 'buy';
            else
                entrustdata{i,3} = 'sell';
            end
            %
            if entrusts.node(i).offsetFlag == 1
                entrustdata{i,4} = 'open';
            else
                entrustdata{i,4} = 'closed';
            end
            %
            if entrusts.node(i).volume == entrusts.node(i).dealVolume
                entrustdata{i,5} = 'settled';
            elseif entrusts.node(i).cancelVolume > 0
                entrustdata{i,5} = 'cancelled';
            else
                entrustdata{i,5} = 'pending';
            end
            %
            if entrusts.node(i).volume == entrusts.node(i).dealVolume
                entrustdata{i,6} = entrusts.node(i).dealPrice;
            else
                entrustdata{i,6} = entrusts.node(i).price;
            end

            entrustdata{i,7} = entrusts.node(i).volume;%volume
            entrustdata{i,8} = entrusts.node(i).dealVolume;%dealvolume
            entrustdata{i,9} = datestr(entrusts.node(i).time,'mm-dd HH:MM:SS');
        end
        set(obj.gui_.entrusts.table,'Data',entrustdata);


    end
    
end