function y = polyND(p, x, deg)
    % x : (n x d) matrix (n = the number of samples, d = the number of variables)
    % deg : maximum degree of polynomial
    % p : coefficient vector (length = nchoosek(d+deg, deg))
    % y : (n x 1) result

    [n, d] = size(x);
    exps = generateExponents(d, deg);  % exponents combination
    y = zeros(n,1);

    for idx = 1:size(exps,1)
        term = ones(n,1);
        for j = 1:d
            term = term .* (x(:,j).^exps(idx,j));
        end
        y = y + p(idx)*term;
    end
end

function exps = generateExponents(d, deg)
    % d variable, maximum deg polynomial exponents combination
    exps = [];
    vec = zeros(1,d);
    exps = recurseExp(exps, vec, 1, deg);
end

function exps = recurseExp(exps, vec, pos, deg)
    d = length(vec);
    if pos > d
        if sum(vec) <= deg
            exps = [exps; vec];
        end
    else
        for v = 0:deg
            vec(pos) = v;
            exps = recurseExp(exps, vec, pos+1, deg);
        end
    end
end