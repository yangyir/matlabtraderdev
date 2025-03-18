function output = kellydistributionmerge(varargin)
%utility function to merge two input kelly tables
%
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('table1',[],@isstruct);
p.addParameter('table2',[],@isstruct);
p.parse(varargin{:});
tbl1 = p.Results.table1;
tbl2 = p.Results.table2;

%1.merge tblbyasset_l, HOWEVER, row 'all' will be removed
rowidx1 = ~strcmpi(tbl1.tblbyasset_l.assetlist,'all');
rowidx2 = ~strcmpi(tbl2.tblbyasset_l.assetlist,'all');
tblbyasset_l = [tbl1.tblbyasset_l(rowidx1,:);tbl2.tblbyasset_l(rowidx2,:)];
%2.merge tblbyasset_s. HOWEVER, row 'all' will be removed
rowidx1 = ~strcmpi(tbl1.tblbyasset_s.assetlist,'all');
rowidx2 = ~strcmpi(tbl2.tblbyasset_s.assetlist,'all');
tblbyasset_s = [tbl1.tblbyasset_s(rowidx1,:);tbl2.tblbyasset_s(rowidx2,:)];
%3.merge tblbyasset_bs. HOWEVER, row 'all' will be removed
rowidx1 = ~strcmpi(tbl1.tblbyasset_bs.assetlist,'all');
rowidx2 = ~strcmpi(tbl2.tblbyasset_bs.assetlist,'all');
tblbyasset_s = [tbl1.tblbyasset_s(rowidx1,:);tbl2.tblbyasset_s(rowidx2,:)];

end