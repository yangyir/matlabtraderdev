function indicators = calc_technical_indicators(mdefut,instrument,varargin)
    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    if ischar(instrument)
        instrument = code2instrument(instrument);
    end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched =true;
    p.addParameter('IncludeExtraResults',false,@islogical);
    p.parse(varargin{:});
    includeextraresults = p.Results.IncludeExtraResults;
    
    for i = 1:ns
        if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
            tbl = mdefut.technical_indicator_table_{i};
            if isempty(tbl)
                indicators = [];
                return;
            end
            if ~includeextraresults
                indicators = cell(size(tbl,1),1);
            else
                indicators = cell(size(tbl,1),2);
            end
            for j = 1:size(tbl,1)
                name = tbl{j}.name;
                val = tbl{j}.values;
                switch lower(name)
                    case 'williamr'
                        if ~includeextraresults
                            indicators{j,1} = calc_wr_(mdefut,instrument,val{:});
                        else
                            [indicators{j,1},indicators{j,2}] = calc_wr_(mdefut,instrument,val{:});
                        end
                    otherwise
                end
            end
            break
        end
    end

end
% end of calc_technical_indicators