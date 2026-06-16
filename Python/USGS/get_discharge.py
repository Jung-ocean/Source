from dataretrieval import waterdata
import pandas as pd
import os

with open("usgs_key") as f:
  api_key = f.read().strip()
os.environ["API_USGS_PAT"] = api_key
print(api_key)

sites = {
    "USGS-12041200": "Hoh_River",
    "USGS-12040500": "Queets_River",
    "USGS-1203951610": "Quinault_River",
    "USGS-12039005": "Humptulips_River",
    "USGS-12035100": "Chehalis_River",
    "USGS-12013500": "Willapa_River",
    "USGS-12010000": "Naselle_River",
    "USGS-14246900": "Columbia_River",
    "USGS-14301340": "Nehalem_River",
    "USGS-14302020": "Wilson_River",
    "USGS-14303600": "Nestucca_River",
    "USGS-14305800": "Siletz_River",
    "USGS-14306500": "Alsea_River",
    "USGS-14307620": "Siuslaw_River",
    "USGS-14321000": "Umpqua_River",
    "USGS-14327055": "Coquille_River",
    "USGS-14327150": "Sixes_River",
    "USGS-14378430": "Rogue_River",
    "USGS-14400000": "Chetco_River"
}

for site_id, river_name in sites.items():
  # Get daily streamflow data (returns DataFrame and metadata)
  df, metadata = waterdata.get_daily(
      monitoring_location_id=site_id,
      parameter_code='00060',  # Discharge
      time='2023-12-31/2025-01-01'
  )

  filename = f"{site_id}_{river_name}.csv"
  df.to_csv(filename, index=False)
