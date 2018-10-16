function positions = convert2positions(obj)
%positions is cell
positions = {};
ntrades = obj.latest_;

if ntrades == 0, return;end
codes = cell(ntrades,1);
count = 0;
for itrade = 1:ntrades
    trade_i = obj.node_(itrade);
    if strcmpi(trade_i.status_,'closed')
        continue;
    end
    count = count + 1;
    codes{count} = trade_i.code_;
end

codes = codes(1:count);
codes = unique(codes);
ninstrument = size(codes,1);
% positions = cell(ninstrument,1);
positions_intermediate = cell(ninstrument,2);
%note:20180927
%we resize positions with 2 columns instead of 1
%the first column records long positions of the particular instrument and
%the second column records short positions of the particular instrument
%we guarantee that positions for the same instrument but different
%directions can be stored at the same time.

npos = 0;
for itrade = 1:ntrades
    trade_i = obj.node_(itrade);
    if strcmpi(trade_i.status_,'closed')
        continue;
    end
    code_ctp = trade_i.code_;
    for iinstrument = 1:ninstrument
        if strcmpi(code_ctp,codes{iinstrument})
            openprice = trade_i.openprice_;
            opendirection = trade_i.opendirection_;
            openvolume = trade_i.openvolume_;
            opentime = trade_i.opendatetime1_;
            if opendirection == 1
                if isempty(positions_intermediate{iinstrument,1})
                    pos = cPos;
                    pos.override('code',code_ctp,'price',openprice,'volume',opendirection*openvolume,'time',opentime);
                    positions_intermediate{iinstrument,1} = pos;
                else
                    positions_intermediate{iinstrument,1}.add('code',code_ctp,'price',openprice,'volume',opendirection*openvolume,'time',opentime);
                end
                npos = npos + 1;
            elseif opendirection == -1
                if isempty(positions_intermediate{iinstrument,2})
                    pos = cPos;
                    pos.override('code',code_ctp,'price',openprice,'volume',opendirection*openvolume,'time',opentime);
                    positions_intermediate{iinstrument,2} = pos;
                else
                    positions_intermediate{iinstrument,2}.add('code',code_ctp,'price',openprice,'volume',opendirection*openvolume,'time',opentime);
                end
                npos = npos + 1;
            end
            break
        end
    end
    
end

%note:20180927
%resize positions_intermediate into 1 column
positions = cell(npos,1);
count = 0;
for itrade = 1:ninstrument
    for iinstrument = 1:2
        if ~isempty(positions_intermediate{itrade,iinstrument})
            count = count + 1;
            positions{count,1} = positions_intermediate{itrade,iinstrument};
        end
    end
end

positions = positions(1:count);


end