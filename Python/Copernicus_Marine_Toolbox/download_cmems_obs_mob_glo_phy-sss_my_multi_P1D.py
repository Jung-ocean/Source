import copernicus_marine_client as copernicusmarine
#copernicusmarine.login()

copernicusmarine.get(
   dataset_id = "cmems_obs-mob_glo_phy-sss_my_multi_P1D",
#   filter = "*_200[0-2]*R*"
   filter = "*_202[0-1]*"
#   output_filename="test.nc"
)
