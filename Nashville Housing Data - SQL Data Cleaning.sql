/*

Cleaning data in SQL queries

*/

SELECT *
FROM NashvilleProject.dbo.Nashville



-- Standardize date format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleProject.dbo.Nashville

UPDATE Nashville
SET SaleDate = CONVERT(Date, SaleDate)


-- If it doesen't update properly

ALTER TABLE Nashville
ADD SaleDateConverted Date;

UPDATE Nashville
SET SaleDateConverted = CONVERT(Date, SaleDate)



---------------------------------------------------------------------------------------------------------------------------------

-- Populate Proprety Address data

SELECT *
FROM NashvilleProject.dbo.Nashville
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleProject.dbo.Nashville a
JOIN NashvilleProject.dbo.Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleProject.dbo.Nashville a
JOIN NashvilleProject.dbo.Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null



---------------------------------------------------------------------------------------------------------------------------------

-- Breaking out address into individual columns (address, city, state)

SELECT PropertyAddress
FROM NashvilleProject.dbo.Nashville

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
FROM NashvilleProject.dbo.Nashville

ALTER TABLE Nashville
ADD PropertySplitAddress Nvarchar(255);

UPDATE Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Nashville
ADD PropertySplitCity Nvarchar(255);

UPDATE Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



-- Another way to break out address

SELECT OwnerAddress
FROM NashvilleProject.dbo.Nashville

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM NashvilleProject.dbo.Nashville


ALTER TABLE Nashville
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Nashville
ADD OwnerSplitCity Nvarchar(255);

UPDATE Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Nashville
ADD OwnerSplitState Nvarchar(255);

UPDATE Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM NashvilleProject.dbo.Nashville



---------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleProject.dbo.Nashville
Group by SoldAsVacant
order by 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleProject.dbo.Nashville

UPDATE Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	                    WHEN SoldAsVacant = 'N' THEN 'No'
	                    ELSE SoldAsVacant
	                    END



---------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
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

FROM NashvilleProject.dbo.Nashville
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



--------------------------------------------------------------------------------------------------------------------------------

-- Delet unused columns

SELECT *
FROM NashvilleProject.dbo.Nashville

ALTER TABLE NashvilleProject..NAshville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

