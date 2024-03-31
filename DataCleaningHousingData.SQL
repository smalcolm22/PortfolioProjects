-- Cleaning data in SQL

SELECT *
FROM PortfolioProjects..NashvilleHousingData

-- Populate Property Address Data

SELECT *
FROM PortfolioProjects..NashvilleHousingData
--WHERE PropertyAddress is null
Order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousingData a
Join PortfolioProjects..NashvilleHousingData b
    on a.ParcelID = b.ParcelID
    and a.UniqueID != b.UniqueID
WHERE a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousingData a
Join PortfolioProjects..NashvilleHousingData b
    on a.ParcelID = b.ParcelID
    and a.UniqueID != b.UniqueID
WHERE a.PropertyAddress is null

-- Separating Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProjects..NashvilleHousingData

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) as City

FROM PortfolioProjects..NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add PropertySplitAddress NVARCHAR(255)

Update NashvilleHousingData
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousingData
Add PropertySplitCity NVARCHAR(255)

Update NashvilleHousingData
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))

SELECT OwnerAddress
FROM PortfolioProjects..NashvilleHousingData

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM PortfolioProjects..NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add OwnerSplitAddress NVARCHAR(255)

Update NashvilleHousingData
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousingData
Add OwnerSplitCity NVARCHAR(255)

Update NashvilleHousingData
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousingData
Add OwnerSplitState NVARCHAR(255)

Update NashvilleHousingData
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

-- Change Y and N to Yes and No in "Sold As Vacant" field

SELECT distinct(SoldAsVacant), count(SoldAsVacant)
FROM PortfolioProjects..NashvilleHousingData
group by SoldAsVacant
order by COUNT(SoldAsVacant)

SELECT SoldAsVacant,
    CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
FROM PortfolioProjects..NashvilleHousingData

Update NashvilleHousingData
Set SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    Order by UniqueID) row_num
FROM PortfolioProjects..NashvilleHousingData
--order by ParcelID
)
DELETE
FROM RowNumCTE
Where row_num >1

-- Delete Unused Columns

ALTER TABLE PortfolioProjects..NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

SELECT *
FROM PortfolioProjects..NashvilleHousingData