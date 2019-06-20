function [output] = refreshtbl(obj,varargin)
%cGUIFut
    try
        tblRowName = get(obj.handles_.mktdatatbl.table,'RowName');
        tblColName = get(obj.handles_.mktdatatbl.table,'ColumnName');
        nrows = size(tblRowName,1);
        ncols = length(tblColName);
        data = cell(nrows,ncols);
        wrinfocell = cell(nrows,1);
        macdcell = cell(nrows,1);
        sigcell = cell(nrows,1);
        bscell = cell(nrows,1);
        sscell = cell(nrows,1);
        levelupcell = cell(nrows,1);
        leveldncell = cell(nrows,1);
        for i = 1:nrows
            instr = code2instrument(tblRowName{i});
            lasttick = obj.mdefut_.getlasttick(tblRowName{i});
            lastClose = obj.mdefut_.lastclose_(i);
            wrinfocell{i} = obj.mdefut_.calc_wr_(instr,'IncludeLastCandle',1);
            [macdcell{i},sigcell{i}] = obj.mdefut_.calc_macd_(instr,'IncludeLastCandle',1);
            [bscell{i},sscell{i},levelupcell{i},leveldncell{i}] = obj.mdefut_.calc_tdsq_(instr,'IncludeLastCandle',1);

            if ~isempty(lasttick)
                data{i,1} = num2str(lasttick(4));   %last trade
                if abs(lasttick(2)) > 1e10
                    data{i,2} = '-';
                else
                    data{i,2} = num2str(lasttick(2));   %bid
                end
                if abs(lasttick(3)) > 1e10
                    data{i,3} = '-';
                else
                    data{i,3} = num2str(lasttick(3));   %ask
                end
                data{i,4} = datestr(lasttick(1),'dd/mmm HH:MM:SS');
                data{i,6} = sprintf('%3.1f%%',100*(lasttick(4)/lastClose-1));
            else
                
                
            end
                data{i,5} = num2str(lastClose);
                data{i,7} = sprintf('%3.1f',wrinfocell{i}(1));
                data{i,8} = num2str(wrinfocell{i}(2));
                data{i,9} = num2str(wrinfocell{i}(3));
                data{i,10} = num2str(bscell{i}(end));
                data{i,11} = num2str(sscell{i}(end));
                data{i,12} = num2str(levelupcell{i}(end));
                data{i,13} = num2str(leveldncell{i}(end));
                data{i,14} = sprintf('%3.3f',macdcell{i}(end));
                data{i,15} = sprintf('%3.3f',sigcell{i}(end));
        end
        set(obj.handles_.mktdatatbl.table,'Data',data);
        output = struct('wrinfocell',{wrinfocell},...
            'macdcell', {macdcell},...
            'sigcell',{sigcell},...
            'bscell',{bscell},...
            'sscell',{sscell},...
            'levelupcell',{levelupcell},...
            'leveldncell', {leveldncell});
    catch err
        fprintf('%s\n',err.message);
        output = {};
    end
end