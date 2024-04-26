function out = get_sequence(c_init, M_pn);
%get_sequence generate pseudo-random sequence following 3GPP TS 38.211
%v16.4.0 clause 5.2.1.

Nc = 1600;
%first sequence
x1(1) = 1;
x1(2: 31) = 0;%zeros(1,30);
%second seuqence
x2(1:31) = getinitialx2values(c_init);
for i = 0 : M_pn + Nc-1
    x1(i+1 +31) = mod(x1(i+1 +3) + x1(i+1), 2);
    x2(i+1 +31) = mod(x2(i+1 +3) + x2(i+1 +2) + x2(i+1 +1) + x2(i +1) ,2);
end

i = (0 : M_pn -1).';
out =  mod( x1( i +1 +Nc)+ x2( i +1 +Nc), 2);
end
%------------------------------------------------
% sub function 
% calc initial sequence value for x2 according to c_init
function out = getinitialx2values( c_init );
x2( 1: 31) = zeros(1, 31);
diff = c_init;
while(diff > 0 )
    n = floor( log2( diff ) );
    x2(n +1) = 1;
    diff = diff - 2^n;
end
out = x2;
end
