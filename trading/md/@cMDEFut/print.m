function [] = print(obj,varargin)
%cMDEFut    
    if ~obj.printflag_, return; end
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    time = p.Results.Time;
      
    if strcmpi(obj.status_,'sleep')
        fprintf('%s:mdefut sleeps......\n',datestr(time,'yyyy-mm-dd HH:MM:SS'));
    elseif strcmpi(obj.status_,'working')
        isanyinstrumenttrading = false;
        n = obj.qms_.instruments_.count;
        for i = 1:n
            dtnum_open = obj.datenum_open_{i};
            dtnum_close = obj.datenum_close_{i};
            for j = 1:size(dtnum_open,1)
                if time >= dtnum_open(j) && time <= dtnum_close(j)
                    isanyinstrumenttrading = true;
                    break
                end
            end
        end
        if isanyinstrumenttrading
            obj.printmarket;
            if ~isempty(obj.gui_)
                tblRowName = get(obj.gui_.mktdatatbl.table,'RowName');
                tblColName = get(obj.gui_.mktdatatbl.table,'ColumnName');
                nrows = size(tblRowName,1);
                ncols = length(tblColName);
                data = cell(nrows,ncols);
                for i = 1:nrows
                    lasttick = obj.getlasttick(tblRowName{i});
                    data{i,1} = num2str(lasttick(4));   %last trade
                    data{i,2} = num2str(lasttick(2));   %bid
                    data{i,3} = num2str(lasttick(3));   %ask
                    data{i,4} = datestr(lasttick(1),'HH:MM:SS');
                    histcandles = obj.gethistcandles(tblRowName{i});
                    lastClose = histcandles{1}(end,5);
                    data{i,5} = num2str(lastClose);
                    data{i,6} = num2str(lasttick(4)-lastClose);
                    wrinfo = obj.calc_technical_indicators(tblRowName{i});
                    data{i,7} = num2str(wrinfo{1}(2));
                    data{i,8} = num2str(wrinfo{1}(3));
                end
                set(obj.gui_.mktdatatbl.table,'Data',data);


            
            
            
            
            end
            
            
            
            
        end
    end
    
end