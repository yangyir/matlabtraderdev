function [] = mde_fin_plot( mdefut)
%
instruments = mdefut.qms_.instruments_.getinstrument;
n = length(instruments);
for i = 1:n
      if ~strcmpi(instruments{i}.exchange,'.CFE'), continue;end
      [~,~,p_i] = mdefut.calc_macd_(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
      op_i = tools_technicalplot1(p_i,mdefut.nfractals_(i),0,'volatilityperiod',0,'tolerance',0);
      tools_technicalplot2(op_i(end-79:end,:),i,instruments{i}.code_ctp);
end
   
%plot 2*TF-T spread
hasTF = false;idxTF = -1;
hasT = false;idxT = -1;
for i = 1:n
      if strcmpi(instruments{i}.asset_name,'govtbond_5y')
            hasTF = true;
            idxTF = i;
            break
      end
end
for i = 1:n
      if strcmpi(instruments{i}.asset_name,'govtbond_10y')
            hasT = true;
            idxT = i;
            break
      end
end

if hasTF && hasT
      d_2TFminusT_30m = load('d_2TFminusT_30m.mat');
      d_2TFminusT_30m = d_2TFminusT_30m.d_2TFminusT_30m;
      d_TF = mdefut.candles4save_{idxTF};
      d_T = mdefut.candles4save_{idxT};
      d_TF = d_TF(d_TF(:,2)~=0,:);
      d_T = d_T(d_T(:,2)~=0,:);
      spd_1m = [d_TF(:,1),2*d_TF(:,5)-d_T(:,5)];
      spd_30m = timeseries_compress(spd_1m,'Frequency','30m');
      d_2TFminusT_30m = [d_2TFminusT_30m;spd_30m];
      op_2TFminusT_30m = tools_technicalplot1(d_2TFminusT_30m,mdefut.nfractals_(idxTF),0,'volatilityperiod',0,'tolerance',0);
      tools_technicalplot2(op_2TFminusT_30m(end-79:end,:),6,'2TF-T spread');     
end


end

