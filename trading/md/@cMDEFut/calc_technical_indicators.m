function indicators = calc_technical_indicators(mdefut,instrument)
    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    if ischar(instrument)
        instrument = code2instrument(instrument);
    end
    
    for i = 1:ns
        if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
            tbl = mdefut.technical_indicator_table_{i};
            if isempty(tbl)
                indicators = [];
                return;
            end
            indicators = cell(size(tbl,1),1);
            for j = 1:size(tbl,1)
                name = tbl{j}.name;
                val = tbl{j}.values;
                switch lower(name)
                    case 'williamr'
                        indicators{j} = calc_wr_(mdefut,instrument,val{:});
                    otherwise
                end
            end
            break
        end
    end

end
% end of calc_technical_indicators