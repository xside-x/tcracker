/*
  Warnings:

  - The values [CPU,GPU,RAM,SSD,MOTHERBOARD,PSU,CASE,COOLER] on the enum `ComponentType` will be removed. If these variants are still used in the database, this will fail.
  - You are about to drop the `BuildsComponent` table. If the table is not empty, all the data it contains will be lost.

*/
-- AlterEnum
BEGIN;
CREATE TYPE "ComponentType_new" AS ENUM ('cpu', 'gpu', 'ram', 'ssd', 'motherboard', 'psu', 'case', 'cooler');
ALTER TABLE "Component" ALTER COLUMN "type" TYPE "ComponentType_new" USING ("type"::text::"ComponentType_new");
ALTER TYPE "ComponentType" RENAME TO "ComponentType_old";
ALTER TYPE "ComponentType_new" RENAME TO "ComponentType";
DROP TYPE "public"."ComponentType_old";
COMMIT;

-- DropForeignKey
ALTER TABLE "BuildsComponent" DROP CONSTRAINT "BuildsComponent_buildId_fkey";

-- DropForeignKey
ALTER TABLE "BuildsComponent" DROP CONSTRAINT "BuildsComponent_componentId_fkey";

-- DropTable
DROP TABLE "BuildsComponent";

-- CreateTable
CREATE TABLE "BuildComponent" (
    "id" TEXT NOT NULL,
    "buildId" TEXT NOT NULL,
    "componentId" TEXT NOT NULL,

    CONSTRAINT "BuildComponent_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "BuildComponent_buildId_componentId_key" ON "BuildComponent"("buildId", "componentId");

-- AddForeignKey
ALTER TABLE "BuildComponent" ADD CONSTRAINT "BuildComponent_buildId_fkey" FOREIGN KEY ("buildId") REFERENCES "Build"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BuildComponent" ADD CONSTRAINT "BuildComponent_componentId_fkey" FOREIGN KEY ("componentId") REFERENCES "Component"("id") ON DELETE CASCADE ON UPDATE CASCADE;
