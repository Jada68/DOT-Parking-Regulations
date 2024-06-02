---------------------------Mappinng NYC---------------------------

SELECT * FROM "DOT"."PavementEdge"
SELECT * FROM "DOT"."NYC_ParkingSIgns"
SELECT * FROM "DOT"."NYCPedRamps"


ALTER TABLE "DOT"."NYC_ParkingSIgns"
ADD COLUMN newgeom Geometry(Point, 4326);

ALTER TABLE NYCparkinglines
ADD COLUMN newgeom geometry(LineString, 4326);

UPDATE NYCparkinglines
SET newgeom = ST_Transform(line_geometry, 4326);

SELECT ST_SRID(line_geometry) AS srid
FROM NYCparkinglines;

SELECT * FROM NYCparkinglines

----Make Geometry column----
UPDATE "DOT"."NYC_ParkingSIgns"
SET newgeom = ST_SetSRID(ST_MakePoint(
	CASE WHEN sign_x_coord = '' THEN NULL ELSE CAST( sign_x_coord AS FLOAT) END, 
	CASE WHEN sign_y_coord = '' THEN NULL ELSE CAST(sign_y_coord AS FLOAT) END
),4326);

--Spatial Index
CREATE INDEX NYCparkingregsigns_spatial_index
ON "DOT"."NYC_ParkingSIgns"
USING GIST(geom);

CREATE INDEX NYCpedramps_spatial_index
ON "DOT"."NYCPedRamps"
USING GIST(geom);

CREATE INDEX NYCPaveedge_spatial_index
ON "DOT"."PavementEdge"
USING GIST(geom);

CREATE INDEX NYC_clipped_pave_spatial_index
ON NYC_clipped_pave
USING GIST(geom);

CREATE INDEX NYCparkinglines_spatial_index
ON NYCparkinglines
USING GIST(newgeom);
-------------------------------------------------------------------------------
-- Create a new table to store the buffered points
ALTER TABLE "DOT"."NYCPedRamps" ADD COLUMN buffer_geometry GEOMETRY;

UPDATE "DOT"."NYCPedRamps"
SET buffer_geometry = ST_Buffer(geom::geography, 10)::geometry;
SELECT * FROM "DOT"."NYCPedRamps"
----------------------------------------------------------------------
CREATE TABLE NYC_clipped_pave AS

SELECT ls.*
FROM "DOT"."PavementEdge" ls
JOIN "DOT"."NYCPedRamps" rp ON ST_Intersects(ls.geom, rp.buffer_geometry);

-----------------------------------------------------------------------------
SELECT * FROM NYCparkinglines
DROP TABLE NYCparkinglines
CREATE TABLE NYCparkinglines AS (
    WITH closest_points AS (
        SELECT
            ROW_NUMBER() OVER () AS row_num,
            p1.id AS start_point_id,
            p2.id AS end_point_id,
            ST_MakeLine(p1.geom, ST_Transform(p2.closest_geom, 4326)) AS line_geometry
        FROM
            "DOT"."NYC_ParkingSIgns" p1
        JOIN LATERAL (
            SELECT
                p2.id,
                ST_Distance(p1.geom, p2.geom) AS distance,
                p2.geom AS closest_geom,
                MAX(p2.sg_arrow_d) AS common_direction
            FROM
                "DOT"."NYC_ParkingSIgns" p2
            WHERE
                p1.id != p2.id  
                AND p1.signdesc1 = p2.signdesc1
                AND ST_DWithin(p1.geom, p2.geom, 0.001) -- Limit the search space
            GROUP BY
                p2.id, p2.geom
            ORDER BY
                ST_Distance(p1.geom, p2.geom)
            LIMIT 1
        ) p2 ON true
        WHERE
            NOT EXISTS (
                SELECT 1
                FROM NYC_clipped_pave s
                WHERE ST_Intersects(ST_MakeLine(p1.geom, ST_Transform(p2.closest_geom, 4326)), ST_Transform(s.geom, 4326))
            )
        OFFSET 0
        LIMIT 10000
    )
    SELECT *
    FROM closest_points
);

CREATE INDEX ON "DOT"."Parking_Regulation_Locations_Signs" USING GIST(newgeom);
CREATE INDEX ON "DOT"."Parking_Regulation_Locations_Signs" USING GIST(closest_geom);
CREATE INDEX ON NYC_clipped_pave USING GIST(geom);
------------------------------------------

CREATE TEMPORARY TABLE closest_points_temp AS (
    SELECT
        p1.id AS start_point_id,
        p2.id AS end_point_id,
        ST_MakeLine(p1.newgeom, ST_Transform(p2.closest_geom, 4326)) AS line_geometry
    FROM
        "DOT"."Parking_Regulation_Locations_Signs" p1
    JOIN LATERAL (
        SELECT
            p2.id,
            ST_Distance(p1.newgeom, p2.newgeom) AS distance,
            p2.newgeom AS closest_geom,
            MAX(p2.arrow_direction) AS common_direction
        FROM
            "DOT"."Parking_Regulation_Locations_Signs" p2
        WHERE
            p1.id != p2.id  
            AND p1.sign_description = p2.sign_description
            AND ST_DWithin(p1.newgeom, p2.newgeom, 0.001) -- Limit the search space
        GROUP BY
            p2.id, p2.newgeom
        ORDER BY
            ST_Distance(p1.newgeom, p2.newgeom)
        LIMIT 1
    ) p2 ON true
    WHERE
        NOT EXISTS (
            SELECT 1
            FROM NYC_clipped_pave s
            WHERE ST_Intersects(ST_MakeLine(p1.newgeom, ST_Transform(p2.closest_geom, 4326)), ST_Transform(s.geom, 4326))
        )
);

CREATE TABLE NYCparkinglines AS (
    SELECT * FROM closest_points_temp
);

CREATE INDEX ON "DOT"."Parking_Regulation_Locations_Signs" USING GIST(newgeom);
CREATE INDEX ON "DOT"."Parking_Regulation_Locations_Signs" USING GIST(closest_geom);
CREATE INDEX ON NYC_clipped_pave USING GIST(geom);
``