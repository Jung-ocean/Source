import copernicusmarine
#copernicusmarine.login()

dataset_id_target = "METOFFICE-GLO-SST-L4-NRT-OBS-SST-V2"

date_range = "*/2023/*"

copernicusmarine.get(
#   dataset_id=dataset_id_target)
   dataset_id=dataset_id_target,
   filter=date_range)
