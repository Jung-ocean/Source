import copernicusmarine
#copernicusmarine.login()

dataset_id_target = "cmems_obs-sl_glo_phy-ssh_nrt_allsat-l4-duacs-0.125deg_P1D"

date_range = "*/2024/*"

copernicusmarine.get(
#   dataset_id=dataset_id_target)
   dataset_id=dataset_id_target,
   filter=date_range)
