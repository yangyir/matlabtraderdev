classdef cPortfolio < handle
    properties
       portfolio_id = 'unknown'
       instrument_list@cell
       instrument_avgcost@double
       instrument_volume@double
    end
    
    methods
        function [bool,idx] = hasinstrument(obj,instrument)
            if ~isa(instrument,'cInstrument')
                error('cPortfolio:hasinstrument:cInstrument type of input expected')
            end
            n = obj.count;
            bool = false;
            idx = 0;
            for i = 1:n
                if strcmpi(instrument.code_ctp,obj.instrument_list{i}.code_ctp)
                    bool = true;
                    idx = i;
                    break;
                end
            end
            
        end
        %end of hasinstrument
        
        function n = count(obj)
            n = length(obj.instrument_list);
        end
        %end of count
    
        
        function obj = addinstrument(obj,instrument,px,volume)
            if nargin < 3
                px = 0;
                volume = 0;    
            end
            
            if nargin == 3
                error('cPortfolio:addinstrument:missing input of volume')
            end
            
            [bool,idx] = obj.hasinstrument(instrument);
            if ~bool
                n = obj.count;
                list_ = cell(n+1,1);
                c_ = zeros(n+1,1);
                v_ = zeros(n+1,1);
                list_{n+1,1} = instrument;
                c_(n+1,1) = px;
                v_(n+1,1) = volume;
                for i = 1:n
                    list_{i,1} = obj.instrument_list{i,1};
                    c_(i,1) = obj.instrument_avgcost(i,1);
                    v_(i,1) = obj.instrument_volume(i,1);
                end
                obj.instrument_list = list_;
                obj.instrument_avgcost = c_;
                obj.instrument_volume = v_;
            else
                avgcost_ = obj.instrument_avgcost(idx,1);
                volume_ = obj.instrument_volume(idx,1);
                obj.instrument_volume(idx,1) = volume_+volume;
                if obj.instrument_volume(idx,1) == 0
                    obj.instrument_avgcost(idx,1) = 0;
                else
                    obj.instrument_avgcost(idx,1) = (avgcost_*volume_ + px*volume)/(volume_+volume);
                end
            end
        end
        %end of addinstrument
        
        function obj = updateinstrument(obj,instrument,px,volume)
            [bool,idx] = obj.hasinstrument(instrument);
            if ~bool
                obj.addinstrument(instrument,px,volume);
            else
                obj.instrument_avgcost(idx,1) = px;
                obj.instrument_volume(idx,1) = volume;
            end
        end
        %end of updateinstrument
        
        function obj = removeinstrument(obj,instrument)
            [bool,idx] = obj.hasinstrument(instrument);
            if ~bool
                %a warning or error message shall be issued
                return;
            else
                n = obj.count;
                if n == 1
                    obj.instrument_list = {};
                    obj.instrument_avgcost = [];
                    obj.instrument_volume = [];
                else
                    list_ = cell(n-1,1);
                    c_ = zeros(n-1,1);
                    v_ = zeros(n-1,1);
                    for i = 1:idx-1
                        list_{i,1} = obj.instrument_list{i,1};
                        c_(i,1) = obj.instrument_avgcost(i,1);
                        v_(i,1) = obj.instrument_volume(i,1);
                    end
                    for i = idx+1:n
                        list_{i-1,1} = obj.instrument_list{i,1};
                        c_(i-1,1) = obj.instrument_avgcost(i,1);
                        v_(i-1,1) = obj.instrument_volume(i,1);
                    end
                    obj.instrument_list = list_;
                    obj.instrument_avgcost = c_;
                    obj.instrument_volume = v_;
                end
                
            end
        end
        %end of removeinstrument
        
        function pnl = runningpnl(obj,quotes)
            n = obj.count;
            pnl = 0;
            for i = 1:n
                instr_i = obj.instrument_list{i}; 
                code_i = instr_i.code_ctp;
                tick_value_i = instr_i.tick_value;
                tick_size_i = instr_i.tick_size;
                volume_i = obj.instrument_volume(i);
                cost_i = obj.instrument_avgcost(i);
                if volume_i ~= 0
                    flag = false;
                    for j = 1:size(quotes,1)
                        q = quotes{j};
                        if strcmpi(code_i,q.code_ctp)
                            pnl = pnl + (q.last_trade-cost_i)/tick_size_i*tick_value_i*volume_i;
                            flag = true;
                            break
                        end
                    end
                    if ~flag
                        error(['missing quote for ',code_i])
                    end
                end
                
            end
        end
        %end of runningpnl
        
        function pnl = updateportfolio(obj,transaction)
            %pnl is the close pnl returned
            %todo:transaction fees shall be added later
            if ~isa(transaction,'cTransaction')
                error('cPortfolio:updateportfolio:invalid transaction input')
            end
            instrument = transaction.instrument_;
            px = transaction.price_;
            volume = transaction.volume_ * transaction.direction;
            
            [bool,idx] = obj.hasinstrument(instrument);
                        
            if ~bool
                n = obj.count;
                list_ = cell(n+1,1);
                c_ = zeros(n+1,1);
                v_ = zeros(n+1,1);
                list_{n+1,1} = instrument;
                c_(n+1,1) = px;
                v_(n+1,1) = volume;
                for i = 1:n
                    list_{i,1} = obj.instrument_list{i,1};
                    c_(i,1) = obj.instrument_avgcost(i,1);
                    v_(i,1) = obj.instrument_volume(i,1);
                end
                obj.instrument_list = list_;
                obj.instrument_avgcost = c_;
                obj.instrument_volume = v_;
                pnl = 0;
            else
                avgcost_ = obj.instrument_avgcost(idx,1);
                volume_ = obj.instrument_volume(idx,1);
                obj.instrument_volume(idx,1) = volume_+volume;
                if obj.instrument_volume(idx,1) == 0
                    %the position is now closed
                    tick_value = instrument.tick_value;
                    tick_size = instrument.tick_size;
                    pnl = (px-avgcost_)*volume_*tick_value/tick_size;
                    obj.instrument_avgcost(idx,1) = 0;
                else
                    obj.instrument_avgcost(idx,1) = (avgcost_*volume_ + px*volume)/(volume_+volume);
                    pnl = 0;
                end
            end
            
        end
        %end of updateportfolio
        
        function p = subportfolio(obj,instruments)
           %create a sub-portfolio with only provided instruments in it
           n = obj.count;
            if n == 0
                p = {};
                return
            end
            
            p = cPortfolio;
            if nargin < 2
                %here we shall create another copy of the portfolio rather
                %than a copy of the pointer
                p.instrument_list = obj.instrument_list;
                p.instrument_avgcost = obj.instrument_avgcost;
                p.instrument_volume = obj.instrument_volume;
                return
            end
            
            
            if isa(instruments,'cInstrument')
                [flag,idx] = portfolio.hasinstrument(instruments);
                if ~flag
                    error(['cPortfolio:subportfolio:invalid instrument input,missing information of ',instruments.code_ctp]);
                end 
                avgcost = portfolio.instrument_avgcost(idx);
                volume = portfolio.instrument_volume(idx);
                p.addinstrument(instruments,avgcost,volume);
                return
            end
            
            if isa(instruments,'cInstrumentArray')
                instruments_ = instruments.getinstrument;
            elseif iscell(instruments)
                instruments_ = instruments;
            else
                error('cPortfolio:calcpnl:invalid instrument inputs')
            end
                       
            for i = 1:length(instruments_)
                instrument = instruments_{i};
                [flag,idx] = obj.hasinstrument(instrument);
                if ~flag
                    error(['cPortfolio:calcpnl:invalid instrument input,missing information of ',instrument.code_ctp]);
                end
                avgcost = obj.instrument_avgcost(idx);
                volume = obj.instrument_volume(idx);
                p.addinstrument(instrument,avgcost,volume);
            end
            
        end
        %end of subportfolio
        
        function [] = print(obj)
            n = obj.count;
            for i = 1:n
                instrument_i = obj.instrument_list{i}.code_ctp;
                c_ = obj.instrument_avgcost(i);
                v_ = obj.instrument_volume(i);
                fprintf('instrument:%s;avgcost:%4.2f;volume:%d\n',instrument_i,c_,v_);
                
            end
        end
        %end of print
        
        function [] = clear(obj)
            obj.instrument_list = {};
            obj.instrument_avgcost = [];
            obj.instrument_volume = [];
            
        end
        %end of clear
    end
        
        
        
end