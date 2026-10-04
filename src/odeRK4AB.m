function [t,x] = odeRK4AB(A, B, u, tv, x0)
    % [t,x] = odeRK4AB(A, B, u, tv, x0)
    
    dt = tv(2)-tv(1);
    K = length(x0); M = length(tv);
    xv = zeros(K, M);
    x = x0; xv(1:K, 1) = x0;

    for k = 1:M-1
        D1 = dt*( A*x + B*u(k) ); 
        D2 = dt*( A*(x+D1/2) + B*u(k) ); 
        D3 = dt*( A*(x+D2/2) + B*u(k) ); 
        D4 = dt*( A*(x+D3) + B*u(k) ); 
        x = x + ( D1 + 2*D2 + 2*D3 + D4 )/6;
        xv(1:K,k+1) = x;
    end
    t=tv'; x=xv.';
end