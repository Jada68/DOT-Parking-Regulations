------------------------------FINAL PROJECT-----------------------------------

SELECT * FROM "ClippedPave"
SELECT * FROM "CroppedPaveEdge"
SELECT * FROM pg_stats WHERE schemaname = 'DOT'

ALTER TABLE "ClippedPave"
ADD COLUMN newgeom Geometry(MultiLineString, 4326);

UPDATE "ClippedPave"
SET newgeom = ST_Transform(geom, 4326);

SELECT * FROM "DOT"."ParkingSigns"
SELECT * FROM "DOT"."ClippedPave"

ALTER TABLE "ParkingSigns"
ADD COLUMN newgeom Geometry(Point, 4326);

UPDATE "ParkingSigns"
SET newgeom = ST_Transform(geom, 4326);

ALTER TABLE "DOT"."PedRamps"
ADD COLUMN newgeom Geometry(Point, 4326);

UPDATE "DOT"."PedRamps"
SET newgeom = ST_Transform(geom, 4326);


--Spatial Index
CREATE INDEX parkingsigns_spatial_index
ON "ParkingSigns"
USING GIST(newgeom);

CREATE INDEX paveedge_spatial_index
ON "ClippedPave"
USING GIST(newgeom);

---------------------------------------------------------------------------------
DROP TABLE separated_lines2
CREATE TABLE separated_lines2 AS (
    SELECT
        p1.id AS start_point_id,
        p2.id AS end_point_id,
        ST_MakeLine(p1.newgeom, ST_Transform(p2.closest_geom, 4326)) AS line_geometry
    FROM
        "DOT".ParkingSigns" p1
    JOIN LATERAL (
        SELECT
            p2.id,
            ST_Distance(p1.newgeom, p2.newgeom) AS distance,
            p2.newgeom AS closest_geom,
            MAX(p2.SG_ARROW_D) AS common_direction  -- Use MAX to get the common direction
        FROM
            "ParkingSigns" p2
        WHERE
            p1.id != p2.id  
            AND p1.signdesc = p2.signdesc  -- Add condition for matching description
        GROUP BY
            p2.id, p2.newgeom
        ORDER BY
            ST_Distance(p1.newgeom, p2.newgeom)
        LIMIT 1
    ) p2 ON true
    WHERE
        ST_DWithin(p1.newgeom, ST_Transform(p2.closest_geom, 4326), 0.001)
        AND NOT EXISTS (
            SELECT 1
            FROM "ClippedPave" s
            WHERE ST_Intersects(ST_MakeLine(p1.newgeom, ST_Transform(p2.closest_geom, 4326)), ST_Transform(s.geom, 4326))
        )
);

SELECT * FROM "DOT"."separated_lines2"

UPDATE "DOT"."separated_lines2"
SET line_geometry = ST_SetSRID(line_geometry, 4326)::geometry(LineString);

--------------------------------------------------------------------------------
WITH ConnectedPairs AS (
    SELECT
        p1.id AS start_point_id,
        p2.id AS end_point_id,
        ST_MakeLine(p1.newgeom, ST_Transform(p2.closest_geom, 4326)) AS line_geometry
    FROM
        "ParkingSigns" p1
    JOIN LATERAL (
        SELECT
            p2.id,
            ST_Distance(p1.newgeom, p2.newgeom) AS distance,
            p2.newgeom AS closest_geom,
            MAX(p2.SG_ARROW_D) AS common_direction  -- Use MAX to get the common direction
        FROM
            "ParkingSigns" p2
        WHERE
            p1.id != p2.id  
            AND p1.signdesc = p2.signdesc  -- Add condition for matching description
        GROUP BY
            p2.id, p2.newgeom
        ORDER BY
            ST_Distance(p1.newgeom, p2.newgeom)
        LIMIT 1
    ) p2 ON true
    WHERE
        ST_DWithin(p1.newgeom, ST_Transform(p2.closest_geom, 4326), 0.001)
        AND NOT EXISTS (
            SELECT 1
            FROM "ClippedPave" s
            WHERE ST_Intersects(ST_MakeLine(p1.newgeom, ST_Transform(p2.closest_geom, 4326)), ST_Transform(s.geom, 4326))
        )
)

