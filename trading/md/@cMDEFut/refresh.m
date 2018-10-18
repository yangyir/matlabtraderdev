function [] = refresh(mdefut,varargin)
    if ~isempty(mdefut.qms_)
        if strcmpi(mdefut.mode_,'realtime')
            %refresh qms with the latest market quotes
            mdefut.qms_.refresh;
            %save ticks data into memory
            mdefut.saveticks2mem;
            %save candles data into memory
            mdefut.updatecandleinmem;
        %    
        elseif strcmpi(mdefut.mode_,'replay')
            mdefut.refreshreplaymode2;
        end
    end
    
    
    if ~isempty(mdefut.gui_)
        try
            tblRowName = get(mdefut.gui_.mktdatatbl.table,'RowName');
            tblColName = get(mdefut.gui_.mktdatatbl.table,'ColumnName');
            nrows = size(tblRowName,1);
            ncols = length(tblColName);
            data = cell(nrows,ncols);
            for i = 1:nrows
                histcandles = mdefut.gethistcandles(tblRowName{i});
                lastClose = histcandles{1}(end,5);
                lasttick = mdefut.getlasttick(tblRowName{i});
                wrinfo = mdefut.calc_technical_indicators(tblRowName{i});
                data{i,7} = num2str(wrinfo{1}(2));
                data{i,8} = num2str(wrinfo{1}(3));

                if ~isempty(lasttick)
                    data{i,1} = num2str(lasttick(4));   %last trade
                    data{i,2} = num2str(lasttick(2));   %bid
                    data{i,3} = num2str(lasttick(3));   %ask
                    data{i,4} = datestr(lasttick(1),'HH:MM:SS');
                    data{i,5} = num2str(lastClose);
                    data{i,6} = num2str(lasttick(4)-lastClose);
                else
                    data{i,1} = num2str(lastClose);   %last trade
                    data{i,2} = num2str(lastClose);   %bid
                    data{i,3} = num2str(lastClose);   %ask
                    data{i,4} = datestr(histcandles{1}(end,1),'HH:MM:SS');
                    data{i,5} = num2str(lastClose);
                    data{i,6} = num2str(0);
                end
            end
            set(mdefut.gui_.mktdatatbl.table,'Data',data);
        catch
        end
    end
    
end
%end of refresh