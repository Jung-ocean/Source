import copernicusmarine
#copernicusmarine.login()

copernicusmarine.get(
   dataset_id = "cmems_obs-mob_glo_phy-sss_nrt_multi_P1D",
#   filter = "*_200[0-2]*R*"
   filter = "*/2025/*"
#   output_filename="test.nc"
)
