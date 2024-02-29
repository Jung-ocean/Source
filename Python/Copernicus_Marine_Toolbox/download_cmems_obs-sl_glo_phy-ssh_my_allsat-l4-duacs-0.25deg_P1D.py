import copernicusmarine
#copernicusmarine.login()

dataset_id_target = "cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.25deg_P1D"

date_range = "*/2020/*"

copernicusmarine.get(
   dataset_id=dataset_id_target,
   filter=date_range)
