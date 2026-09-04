function [output] = charlotte_atr_run(varargin)
% run the pnl profile with a simple ATR trailing system
% simple rule:
% for LONG trade:
% 1. stop once the lowest candle price hit the atrstoploss
% 2. stop once the lowest caddle price hit the alligator teeth
% 3. stop once the highest candle price hit the atrtarget
%
% for SHORT trade:
% 1. stop once the highest candle price hit the atrstoploss
% 2. stop once the highest caddle price hit the alligator teeth
% 3. stop once the lowest candle price hit the atrtarget
% 
% in case of using atrbreakeven, stoploss is reset once the highest
% candle price hit the atrbreakeven

    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Trades',[],@(x) validateattributes(x,{'table','cTradeOpenArray'},{},'','Trades'));
    p.addParameter('ExtraInfo',[],@isstruct);
    p.addParameter('ATRBreakEven',[],@isnumeric);    % ATR breakeven
    p.addParameter('ATRSL',[],@isnumeric);   % ATR stoploss
    p.addParameter('ATRTP',[],@isnumeric);   % ATR take profit
    p.addParameter('ATRLambda',[],@isnumeric);

    p.parse(varargin{:});

    trades = p.Results.Trades;
    ei = p.Results.ExtraInfo;
    atrbreakeven = p.Results.ATRBreakEven;
    atrsl = p.Results.ATRSL;
    atrtarget = p.Results.ATRTP;
    atrlambda = p.Results.ATRLambda;

    nbars = size(ei.px,1);


    if istable(trades)
        ntrades = size(trades,1);
        tblflag = true;
    elseif isa(trades,'cTradeOpenArray')
        ntrades = trades.latest_;
        tblflag = false;
    else
        tblflag = false;
    end
    atrmae = zeros(ntrades,1);  % maximum adverse excursion
    atrmfe = zeros(ntrades,1);  % maximum favorable excursion
    pnlvec = zeros(ntrades,1);
    initialloss = zeros(ntrades,1);

    for i = 1:ntrades
        if tblflag
            opendt_i = trades.opendatetime(i);
            opendirection_i = trades.direction(i);
            openpx_i = trades.openprice(i);
        else
            opendt_i = trades.node_(i).opendatetime1_;
            opendirection_i = trades.node_(i).opendirection_;
            openpx_i = trades.node_(i).openprice_;
        end
        if iscell(opendt_i)
            opendt_i = datenum(opendt_i{1},'yyyy-mm-dd HH:MM');
        end
        
        openid_i = find(ei.px(:,1) >= opendt_i,1,'first');
        initialloss_i = ei.atr(openid_i-1);

        
        if opendirection_i == 1
            latrmin_i = 0;
            latrmax_i = 0;
            if tblflag
                hh_i = trades.barrierfractal(i);
            else
                hh_i = trades.node_(i).opensignal_.hh_;
            end
            stoploss_i = hh_i - atrsl * initialloss_i;

            for j = openid_i:nbars
                low_j = ei.px(j,4);
                high_j = ei.px(j,3);
                hh_i = max(hh_i,high_j);
                teeth_jmius = ei.teeth(j-1);
                stoploss_i = max(stoploss_i,teeth_jmius);
                if low_j < stoploss_i
                    latrmin_i = max(latrmin_i,(openpx_i-stoploss_i)/initialloss_i);
                    pnlvec(i) = stoploss_i - openpx_i;
                    break
                end

                latrmin_i = max(latrmin_i,(openpx_i - low_j)/initialloss_i);
                latrmax_i = max(latrmax_i,(hh_i - openpx_i)/initialloss_i);
                
                if ~isempty(atrbreakeven) && ~isempty(atrlambda)
                    if latrmax_i >= atrbreakeven 
                        atrmultiplier = 0.8 + (1.8-0.8)*exp(-atrlambda*latrmax_i);
                        stoploss_i = max(hh_i - atrmultiplier * ei.atr(j),stoploss_i);
                    end
                end

                if latrmax_i > atrtarget
                    pnlvec(i) = atrtarget*initialloss_i;
                    break
                end
            end

            atrmae(i) = latrmin_i;
            atrmfe(i) = latrmax_i;
            %
        elseif opendirection_i == -1
            satrmin_i = 0;
            satrmax_i = 0;
            if tblflag
                ll_i = trades.barrierfractal(i);
            else
                ll_i = trades.node_(i).opensignal_.ll_;
            end
            stoploss_i = ll_i + atrsl * initialloss_i;
            
            for j = openid_i:nbars
                low_j = ei.px(j,4);
                high_j = ei.px(j,3);
                ll_i = min(ll_i,low_j);
                teeth_jmius = ei.teeth(j-1);
                stoploss_i = min(stoploss_i,teeth_jmius);
                if high_j > stoploss_i
                    satrmin_i = max(satrmin_i,(stoploss_i-openpx_i)/initialloss_i);
                    pnlvec(i) = openpx_i - stoploss_i;
                    break
                end
                
                satrmin_i = max(satrmin_i,(high_j - openpx_i)/initialloss_i);
                satrmax_i = max(satrmax_i,(openpx_i-ll_i)/initialloss_i);
                
                if ~isempty(atrbreakeven) && ~isempty(atrlambda)
                    if satrmax_i >= atrbreakeven
                        atrmultiplier = 0.8 + (1.8-0.8)*exp(-atrlambda*satrmax_i);
                        stoploss_i = min(ll_i + atrmultiplier * ei.atr(j),stoploss_i);
                    end
                end

                if satrmax_i > atrtarget
                    pnlvec(i) = atrtarget*initialloss_i;
                    break
                end
            end
            
            atrmae(i) = satrmin_i;
            atrmfe(i) = satrmax_i;

        end

        initialloss(i) = initialloss_i;
    end

    output = struct('PnL',pnlvec,...
        'MAE',atrmae,...
        'MFE',atrmfe,...
        'InitialLoss',initialloss);

end