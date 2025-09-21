function r = randRange(a, b, varargin)
% randRange  Random numbers in the interval [a, b]
%   r = randRange(a,b)             returns a scalar in [a,b]
%   r = randRange(a,b,sz)          where sz is a size vector returns array of size sz
%   r = randRange(a,b,m,n,...)     returns array of size [m n ...] (like rand)
%
% Examples:
%   r = randRange(0.75, 1.0);        % scalar
%   r = randRange(0,1,[100,1]);      % 100x1 column vector
%   r = randRange(0,1,5,3);          % 5x3 matrix

if nargin < 2
    error('randRange requires at least two inputs: a and b.');
end
if ~isnumeric(a) || ~isnumeric(b)
    error('Inputs a and b must be numeric.');
end
if a > b
    error('First input a must be <= second input b.');
end

% Determine output size
if isempty(varargin)
    sz = [1 1];
elseif numel(varargin) == 1 && isnumeric(varargin{1}) && isvector(varargin{1})
    % pass a size vector e.g. [100 1]
    sz = varargin{1}(:)'; % row vector
else
    % treat varargin as separate size arguments e.g. (a,b,5,3)
    if all(cellfun(@(x) isnumeric(x) && isscalar(x) && x==floor(x) && x>=0, varargin))
        sz = cell2mat(varargin);
    else
        error('Size inputs must be non-negative integer scalars or a numeric size vector.');
    end
end

% Generate scaled random numbers
r = a + (b - a) .* rand(sz);
end
