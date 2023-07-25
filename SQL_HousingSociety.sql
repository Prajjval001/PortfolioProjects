/* 
--Cleaning Data of National Housing Society Using SQL
*/

SELECT * 
FROM PortfolioProject.dbo.NationalHousing;

-----------------------------------------------------------------------------------------------------------------------------------------


--Standard Date Format

SELECT SaleDateOnly, CONVERT(date, SaleDate) 
FROM PortfolioProject.dbo.NationalHousing;

UPDATE NationalHousing
SET SaleDate = CONVERT(date, SaleDate);

ALTER TABLE NationalHousing
ADD SaleDateOnly Date;

UPDATE NationalHousing
SET SaleDateOnly = CONVERT(date, SaleDate);


---------------------------------------------------------------------------------------------------------------------------------------------


--Popular Property Address Data

SELECT *
FROM PortfolioProject.dbo.NationalHousing
--WHERE PropertyAddress is Null
ORDER BY ParcelID


SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NationalHousing a
JOIN PortfolioProject.dbo.NationalHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is Null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NationalHousing a
JOIN PortfolioProject.dbo.NationalHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is Null


---------------------------------------------------------------------------------------------------------------------------------------------------------


--Breaking out Address into Individual Columns(Address, City, State)


SELECT PropertyAddress
FROM PortfolioProject.dbo.NationalHousing
--WHERE PropertyAddress is Null
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address

FROM PortfolioProject.dbo.NationalHousing


ALTER TABLE NationalHousing
ADD PropertyAddressSplit Nvarchar(255);

UPDATE NationalHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1 )

ALTER TABLE NationalHousing
ADD PropertyCity Nvarchar(255);

UPDATE NationalHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));


SELECT *
FROM PortfolioProject.dbo.NationalHousing


SELECT OwnerAddress
FROM PortfolioProject.dbo.NationalHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NationalHousing



ALTER TABLE NationalHousing
ADD OwnerAddressSplit Nvarchar(255);

UPDATE NationalHousing
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NationalHousing
ADD OwnerCity Nvarchar(255);

UPDATE NationalHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NationalHousing
ADD OwnerState Nvarchar(255);

UPDATE NationalHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM PortfolioProject.dbo.NationalHousing


-------------------------------------------------------------------------------------------------------------------------------------------------------------


--Change Y and N to Yes and No in "Sold as Vacant Field"

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.NationalHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM PortfolioProject.dbo.NationalHousing


UPDATE NationalHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END


------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Remove Duplicates


WITH Row_NumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num

FROM PortfolioProject.dbo.NationalHousing
)
SELECT *                        -- DELETE in place to delete duplicates
FROM Row_NumCTE
WHERE row_num > 1




SELECT *
FROM PortfolioProject.dbo.NationalHousing


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns 


SELECT *
FROM PortfolioProject.dbo.NationalHousing



ALTER TABLE PortfolioProject.dbo.NationalHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NationalHousing
DROP COLUMN SaleDate












