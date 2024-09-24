import copernicusmarine
#copernicusmarine.login()

dataset_id_target = "METOFFICE-GLO-SST-L4-REP-OBS-SST"

date_range = "*/2021/*"

copernicusmarine.get(
#   dataset_id=dataset_id_target)
   dataset_id=dataset_id_target,
   filter=date_range)
