-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Sat Apr  7 01:42:38 2012
-- 

--
-- Table: "drinks"
--
CREATE TABLE "drinks" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "description" ntext NOT NULL,
  "source" nvarchar(50),
  "variant_of_drink_id" int,
  FOREIGN KEY ("variant_of_drink_id") REFERENCES "drinks"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX "drinks_idx_variant_of_drink_id" ON "drinks" ("variant_of_drink_id");

--
-- Table: "ingredients"
--
CREATE TABLE "ingredients" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "parent" int,
  "materialized_path" varchar(255),
  "name" nvarchar(50) NOT NULL,
  "description" ntext
);

CREATE UNIQUE INDEX "ingredients_name" ON "ingredients" ("name");

--
-- Table: "units"
--
CREATE TABLE "units" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "name" nvarchar(50) NOT NULL,
  "gills" float
);

CREATE UNIQUE INDEX "units_name" ON "units" ("name");

--
-- Table: "users"
--
CREATE TABLE "users" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "name" nvarchar(50) NOT NULL
);

CREATE UNIQUE INDEX "users_name" ON "users" ("name");

--
-- Table: "drink_names"
--
CREATE TABLE "drink_names" (
  "id" INTEGER PRIMARY KEY NOT NULL,
  "drink_id" int NOT NULL,
  "name" nvarchar(50) NOT NULL,
  "order" float NOT NULL,
  FOREIGN KEY ("drink_id") REFERENCES "drinks"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX "drink_names_idx_drink_id" ON "drink_names" ("drink_id");

CREATE UNIQUE INDEX "drink_names_drink_id_order" ON "drink_names" ("drink_id", "order");

CREATE UNIQUE INDEX "drink_names_name" ON "drink_names" ("name");

--
-- Table: "inventory_items"
--
CREATE TABLE "inventory_items" (
  "ingredient_id" int NOT NULL,
  "user_id" int NOT NULL,
  PRIMARY KEY ("ingredient_id", "user_id"),
  FOREIGN KEY ("ingredient_id") REFERENCES "ingredients"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX "inventory_items_idx_ingredient_id" ON "inventory_items" ("ingredient_id");

CREATE INDEX "inventory_items_idx_user_id" ON "inventory_items" ("user_id");

--
-- Table: "drink_ingredients"
--
CREATE TABLE "drink_ingredients" (
  "drink_id" int NOT NULL,
  "ingredient_id" int NOT NULL,
  "unit_id" int,
  "amount" float,
  "arbitrary_amount" nvarchar(50),
  "notes" ntext,
  FOREIGN KEY ("drink_id") REFERENCES "drinks"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY ("ingredient_id") REFERENCES "ingredients"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY ("unit_id") REFERENCES "units"("id")
);

CREATE INDEX "drink_ingredients_idx_drink_id" ON "drink_ingredients" ("drink_id");

CREATE INDEX "drink_ingredients_idx_ingredient_id" ON "drink_ingredients" ("ingredient_id");

CREATE INDEX "drink_ingredients_idx_unit_id" ON "drink_ingredients" ("unit_id");
