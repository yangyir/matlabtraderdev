function [] = loadportfoliofromcounter(strategy)
    if isempty(strategy.counter_), return; end
    strategy.portfolio_ = cPortfolio;
    positions = strategy.counter_.queryPositions;
    instruments = strategy.instruments_.getinstrument;

    for i = 1:strategy.count
        instrument = instruments{i};
        for j = 1:size(positions,2)
            if strcmpi(instrument.code_ctp,positions(j).asset_code)
                multi = instrument.contract_size;
                if ~isempty(strfind(instrument.code_bbg,'TFC')) || ~isempty(strfind(instrument.code_bbg,'TFT'))
                    multi = multi/100;
                end

                direction = positions(j).direction;
                cost = positions(j).avg_price / multi;
                volume = positions(j).total_position * direction;

                strategy.portfolio_.updateinstrument(instrument,cost,volume);
            end
        end
    end
end
%end of loadportfoliofromcounter