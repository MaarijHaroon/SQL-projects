------------------------------------ DATA CLEANING SQL PROJECT--------------------------------------------------------------------------------

-- SELECTING ALL OF THE DATA FROM OUR TABLE
SELECT *
FROM housing_data

--CHANGING THE FORMAT OF OUR SALEDATE
ALTER TABLE housing_data
ADD Converted_date Date
UPDATE housing_data
SET Converted_date = CONVERT(DATE,SaleDate)

--Populating empty spaces of property address

SELECT a.ParcelID,a.PropertyAddress,b.[ParcelID],b.[PropertyAddress],ISNULL(a.PropertyAddress,b.[PropertyAddress])
FROM housing_data a
JOIN housing_data b
	ON a.[ParcelID] = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE  a
SET PropertyAddress = ISNULL(a.[PropertyAddress],b.[PropertyAddress])
FROM housing_data a
JOIN housing_data b
	ON a.[ParcelID] = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--BREAKING PROPERTYADDRESS COLUMN INTO ADDRESS AND CITY

SELECT PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) City
FROM housing_data

ALTER TABLE housing_data
ADD property_split_Address nvarchar (255)

UPdate housing_data
SET property_split_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE housing_data
ADD City nvarchar (255)

UPdate housing_data
SET City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--BREAKING DOWN OWNER ADDRESS INTO ADDRESS,CITY,STATE

SElect OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3) owner_split_address
,PARSENAME(REPLACE(OwnerAddress,',','.'),2) owner_split_city
,PARSENAME(REPLACE(OwnerAddress,',','.'),1) owner_split_state
from housing_data

ALTER TABLE housing_data
ADD owner_split_address nvarchar (255)

UPdate housing_data
SET owner_split_address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE housing_data
ADD owner_split_city nvarchar (255)

UPdate housing_data
SET owner_split_city = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE housing_data
ADD owner_split_state nvarchar (255)

UPdate housing_data
SET owner_split_state = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 

--CHANGING 'Y' and 'N' OF SoldasVacant column into 'yes' and 'no'

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
from housing_data

Update housing_data
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
from housing_data

--REMOVING DUPLICATES

WITH COUNTROW_CTE AS(
SELECT *,
	ROW_NUMBER() OVER (
						PARTITION BY ParcelID,PropertyAddress,SalePrice,LandUse,SaleDate,City
						ORDER BY UniqueID
						) row_num2
FROM housing_data
)
DELETE
FROM COUNTROW_CTE
where row_num2  > 1
