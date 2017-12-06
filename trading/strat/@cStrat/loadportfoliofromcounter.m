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
            direction = positions(i).direction;
            volume = positions(i).total_position * direction;
            if volume == 0, continue;end
            
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
            
            cost_open = positions(i).avg_price / multi;
            data = cDataFileIO.loadDataFromTxtFile([instrument.code_ctp,'_daily.txt']);
            cost_carry = data(data(:,1)==getlastbusinessdate,5);
            strategy.portfolio_.addposition(instrument,cost_carry,volume,getlastbusinessdate);
            strategy.portfolio_.setcostopen(instrument,cost_open);
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
                    cost_open = positions(j).avg_price / multi;
                    
                    direction = positions(j).direction;
                    data = cDataFileIO.loadDataFromTxtFile([instrument.code_ctp,'_daily.txt']);
                    cost_carry = data(data(:,1)==getlastbusinessdate,5);
                    volume = positions(j).total_position * direction;
                    strategy.portfolio_.addposition(instrument,cost_carry,volume,getlastbusinessdate);
                    strategy.portfolio_.setcostopen(instrument,cost_open);
                    
                end
            end
        end
    end
    
    
    
    
end
%end of loadportfoliofromcounter