SELECT DISTINCT ON (start_point_id, end_point_id)
    start_point_id,
    end_point_id,
    line_geometry
FROM ConnectedPairs;

--------------------------------------------------------------------------------------
-- Add foreign keys to SignEdgeConnections table
ALTER TABLE "DOT"."separated_lines"
ADD CONSTRAINT fk_start_id
FOREIGN KEY (start_point_id)
REFERENCES "DOT"."separated_lines2" (start_point_id);


--  Refresh materialized view if applicable
--REFRESH MATERIALIZED VIEW IF EXISTS your_materialized_view_name;

-- Analyze tables for better query optimization
ANALYZE "DOT"."ParkingSigns";
ANALYZE "DOT"."ClippedPave";


ALTER TABLE "DOT"."separated_lines"
ADD CONSTRAINT unique_constraint_name1 UNIQUE (start_point_id, end_point_id);

SELECT * FROM pg_stats WHERE schemaname = 'DOT'

UPDATE "DOT"."ParkingSigns" AS points
SET geom = ST_ClosestPoint("DOT".ClippedPave".geom, points.geom)
FROM "DOT"."ClippedPave" AS line
WHERE ST_DWithin(line.geom, points.geom, 0.001);


-- Create a new table to store the buffered points
CREATE TABLE buffered_points AS
SELECT
    id, -- Replace with your identifier column
    ST_Buffer(newgeom, 10) AS buffered_geom
FROM
    "DOT"."PedRamps";

SELECT * FROM buffered_points
-- Assuming you have a table called 'clippedpave' with a geometry column named 'geom'
-- Assuming you have created a buffered points table called 'buffered_points' with a geometry column named 'buffered_geom'

-- Create a new table to store the clipped line segments
CREATE TABLE clipped_segments AS
SELECT
    cp.id AS segment_id,
    bp.id AS point_id,
    ST_Intersection(cp.newgeom, bp.buffered_geom) AS clipped_geom
FROM
    "DOT"."ClippedPave" cp
JOIN
    buffered_points bp ON ST_Intersects(cp.geom, bp.buffered_geom);

SELECT * FROM "DOT"."PedRamps"

--------------------------------------------------------------------------
DROP TABLE separated_lines3
CREATE TABLE separated_lines3 AS (
    SELECT
        p1.id AS start_point_id,
        p2.id AS end_point_id,
        p1.signdesc AS start_point_description,
        p2.signdesc AS end_point_description,
        ST_MakeLine(p1.newgeom, ST_Transform(p2.closest_geom, 4326)) AS line_geometry
    FROM
        "DOT"."ParkingSigns" p1
    JOIN LATERAL (
        SELECT
            p2.id,
            p2.signdesc,
            ST_Distance(p1.newgeom, p2.newgeom) AS distance,
            p2.newgeom AS closest_geom,
            MAX(p2.SG_ARROW_D) AS common_direction  -- Use MAX to get the common direction
        FROM
            "DOT"."ParkingSigns" p2
        WHERE
            p1.id != p2.id  
            AND p1.signdesc = p2.signdesc  -- Add condition for matching description
        GROUP BY
            p2.id,p2.newgeom
        ORDER BY
            ST_Distance(p1.newgeom, p2.newgeom)
        LIMIT 1
    ) p2 ON true
    WHERE
        ST_DWithin(p1.newgeom, ST_Transform(p2.closest_geom, 4326), 0.001)
        AND NOT EXISTS (
            SELECT 1
            FROM "ClippedPave" s
            WHERE ST_Intersects(ST_MakeLine(p1.newgeom, ST_Transform(p2.closest_geom, 4326)), ST_Transform(s.geom, 4326))
        )
);

SELECT * FROM separated_lines3