au1712 = cContract('AssetName','gold','Tenor','1712');
v1 = CreateObj('vanilla1','security','securityname','vanilla',...
    'strike',1,'issuedate',today,'expirydate',dateadd(today,'3m'),...
    'underlier',au1712,'optiontype','call');
vp = cVanillaPortfolio('vp1');
display(vp);
vp = vp.add(v1);
display(vp)
v2 = CreateObj('vanilla2','security','securityname','vanilla',...
    'strike',1,'issuedate',today,'expirydate',dateadd(today,'3m'),...
    'underlier',au1712,'optiontype','put');
vp = vp.add(v2);
display(vp)
v3 = CreateObj('vanilla2','security','securityname','vanilla',...
    'strike',1,'issuedate',today,'expirydate',dateadd(today,'3m'),...
    'underlier',au1712,'optiontype','straddle');
vp = vp.add(v3);
display(vp)

instruments = vp.instruments;
display(instruments);

idx = vp.find(v2);
display(idx);
vp = vp.remove(v1);
display(vp);
vp = vp.remove(v2);
display(vp);

