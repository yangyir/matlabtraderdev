function indicators = calc_technical_indicators(mdefut,instrument)
    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    for i = 1:ns
        if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
            tbl = mdefut.technical_indicator_table_{i};
            if isempty(tbl)
                indicators = [];
                return;
            end
            indicators = ones(size(tbl,1),1);
            for j = 1:size(tbl,1)
                name = tbl{j}.name;
                val = tbl{j}.values;
                switch lower(name)
                    case 'williamr'
                        wr = calc_wr_(mdefut,instrument,val{:});
                        indicators(j) = wr(end);
                    otherwise
                end
            end
            break
        end
    end

end
% end of calc_technical_indicators