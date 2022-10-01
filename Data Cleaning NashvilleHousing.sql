/*

DATA CLEANING QUERIES

*/

SELECT * 
FROM DataCleaningHousingData.dbo.NashvilleHousing


-------------------------------- Standarize Data Format:

SELECT SaleDate, CONVERT(date,SaleDate)
FROM DataCleaningHousingData.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateStd Date;

UPDATE NashvilleHousing
SET SaleDateStd = CONVERT(date,SaleDate)

-------------------------------- Fill Null Values in PropertyAddress:

SELECT * 
FROM DataCleaningHousingData.dbo.NashvilleHousing
WHERE PropertyAddress is null

-- I noticed that addresses that have similar ParcelID have the same address

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningHousingData.dbo.NashvilleHousing a
JOIN DataCleaningHousingData.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null
ORDER BY a.ParcelID

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningHousingData.dbo.NashvilleHousing a
JOIN DataCleaningHousingData.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-------------------------------- Breaking out Address into (Adress, City, State):

SELECT *
FROM DataCleaningHousingData.dbo.NashvilleHousing

SELECT SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) as City
FROM DataCleaningHousingData.dbo.NashvilleHousing

SELECT SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) as Address
FROM DataCleaningHousingData.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertyAddStreet nvarchar(255), 
	PropertyAddCity nvarchar(255)

Update NashvilleHousing
SET PropertyAddStreet = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1), 
	PropertyAddCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))


-------------------------------- OwnerAddress:


SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM DataCleaningHousingData.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerAddStreet nvarchar(255), 
	OwnerAddCity nvarchar(255),
	OwnerAddState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerAddStreet =  PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
	OwnerAddCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
	OwnerAddState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


-------------------------------- Change Y and N to Yes and No in "Sold as Vacant" field:

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaningHousingData.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM DataCleaningHousingData.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


-------------------------------- Remove Duplicates

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
					) row_num
FROM DataCleaningHousingData.dbo.NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num = 2

-------------------------------- Delete unused Columns:

SELECT *
FROM DataCleaningHousingData.dbo.NashvilleHousing


ALTER TABLE DataCleaningHousingData.dbo.NashvilleHousing
DROP COLUMN SaleDate;