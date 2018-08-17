% fields insturment type
% [mkt, level] = getCurrentPrice(code,marketNo);
% marketNo: 上海证券交易所='1';深交所='2'; 上交所期权='3';中金所='5'
% mkt: 5*1数值向量, 依次为最新价,成交量,交易状态(=0表示取到行情;=1表示未取到行情),交易分钟数,秒钟数
% marketNo: 0 -上海L1,深圳L1,转上市地，新三板 1
% level: 盘口数据(5*4矩阵), 第1~4列依次为委买价,委买量,委卖价,委卖量
function data = realtime(obj,instruments,fields)
    %note fields are not used here
    variablenotused(fields);
    if ~obj.isconnected_
        data = {};
        return
    end
    marketNo = '1';
    if isa(instruments,'cInstrument')
        % getCurrentPrice come from H5Quote 见 qtool\option\optionClass\实盘交易类\O32_matlab\H5Quote\H5QUOTE
        if isa(instruments,'cStock')
            marketNo = '1';
        elseif isa(insturments,'cOption')
            marketNo = '3';
        end
        [mkt, level] = getCurrentPrice(instruments.code_H5,marketNo);
        data = cell(1,1);
        data{1} = struct('mkt',mkt,'level',level);
    elseif iscell(instruments)
        n = length(instruments);
        data = cell(n,1);
        for i = 1:n
            if isa(instruments,'cInstrument')
                if isa(instruments,'cStock')
                    marketNo = '1';
                elseif isa(insturments,'cOption')
                    marketNo = '3';
                end
                [mkt, level] = getCurrentPrice(instruments{i}.code_H5,marketNo);
            else
                [mkt, level] = getCurrentPrice(instruments{i},marketNo);
            end
            data{i} = struct('mkt',mkt,'level',level);
        end
    else
        [mkt, level] = getCurrentPrice(num2str(instruments),marketNo);
        data = cell(1,1);
        data{1} = struct('mkt',mkt,'level',level);
    end
end
%end of realtime