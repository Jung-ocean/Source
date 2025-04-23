import copernicusmarine
#copernicusmarine.login()

dataset_id_target = "cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.125deg_P1M-m"

date_range = "*/2023/*"

copernicusmarine.get(
#   dataset_id=dataset_id_target)
   dataset_id=dataset_id_target,
   filter=date_range)
