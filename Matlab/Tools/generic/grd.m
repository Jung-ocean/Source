function grd = gg(location)

% if nargin == 0
%   location = 'eas'; % default
% end
%    scoord = [5 0.4 50 20];

switch location
    case 'BSf'
        grd_file = '/data/sdurski/ROMS_Setups/Grids/Bering_Sea/BeringSea_Dsm_grid.nc';
        scoord = [2 0 50 45]; % theta_s theta_b hc N

        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        Vtransform = 2;
        grd = roms_get_grid(grd_file,scoord,0,Vtransform);

    case 'Lab'
        grd_file = 'G:\내 드라이브\Model\ROMS\Case\Lab\roms_grd.nc' ;
        scoord = [5 0.4 4 20]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord,0,0,1);
        
    case 'NWP_old'
        grd_file = 'G:\내 드라이브\Model\ROMS\Case\NWP\input\roms_grid_NWP.nc' ;
        scoord = [10 0 250 40]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'test'
        grd_file = 'G:\grid\test.nc';
        scoord = [7 2 250 40]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);

    case 'NWP_ver40_74'
        grd_file = 'G:\OneDrive - SNU\Model\ROMS\Case\NWP\input\roms_grid_NWP_ver40.nc';
        scoord = [7 4 250 40]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case {'NWP_ver40_layer20', 'NWP_ver40_s2_layer20'}
        grd_file = ['G:\OneDrive - SNU\Model\ROMS\Case\NWP\input\roms_grid_NWP_ver40.nc'];
        scoord = [7 2 250 20]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case {'NWP_ver39_s', 'NWP_ver40_s', 'NWP_ver40_s2'}
        grd_file = ['G:\OneDrive - SNU\Model\ROMS\Case\NWP\input\roms_grid_', location, 'mooth.nc'];
        scoord = [7 2 250 40]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
                
    case 'ADD'
        grd_file = 'D:\Data\Ocean\Model\ROMS\ADD_assimilation_2010\roms_grid2_ADD_08_2_ep.nc';
        scoord = [5 0.4 5 40]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'ens_10km'
        grd_file = 'D:\Data\Ocean\Model\ROMS\ens_mean_monthly_ghseo\roms_grid_final.nc';
        scoord = [5 0.4 5 20]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'ykang'
        grd_file = 'G:\양진이\etopo1_Eastsea_40.nc' ;
        scoord = [7 2 250 40]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'YSS'
        grd_file = 'G:\Model\ROMS\Case\HF_control\input\roms_grd_korea_ws_lar3_td_sm1.nc' ;
        scoord = [5 0.4 4 20]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'kimyy'
        grd_file = 'G:\내 드라이브\Model\ROMS\Case\kimyy\input\test06\roms_grid_nwp_1_10_test06.nc' ;
        scoord = [10 1 250 40]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'Fukushima_closed'
        grd_file = 'G:\OneDrive - SNU\Model\ROMS\Case\NWP_Fukushima_dye\roms_grid_nwp_1_10_test06_closed.nc' ;
        scoord = [10 1 250 40]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
                
    case 'kimyy_1_20_test42'
        grd_file = 'C:\Users\JJH\Desktop\용엽쓰_1_20\test42\roms_grid_nwp_1_20_test42.nc' ;
        scoord = [10 1 250 40]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'kimyy_1_20_test49'
        grd_file = 'C:\Users\JJH\Desktop\용엽쓰_1_20\test49\roms_grid_nwp_1_20_test49.nc' ;
        scoord = [10 1 250 40]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case {'cshwa_3km', 'yjtak'}
        grd_file = 'G:\내 드라이브\Model\ROMS\Case\YECS\input\roms_grd_auto_rdrg2_new8_smooth.nc';
        scoord = [5 0.4 500 40]; % theta_s theta_b hc N
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'YECS'
        grd_file = 'G:\내 드라이브\Model\ROMS\Case\YECS\input\roms_grd_auto_rdrg2_6e_4.nc';
        scoord = [5 0.4 500 40]; % theta_s theta_b hc N
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'asan'
        grd_file = 'G:\OneDrive - SNU\Model\ROMS\Case\Asan\Asanho\domain\grid_asan3.nc' ;
        scoord = [1 1 1 20] % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case {'EYECS_20190807', 'EYECS_20190818', 'EYECS_20190822', 'EYECS_20190826', 'EYECS_20190828', ...
            'EYECS_20190829', 'EYECS_20190829_2', 'EYECS_20190830', 'EYECS_20190831', ...
            'EYECS_20190902', 'EYECS_20190902_2', 'EYECS_20190902_3', 'EYECS_20190902_4', ...
            'EYECS_20190903', 'EYECS_20190903_2', 'EYECS_20190904', 'EYECS_20211206', ...
            'EYECS_20211207', 'EYECS_20211208', 'EYECS_20211214', 'EYECS_20211215', ...
            'EYECS_20211216', 'EYECS_20211217', 'EYECS_20211218', ...
            'EYECS_20211220', 'EYECS_20211221', 'EYECS_20211224', ...
            'EYECS_20211229', 'EYECS_20220105', 'EYECS_20220106', ...
            'EYECS_20220107', 'EYECS_20220109', 'EYECS_20220110'}
            grd_file = ['D:\OneDrive - SNU\Model\ROMS\EYECS\input\roms_grid_', location, '.nc'];
        scoord = [7 2 250 40]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);

    case 'mask4southern'
        grd_file = ['G:\OneDrive - SNU\Model\ROMS\Case\EYECS\input\mask4southern.nc'];
        scoord = [7 2 250 40]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'EYECS'
        grd_file = 'G:\내 드라이브\Model\ROMS\Case\EYECS\input\roms_grid_EYECS_20190904.nc';
        scoord = [7 2 250 40]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'NP'
        grd_file = 'G:\내 드라이브\Model\ROMS\Case\NP\input\roms_grid_NP_exp_01.nc';
        scoord = [5 0.4 5 30]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord,0,0,1);
        
    case 'upwelling5km'
        grd_file = 'G:\내 드라이브\Model\ROMS\Case\Upwelling_ideal\grid\ideal_5km\roms_grid_upwelling_ideal_5km.nc';
        scoord = [0 0 1e16 30]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'upwelling5km_flat_mask'
        grd_file = 'G:\내 드라이브\Model\ROMS\Case\ADSEN\test\input\roms_grid_upwelling_ideal_5km_flat.nc';
        scoord = [0 0 1e16 30]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'upwelling5km_flat'
        grd_file = 'G:\내 드라이브\Model\ROMS\Case\Upwelling_ideal\grid\ideal_5km\roms_grid_upwelling_ideal_5km_flat.nc';
        scoord = [0 0 1e16 30]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'upwelling1km_flat_s0_b0'
        grd_file = 'G:\내 드라이브\Model\ROMS\Case\Upwelling_ideal\grid\ideal_1km\roms_grid_upwelling_ideal_1km_flat.nc';
        scoord = [0 0 1e16 30]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'upwelling1km_flat'
        grd_file = 'G:\내 드라이브\Model\ROMS\Case\Upwelling_ideal\grid\ideal_1km\roms_grid_upwelling_ideal_1km_flat.nc';
        scoord = [10 1 40 30]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'CC_ideal'
        grd_file = 'D:\OneDrive - SNU\Model\ROMS\Counter_current_ideal\grid\roms_grid_CC_ideal.nc';
        scoord = [10 1 40 30]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'upwelling_background'
        grd_file = 'D:\OneDrive - SNU\Model\ROMS\Upwelling_background\grid\roms_grid_upwelling_background.nc';
        scoord = [10 1 40 30]; % theta_s theta_b hc N
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    case 'nwp_1_10_auto'
        grd_file= 'D:\Data\Ocean\Model\GLORYS_climatology/auto01_grid.nc';
        scoord = [10.0 1.0 250.0 40]; % theta_s theta_b hc N
        Vtransform = 2;
        Vstretching = 4;
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
    otherwise
        grd_file = ['G:\OneDrive - SNU\Model\ROMS\Case\NWP\input\roms_grid_', location, '.nc'];
        
        if str2num(location(8:end)) < 39
            scoord = [10 0 250 40] % theta_s theta_b hc N
        else
            scoord = [7 2 250 40] % theta_s theta_b hc N
        end
        
        disp(' ')
        disp([ 'Loading ROMS grd for application: ' location])
        disp([ 'using grid file ' grd_file])
        disp(' ')
        grd = roms_get_grid(grd_file,scoord);
        
end