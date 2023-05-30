-- Standardize Date Format

SELECT *
FROM PortfolioProject..NashVilleHousing;

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashVilleHousing;

ALTER TABLE NashVilleHousing
ADD SaleConvertDate Date;

UPDATE NashVilleHousing
SET SaleConvertDate = CONVERT(Date, SaleDate);


-- Populate Property Address Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashVilleHousing a
JOIN PortfolioProject..NashVilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID] <> b.[UniqueID]
	WHERE a.PropertyAddress IS NULL;


-- Add the Populated Property Address Data to the table

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashVilleHousing a
JOIN PortfolioProject..NashVilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID] <> b.[UniqueID]
	WHERE a.PropertyAddress IS NULL;


-- Split PropertyAddress Into Individual Columns (Address, City)

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) City
FROM PortfolioProject..NashVilleHousing;


ALTER TABLE NashVilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashVilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashVilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashVilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress));



-- Another way to Split OwnerAddress Into Individual Columns (Address, City, State)

SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) Address,
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) City,
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) State
FROM PortfolioProject..NashVilleHousing;

ALTER TABLE NashVilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3);

ALTER TABLE NashVilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashVilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2);


ALTER TABLE NashVilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashVilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1);


-- Change Y and Z to Yes and No in 'SoldasVacant' Field.

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashVilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

-- Case Statement

SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END AS YandN
FROM PortfolioProject..NashVilleHousing;

UPDATE NashVilleHousing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashVilleHousing
GROUP BY SoldAsVacant;


-- Remove Duplicates

WITH RowNumCte AS (
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY 
						ParcelID,
						PropertyAddress, 
						SaleDate, SalePrice,
						LegalReference 
						ORDER BY UniqueID
							) Row_Num
FROM PortfolioProject..NashVilleHousing)

DELETE
FROM RowNumCte
WHERE Row_Num > 1;


-- Remove Unused Columns

SELECT *
FROM PortfolioProject..NashVilleHousing;

ALTER TABLE PortfolioProject..NashVilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict;