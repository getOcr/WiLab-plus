function [grid] = gen_SSBgrid(ssb, carrier)
 %gen_SSBgrid Generate the SSB resrouce grid.
%
% Description:
%   This function aims to generate SSB grid according to 3GPP TS38.211 
%   v16.4.0 clause 7.4.3.
%
%	Developer: Jia. Institution: PML. Date: 2021/08/14
 
symbolsPerSubframe = carrier.SymbolsPerSlot * carrier.SlotsPerSubframe*5;
grid = [];
for ihfframe = 1 : ssb.nframe_tot*2
    ssb.NHFframe = ihfframe -1;
    grid_HF = zeros(ssb.NRB *12, symbolsPerSubframe);
    if mod(ssb.NHFframe, ssb.SSBPeriodicity /5 ) == 0
        % n_hf
        if mod( ssb.NHFframe, 2 ) == 0
            ssb.n_hf = 0;
        elseif mod( ssb.NHFframe, 2 ) == 1
            ssb.n_hf = 1;
        end    
        for i_ssb = 1 : ssb.Lmax_bar
            ssb.i_ssb = i_ssb -1;
            % i_ssb_bar
            if ssb.Lmax_bar == 4
                ssb.i_ssb_bar = i_ssb -1 + 4 * n_hf;
            elseif ssb.Lmax_bar > 4
                ssb.i_ssb_bar = i_ssb -1;
            end
            % ssb grid
            ssbGrid = SSBgrid( ssb );
            % common grid
            grid_HF( ssb.SSBSCPos, ssb.SSBSymPos( i_ssb, :) ) = ssbGrid;
        end
    end
    grid = cat( 2, grid, grid_HF );
end

end
