function [data,label] = bloombergticksregroup(ticks)
%function to re-group tick data from BLOOMBERG
%BLOOMBERG ticks are presented in order of TRADE,BID and ASK
%the 1st column is Type, i.e.'TRDAE','BID' or 'ASK'
%the 2nd column is Date and Time
%the 3rd column is the price
%the 4th,which is the last,column is the size(volume)
%in case there are 'TRADE','BID' and 'ASK' presented in the orginal tick
%data, the re-grouped output data shall be in column order as
%'Datetime','BidPrice','BidSize','AskPrice','AskSize','TradePrice','TradeSize'
%
%in case only 'TRADE' presented in the original tick data, the re-grouped
%ouputput shall be in column order as 'DateTime','TradePrice','TradeSize'

    n=size(ticks,1);
    if n == 0
        data = [];
        label = {};
        return;
    end
    nBid = sum(strcmpi('BID',ticks(:,1)));
    nAsk = sum(strcmpi('ASK',ticks(:,1)));
    nTrade = sum(strcmpi('TRADE',ticks(:,1)));

    nRows = max([nBid,nAsk,nTrade]);
    nCols = 1+2*(nBid>0)+2*(nAsk>0)+2*(nTrade>0);

    if nBid > 0 || nAsk > 0
        %pop-up labels
        if nBid > 0
            label = 'bidprice,bidsize';
        end
        if nAsk > 0
            answer = who('label');
            if isempty(answer)
                label = 'askprice,asksize';
            else
                label = [label,',askprice,asksize'];
            end
        end
        if nTrade > 0
            answer = who('label');
            if isempty(answer)
                label = 'tradeprice,tradesize';
            else
                label = [label,',tradeprice,tradesize'];
            end
        end
        label = regexp(label,',','split');


        data=NaN(nRows,nCols);
        if nRows == nBid
            data(:,1:3)=cell2mat(ticks(strcmpi('BID',ticks(:,1)),2:end));
        end
        if nAsk > 0
            for i = 1:nCols-1
                if strcmpi('askprice',label{i})
                    break
                end
            end
            data(:,i+1:i+2)=cell2mat(ticks(strcmpi('ASK',ticks(:,1)),3:end));
        end
        if nTrade > 0
            if nTrade == nRows
                data(:,end-1:end)=cell2mat(ticks(strcmpi('TRADE',ticks(:,1)),3:end));
            else
                %the downloaded data is always in order of 'TRADE','BID','ASK'
                if nBid > 0 && nAsk > 0
                    i = 1;
                    iBid = 0;
                    while i <= n
                        if strcmpi('TRADE',ticks{i,1}) && strcmpi('BID',ticks{i+1,1}) && strcmpi('ASK',ticks{i+2,1})
                            iBid = iBid+1;
                            data(iBid,end-1) = ticks{i,3};
                            data(iBid,end) = ticks{i,4};
                            i=i+3;
                        elseif strcmpi('BID',ticks{i,1}) && strcmpi('ASK',ticks{i+1,1})
                            %in some cases only the bid and ask prices are
                            %available,i.e.no trade occurs
                            iBid = iBid+1;
                            i = i+2;
                            %do nothing
                        end
                    end
                elseif nBid > 0 && nAsk == 0
                    i = 1;
                    iBid = 0;
                    while i <= n
                        if strcmpi('TRADE',ticks{i,1}) && strcmpi('BID',ticks{i+1,1})
                            iBid = iBid+1;
                            data(iBid,end-1) = ticks{i,3};
                            data(iBid,end) = ticks{i,4};
                            i = i+2;
                        elseif strcmpi('BID',ticks{i,1})
                            iBid = iBid+1;
                            i = i+1;
                            %do nothing
                        end
                    end
                elseif nBid == 0 && nAsk > 0
                    i = 1;
                    iAsk = 0;
                    while i <= n
                        if strcmpi('TRADE',ticks{i,1}) && strcmpi('ASK',ticks{i+1,1})
                            iAsk = iAsk+1;
                            data(iAsk,end-1)=ticks{i,3};
                            data(iAsk,end)=ticks{i,4};
                            i=i+2;
                        elseif strcmpi('ASK',ticks{i,1})
                            iAsk = iAsk+1;
                            i = i+1;
                            %do nothing
                        end
                    end
                end
            end
        end    
    else
        data=cell2mat(ticks(:,2:4));
        label = {'tradeprice','tradesize'};
    end







