-- Case insensitive drink names
CREATE TEMPORARY TABLE "drink_names_temp_alter" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "drink_id" int NOT NULL,
  "name" nvarchar(50) COLLATE NOCASE NOT NULL,
  "order" float NOT NULL
);

INSERT INTO "drink_names_temp_alter"( "id", "drink_id", "name", "order") SELECT "id", "drink_id", "name", "order" FROM "drink_names";

DROP TABLE "drink_names";

CREATE TABLE "drink_names" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "drink_id" int NOT NULL,
  "name" nvarchar(50) COLLATE NOCASE NOT NULL,
  "order" float NOT NULL,
  FOREIGN KEY ("drink_id") REFERENCES "drinks"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX "drink_names_idx_drink_id02" ON "drink_names" ("drink_id");

CREATE UNIQUE INDEX "drink_names_drink_id_order02" ON "drink_names" ("drink_id", "order");

CREATE UNIQUE INDEX "drink_names_name02" ON "drink_names" ("name" COLLATE NOCASE);

INSERT INTO "drink_names" SELECT "id", "drink_id", "name", "order" FROM "drink_names_temp_alter";

DROP TABLE "drink_names_temp_alter";

-- Case insensitive ingredient names
CREATE TEMPORARY TABLE "ingredients_temp_alter" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "kind_of_id" int,
  "materialized_path" varchar(255),
  "name" nvarchar(50) COLLATE NOCASE NOT NULL,
  "description" ntext
);

INSERT INTO "ingredients_temp_alter"( "id", "kind_of_id", "materialized_path", "name", "description") SELECT "id", "kind_of_id", "materialized_path", "name", "description" FROM "ingredients";

DROP TABLE "ingredients";

CREATE TABLE "ingredients" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "kind_of_id" int,
  "materialized_path" varchar(255),
  "name" nvarchar(50) COLLATE NOCASE NOT NULL,
  "description" ntext,
  FOREIGN KEY ("kind_of_id") REFERENCES "ingredients"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX "ingredients_idx_kind_of_id02" ON "ingredients" ("kind_of_id");

CREATE UNIQUE INDEX "ingredients_name02" ON "ingredients" ("name" COLLATE NOCASE);

INSERT INTO "ingredients" SELECT "id", "kind_of_id", "materialized_path", "name", "description" FROM "ingredients_temp_alter";

DROP TABLE "ingredients_temp_alter";

-- Case insensitive unit names
CREATE TEMPORARY TABLE "units_temp_alter" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "name" nvarchar(50) COLLATE NOCASE NOT NULL,
  "gills" float
);

INSERT INTO "units_temp_alter"( "id", "name", "gills") SELECT "id", "name", "gills" FROM "units";

DROP TABLE "units";

CREATE TABLE "units" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "name" nvarchar(50) COLLATE NOCASE NOT NULL,
  "gills" float
);

CREATE UNIQUE INDEX "units_name02" ON "units" ("name" COLLATE NOCASE);

INSERT INTO "units" SELECT "id", "name", "gills" FROM "units_temp_alter";

DROP TABLE "units_temp_alter";

-- Case insensitive user names
CREATE TEMPORARY TABLE "users_temp_alter" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "name" nvarchar(50) COLLATE NOCASE NOT NULL
);

INSERT INTO "users_temp_alter"( "id", "name") SELECT "id", "name" FROM "users";

DROP TABLE "users";

CREATE TABLE "users" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "name" nvarchar(50) COLLATE NOCASE NOT NULL
);

CREATE UNIQUE INDEX "users_name02" ON "users" ("name" COLLATE NOCASE);

INSERT INTO "users" SELECT "id", "name" FROM "users_temp_alter";

DROP TABLE "users_temp_alter";
