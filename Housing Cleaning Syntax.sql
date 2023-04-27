/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Nashville_Housing].[dbo].[Housing_13_19]

 /*
Cleaning Data in SQL Queries
*/


SELECT *
FROM [Nashville_Housing].[dbo].[Housing_13_19]

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


--SELECT saleDateConverted, CONVERT(Date,SaleDate)
--FROM [Nashville_Housing].[dbo].[Housing_13_19]


UPDATE [Nashville_Housing].[dbo].[Housing_13_19]
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE [Nashville_Housing].[dbo].[Housing_13_19]
Add SaleDateConverted Date;

UPDATE [Nashville_Housing].[dbo].[Housing_13_19]
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM [Nashville_Housing].[dbo].[Housing_13_19]
--Where PropertyAddress is null
ORDER BY ParcelID



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Nashville_Housing].[dbo].[Housing_13_19] a
JOIN [Nashville_Housing].[dbo].[Housing_13_19] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Nashville_Housing].[dbo].[Housing_13_19] a
JOIN [Nashville_Housing].[dbo].[Housing_13_19] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM [Nashville_Housing].[dbo].[Housing_13_19]
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

FROM [Nashville_Housing].[dbo].[Housing_13_19]


ALTER TABLE [Nashville_Housing].[dbo].[Housing_13_19]
Add PropertySplitAddress Nvarchar(255);

Update [Nashville_Housing].[dbo].[Housing_13_19]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE[Nashville_Housing].[dbo].[Housing_13_19]
Add PropertySplitCity Nvarchar(255);

Update [Nashville_Housing].[dbo].[Housing_13_19]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




SELECT *
FROM [Nashville_Housing].[dbo].[Housing_13_19]





SELECT OwnerAddress
FROM [Nashville_Housing].[dbo].[Housing_13_19]


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM [Nashville_Housing].[dbo].[Housing_13_19]



ALTER TABLE [Nashville_Housing].[dbo].[Housing_13_19]
Add OwnerSplitAddress Nvarchar(255);

UPDATE [Nashville_Housing].[dbo].[Housing_13_19]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [Nashville_Housing].[dbo].[Housing_13_19]
Add OwnerSplitCity Nvarchar(255);

UPDATE [Nashville_Housing].[dbo].[Housing_13_19]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE [Nashville_Housing].[dbo].[Housing_13_19]
Add OwnerSplitState Nvarchar(255);

UPDATE [Nashville_Housing].[dbo].[Housing_13_19]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



SELECT *
From [Nashville_Housing].[dbo].[Housing_13_19]




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM [Nashville_Housing].[dbo].[Housing_13_19]
GROUP BY SoldAsVacant
ORDER BY 2




SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM [Nashville_Housing].[dbo].[Housing_13_19]

UPDATE [Nashville_Housing].[dbo].[Housing_13_19]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM [Nashville_Housing].[dbo].[Housing_13_19]
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



SELECT *
FROM [Nashville_Housing].[dbo].[Housing_13_19]





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



SELECT *
FROM [Nashville_Housing].[dbo].[Housing_13_19]

ALTER TABLE [Nashville_Housing].[dbo].[Housing_13_19]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO




