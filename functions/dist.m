function d = dist(varargin)

if nargin == 1
    X = varargin{1};
    d = sqrt( X(:,1).^2 + X(:,2).^2 + X(:,3).^2 );
elseif nargin == 2
    X1 = varargin{1};
    X2 = varargin{2};
    d = sqrt( (X1(:,1)-X2(:,1)).^2 + (X1(:,2)-X2(:,2)).^2 + (X1(:,3)-X2(:,3)).^2 );
end

end