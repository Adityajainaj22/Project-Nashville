/*

Cleaning Data in SQL Queries - Nashville Housing Data
Nashville Housing - Data Cleaning

*/

--- PART A --- 
-- Basic Query
Select *
From ProjectNashville..NashvilleData$

--------------------------------------------------------------------------------------------------------------------------
--- PART B ---

-- a) Standardizing Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From ProjectNashville..NashvilleData$

-- Updating the database
Update ProjectNashville..NashvilleData$
SET SaleDate = CONVERT(Date,SaleDate)

-- Adding a table and then converting it
ALTER TABLE ProjectNashville..NashvilleData$
Add SaleDateConverted Date;

Update ProjectNashville..NashvilleData$
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Checking if it converted
Select SaleDateConverted
From ProjectNashville..NashvilleData$

 --------------------------------------------------------------------------------------------------------------------------

-- b) Populate Property Address data

-- Looking at null values
Select *
From ProjectNashville..NashvilleData$
--Where PropertyAddress is null
order by ParcelID


-- Using self join to check
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From ProjectNashville..NashvilleData$ a
JOIN ProjectNashville..NashvilleData$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Using self join and IS NULL to populate
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From ProjectNashville..NashvilleData$ a
JOIN ProjectNashville..NashvilleData$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Updating the address in the table
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From ProjectNashville..NashvilleData$ a
JOIN ProjectNashville..NashvilleData$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- c) Breaking out Property Address into Individual Columns (Address, City, State)
-- Basic look at the data
Select PropertyAddress
From ProjectNashville..NashvilleData$
--Where PropertyAddress is null
--order by ParcelID


-- Splitting the property address into 2 parts
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
From ProjectNashville..NashvilleData$


-- Altering table to add a separate column of Address and then updating it
ALTER TABLE ProjectNashville..NashvilleData$
Add PropertySplitAddress Nvarchar(255);

Update ProjectNashville..NashvilleData$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


-- Altering table to add a separate column of City and then updating it
ALTER TABLE ProjectNashville..NashvilleData$
Add PropertySplitCity Nvarchar(255);

Update ProjectNashville..NashvilleData$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


-- Checking our table if it has been altered
Select *
From ProjectNashville..NashvilleData$


--------------------------------------------------------------------------------------------------------------------------
-- d) Breaking out Owner Address into Individual Columns (Address, City, State)
-- Basic look at the data
Select OwnerAddress
From ProjectNashville..NashvilleData$


-- Splitting the property address into 3 parts
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) -- Address
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) -- City
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) -- State
From ProjectNashville..NashvilleData$


-- Altering table to add a separate column of Address and then updating it
ALTER TABLE ProjectNashville..NashvilleData$
Add OwnerSplitAddress Nvarchar(255);

Update ProjectNashville..NashvilleData$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


-- Altering table to add a separate column of City and then updating it
ALTER TABLE ProjectNashville..NashvilleData$
Add OwnerSplitCity Nvarchar(255);

Update ProjectNashville..NashvilleData$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


-- Altering table to add a separate column of State and then updating it
ALTER TABLE ProjectNashville..NashvilleData$
Add OwnerSplitState Nvarchar(255);

Update ProjectNashville..NashvilleData$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- Checking our table if it has been altered
Select *
From ProjectNashville..NashvilleData$


--------------------------------------------------------------------------------------------------------------------------


-- e) Change Y and N to Yes and No in "Sold as Vacant" field
-- Basic Query to check the data
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From ProjectNashville..NashvilleData$
Group by SoldAsVacant
order by 2


-- Checking - Y to Yes and N to No
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From ProjectNashville..NashvilleData$


-- Updating - Y to Yes and N to No
Update ProjectNashville..NashvilleData$
SET SoldAsVacant = CASE 
	   When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

	   		 	  
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- f) Remove Duplicates
-- CTE to find out duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From ProjectNashville..NashvilleData$
--order by ParcelID
)

Select * -- (DELETE in place of select * deletes duplicates)
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- Basic Query
Select *
From ProjectNashville..NashvilleData$




---------------------------------------------------------------------------------------------------------

-- g) Delete Unused Columns
-- Basic Query
Select *
From ProjectNashville..NashvilleData$


-- Alter table to delete unused columns
ALTER TABLE ProjectNashville..NashvilleData$
--DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced (looks cooler too) and have to configure server appropriately to do correctly


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE ProjectNashville 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE ProjectNashville;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE ProjectNashville;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

