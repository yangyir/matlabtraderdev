function [] = mde_fin_plot( mdefut)
%
instruments = mdefut.qms_.instruments_.getinstrument;
n = length(instruments);
n_fin = 0;
for i = 1:n
      if ~strcmpi(instruments{i}.exchange,'.CFE'), continue;end
      n_fin = n_fin + 1;
      [~,~,p_i] = mdefut.calc_macd_(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
      op_i = tools_technicalplot1(p_i,mdefut.nfractals_(i),0,'volatilityperiod',0,'tolerance',0);
      tools_technicalplot2(op_i(end-79:end,:),n_fin,instruments{i}.code_ctp);
end
   
% %plot 2*TF-T spread
% hasTF = false;idxTF = -1;
% hasT = false;idxT = -1;
% for i = 1:n
%       if strcmpi(instruments{i}.asset_name,'govtbond_5y')
%             hasTF = true;
%             idxTF = i;
%             break
%       end
% end
% for i = 1:n
%       if strcmpi(instruments{i}.asset_name,'govtbond_10y')
%             hasT = true;
%             idxT = i;
%             break
%       end
% end
% 
% if hasTF && hasT
%     n_fin = n_fin + 1;
%     d_2TFminusT_30m = load('d_2TFminusT_30m.mat');
%     d_2TFminusT_30m = d_2TFminusT_30m.d_2TFminusT_30m;
%     d_TF = mdefut.candles4save_{idxTF};
%     d_T = mdefut.candles4save_{idxT};
%     d_TF = d_TF(d_TF(:,2)~=0,:);
%     d_T = d_T(d_T(:,2)~=0,:);
%     [t,idx_TF,idx_T] = intersect(d_TF(:,1),d_T(:,1));
%     spd_1m = [t,2*d_TF(idx_TF,5)-d_T(idx_T,5)];
%     spd_30m = timeseries_compress(spd_1m,'Frequency','30m');
%     d_2TFminusT_30m = [d_2TFminusT_30m;spd_30m];
%     op_2TFminusT_30m = tools_technicalplot1(d_2TFminusT_30m,mdefut.nfractals_(idxTF),0,'volatilityperiod',0,'tolerance',0);
%     tools_technicalplot2(op_2TFminusT_30m(end-79:end,:),n_fin,'2TF-T spread');
% end
% 
% hasIF = false;idxIF = -1;
% hasIC = false;idxIC = -1;
% hasIH = false;idxIH = -1;
% for i = 1:n
%       if strcmpi(instruments{i}.asset_name,'eqindex_300')
%             hasIF = true;
%             idxIF = i;
%             break
%       end
% end
% for i = 1:n
%       if strcmpi(instruments{i}.asset_name,'eqindex_500')
%             hasIC = true;
%             idxIC = i;
%             break
%       end
% end
% for i = 1:n
%       if strcmpi(instruments{i}.asset_name,'eqindex_50')
%             hasIH = true;
%             idxIH = i;
%             break
%       end
% end
% 
% 
% if hasIF && hasIC
%     n_fin = n_fin + 1;
%     d_ICminusIF_30m = load('d_ICminusIF_30m.mat');
%     d_ICminusIF_30m = d_ICminusIF_30m.d_ICminusIF_30m;
%     d_IF = mdefut.candles4save_{idxIF};
%     d_IC = mdefut.candles4save_{idxIC};
%     d_IF = d_IF(d_IF(:,2)~=0,:);
%     d_IC = d_IC(d_IC(:,2)~=0,:);
%     [t,idx_IF,idx_IC] = intersect(d_IF(:,1),d_IC(:,1));
%     spd_1m = [t,2*d_IC(idx_IC,5)-3*d_IF(idx_IF,5)];
%     spd_30m = timeseries_compress(spd_1m,'Frequency','30m');
%     d_ICminusIF_30m = [d_ICminusIF_30m;spd_30m];
%     op_ICminusIF_30m = tools_technicalplot1(d_ICminusIF_30m,mdefut.nfractals_(idxIF),0,'volatilityperiod',0,'tolerance',0);
%     tools_technicalplot2(op_ICminusIF_30m(end-79:end,:),n_fin,'2IC-3IF spread');
% end
% 
% if hasIH && hasIC
%     n_fin = n_fin + 1;
%     d_ICminusIH_30m = load('d_ICminusIH_30m.mat');
%     d_ICminusIH_30m = d_ICminusIH_30m.d_ICminusIH_30m;
%     d_IH = mdefut.candles4save_{idxIH};
%     d_IC = mdefut.candles4save_{idxIC};
%     d_IH = d_IH(d_IH(:,2)~=0,:);
%     d_IC = d_IC(d_IC(:,2)~=0,:);
%     [t,idx_IH,idx_IC] = intersect(d_IH(:,1),d_IC(:,1));
%     spd_1m = [t,2*d_IC(idx_IC,5)-3*d_IH(idx_IH,5)];
%     spd_30m = timeseries_compress(spd_1m,'Frequency','30m');
%     d_ICminusIH_30m = [d_ICminusIH_30m;spd_30m];
%     op_ICminusIH_30m = tools_technicalplot1(d_ICminusIH_30m,mdefut.nfractals_(idxIH),0,'volatilityperiod',0,'tolerance',0);
%     tools_technicalplot2(op_ICminusIH_30m(end-79:end,:),n_fin,'2IC-3IH spread');
% end
% 
% if hasIH && hasIF
%     n_fin = n_fin + 1;
%     d_IFminusIH_30m = load('d_IFminusIH_30m.mat');
%     d_IFminusIH_30m = d_IFminusIH_30m.d_IFminusIH_30m;
%     d_IF = mdefut.candles4save_{idxIF};
%     d_IH = mdefut.candles4save_{idxIH};
%     d_IH = d_IH(d_IH(:,2)~=0,:);
%     d_IF = d_IF(d_IF(:,2)~=0,:);
%     [t,idx_IF,idx_IH] = intersect(d_IF(:,1),d_IH(:,1));
%     spd_1m = [t,d_IF(idx_IF,5)-d_IH(idx_IH,5)];
%     spd_30m = timeseries_compress(spd_1m,'Frequency','30m');
%     d_IFminusIH_30m = [d_IFminusIH_30m;spd_30m];
%     op_IFminusIH_30m = tools_technicalplot1(d_IFminusIH_30m,mdefut.nfractals_(idxIH),0,'volatilityperiod',0,'tolerance',0);
%     tools_technicalplot2(op_IFminusIH_30m(end-79:end,:),n_fin,'IF-IH spread');
% end

n_comdty = 0;
for i = 1:n
    if strcmpi(instruments{i}.exchange,'.CFE'), continue;end
    n_comdty = n_comdty + 1;
    [~,~,p_i] = mdefut.calc_macd_(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
    op_i = tools_technicalplot1(p_i,mdefut.nfractals_(i),0,'volatilityperiod',0,'tolerance',0);
    tools_technicalplot2(op_i(end-79:end,:),n_fin+n_comdty,instruments{i}.code_ctp);
end

end

