import copernicus_marine_client as copernicusmarine
#copernicusmarine.login()

copernicusmarine.get(
   dataset_id = "cmems_obs-mob_glo_phy-sss_my_multi_P1M",
#   filter = "*_200[0-2]*R*"
   filter = "*/2023/*"
#   output_filename="test.nc"
)
