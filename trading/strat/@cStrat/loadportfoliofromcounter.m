function [] = loadportfoliofromcounter(strategy)
    if isempty(strategy.counter_), return; end
    
    if ~strategy.counter_.is_Counter_Login, return;end
    
    positions = strategy.counter_.queryPositions;
    strategy.portfolio_ = cPortfolio;
    flag = isempty(strategy.instruments_);
    
    if flag
        %note:no instrument has been registered with the strategy
        for i = 1:size(positions,2)
            code_ctp = positions(i).asset_code;
            isopt = isoptchar(code_ctp);
            if isopt
                instrument = cOption(code_ctp);
            else
                instrument = cFutures(code_ctp);
            end
            instrument.loadinfo([code_ctp,'_info.txt']);
            strategy.registerinstrument(instrument);
            multi = instrument.contract_size;
            if ~isempty(strfind(instrument.code_bbg,'TFC')) || ~isempty(strfind(instrument.code_bbg,'TFT'))
                multi = multi/100;
            end
            
            direction = positions(i).direction;
            volume = positions(i).total_position * direction;
            if volume == 0, continue;end
            cost = positions(i).avg_price / multi;
            strategy.portfolio_.updateinstrument(instrument,cost,volume);
        end
    else
        %note:we hereby only search for the positions with instruments that
        %are registered with the strategy
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
    
    
    
    
end
%end of loadportfoliofromcounter