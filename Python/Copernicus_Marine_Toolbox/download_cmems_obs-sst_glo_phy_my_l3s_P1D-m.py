import copernicusmarine
#copernicusmarine.login()

dataset_id_target = "cmems_obs-sst_glo_phy_my_l3s_P1D-m"

date_range = "*/2024/*"

copernicusmarine.get(
#   dataset_id=dataset_id_target)
   dataset_id=dataset_id_target,
   filter=date_range)
