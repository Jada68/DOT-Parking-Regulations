import geopandas as gpd
from shapely.geometry import LineString

# from shapely import STRtree
from tqdm import tqdm
import numpy as np
from scipy.spatial import cKDTree

# Load the data
parking_signs: gpd.GeoDataFrame = gpd.read_file(
    "Parking_Regulation_Shapefile/Parking_Regulation_Shapefile.shp"
)
print("Parking signs loaded")

nyc_pave_edge: gpd.GeoDataFrame = gpd.read_file("NYCPaveEdge/Clipped_NYCPaveEdge.shp")
print("NYC pave edges loaded")


# Ensure CRS is set to EPSG:4326 (WGS84)
parking_signs = parking_signs.to_crs(epsg=2263)
nyc_pave_edge = nyc_pave_edge.to_crs(epsg=2263)

# Create a spatial index for faster nearest neighbor search
# spatial_index: STRtree = parking_signs.sindex
# Create spatial index
nA = np.array(list(parking_signs.geometry.apply(lambda x: (x.x, x.y))))
btree = cKDTree(nA)


# Function to find the nearest point
def find_nearest(point, df, exclusion_id):
    # possible_matches_index = list(spatial_index.nearest(point))

    possible_matches_index = btree.query([point.x, point.y], k=5)[1]
    # print(possible_matches_index)

    possible_matches = df.iloc[possible_matches_index]
    # possible_matches = possible_matches.to_crs(epsg=4326)
    # print(possible_matches)
    possible_matches = possible_matches[
        (possible_matches.index != exclusion_id)
        & (possible_matches["SIGNDESC"] == df.loc[exclusion_id, "SIGNDESC"])
    ]
    # possible_matches = possible_matches.to_crs(epsg=4326)

    if len(possible_matches) > 0:
        nearest = possible_matches.distance(point).sort_values().index[0]
        return df.loc[nearest]
    return None


# Create lines between nearest points
lines = []
with tqdm(total=len(parking_signs)) as pbar:
    for idx, row in parking_signs.iterrows():
        nearest = find_nearest(row.geometry, parking_signs, idx)
        if nearest is not None:
            line = LineString([row.geometry, nearest.geometry])
            if not any(nyc_pave_edge.intersects(line)):
                lines.append(
                    {
                        "start_point_id": idx,
                        "end_point_id": nearest.name,
                        "line_geometry": line,
                        "common_direction": nearest["SG_ARROW_D"],
                        "sign_desc": row["SIGNDESC"],
                    }
                )
        pbar.update(1)

# Create GeoDataFrame from lines
nyc_parking_lines = gpd.GeoDataFrame(lines, geometry="line_geometry", crs="EPSG:2263")

# Save to file
nyc_parking_lines.to_file("NYCParkinglines.geojson", driver="GeoJSON")
