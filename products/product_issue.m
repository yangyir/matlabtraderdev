function [books,vanillas,underlying,productnotional,productvolume] = product_issue(varargin)
p = inputParser;p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('ProductName',{},@(x) validateattributes(x,{'char'},{},'ProductName'));
p.addParameter('ProductIssueDate',{},@(x) validateattributes(x,{'char','numeric'},{},'ProductIssueDate'));
p.parse(varargin{:});
productname = p.Results.ProductName;
issuedate = p.Results.ProductIssueDate;

if isempty(productname)
    error('product_issue:ProductName required');
end

if isempty(issuedate)
    %default to the last business date
    issuedate = businessdate(today,-1);
end

if strcmpi(productname,'deformedbar_no1')
    [books,vanillas,underlying,productnotional,productvolume] = product_deformedbar_no1('ProductIssueDate',issuedate);
else
    error([productname, 'not supported!'])
end

end