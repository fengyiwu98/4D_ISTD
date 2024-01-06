% function [dx] = soft_shrink(dx,Thresh)
% s = abs( dx );
% dx = max(s - Thresh,0).*sign(dx);
function [dx] = soft_shrink(v0,tau)
% s = abs( dx );
% dx = max(s - Thresh,0).*sign(dx);
dx=sign(v0).*max(abs(v0)-tau,0);
