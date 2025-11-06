function  C = SWM(A)
%%Sherman-Morrison-Woodbury Formul
n = size(A,1);I = eye(n);C = I;
    for k = 1:n
        u = I(:,k); v = A(k,:); v(k) = v(k) - 1;
        w = C*u; z=v*C; t = -1/(v*w+1);
        C = C + t*w*z;
    end
end