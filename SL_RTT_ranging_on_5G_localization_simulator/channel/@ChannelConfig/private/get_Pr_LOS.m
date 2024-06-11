function p = get_Pr_LOS(scenario,d2, h_UE, h_BS);
%get_Pr_LOS generate los probability for different scenarios.
% According to TR 38.901 clause 7.4.2.
% Note: For RMa, UMa, and UMi scenarios, d2 means d2out (outdoor).
% For Indoor, d2 means d2in. For InF BS is in the room.
h_UE = h_UE(:).';
h_BS = h_BS(:);
if strcmpi( scenario(1:3), 'rma' )
    p = 1* (d2 <= 10) + exp( - ( d2 - 10 ) / 1000 ) .* (d2 > 10);
elseif strcmpi( scenario(1:3), 'umi' ) %Street canyon
    p = 1* (d2 <= 18) + (18./d2 + exp( -d2/36 ) .* (1- 18./d2 ) ) .* (d2 > 18);
elseif strcmpi( scenario(1:3), 'uma' )
    C_prime = ( h_UE > 13 ) .* (h_UE <= 23 ) .* ( ( (h_UE -13 ) /10 ).^1.5 );
    p = 1* (d2 <= 18) + ( 18./d2 + exp( - d2 /63 ) .* ( 1- 18./d2 ) ) ...
        .* (1 + C_prime * 5/4 .* ( d2/100 ).^3 .* exp( - d2/150 ) )...
        .* (d2 > 18);
elseif  strcmpi( scenario(1:6), 'indoor' )
    p = 1* (d2 <= 5) + exp( -( d2 -5 ) /70.8 ) .* (d2 <= 49) ...
        + exp( - (d2 -49 ) /211.7 ) * 0.54 .* (d2 > 49);
elseif  strcmpi( scenario, 'Indoor_Mixed_office' )
    p = 1* ( d2 <= 1.2) + exp( -(d2 -1.2) /4.7 ) .* (d2 < 6.5) ...
        + exp( -( d2 -6.5) /32.6 ) *0.32 .* (d2 >= 6.5);
elseif strcmpi( scenario(1:3), 'inf' )
    % according to TR28.857-table 6.1-1
    if strcmpi( scenario(5), 'S' ) % SL SH  sparse
        r = 0.20; h_c = 2; d_clutter = 10;
    elseif strcmpi( scenario(5), 'D' ) % DL DH dense
        r = 0.40; h_c = 2; d_clutter = 2;
        % optional1 r = 0.40; h_c = 3; d_clutter = 5;
        % optional1 r = 0.60; h_c = 6; d_clutter = 2;
    end
    if strcmpi( scenario(6), 'L' ) % SL DL  lowBS
        k_sub = - d_clutter / log( 1 -r );
    elseif strcmpi( scenario(6), 'H' ) % SH DH  HighBS
        k_sub = - d_clutter / log( 1 -r ) * ( h_BS -h_UE ) ./ ( h_c -h_UE );
    end
    if strcmpi( scenario(5), 'H' ) % HH
        p = ones(length(d2),1 );
    else
        p = exp( - d2 ./ k_sub ); % SL DL SH DH
    end
end







