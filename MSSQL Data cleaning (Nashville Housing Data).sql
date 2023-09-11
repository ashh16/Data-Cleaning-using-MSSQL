-- Data cleaning 
select * 
FROM DataDB.dbo.[Nashvil Housing]

-- Standardize date format 
SELECT saleDate, CONVERT(date, SaleDate)
FROM DataDB.dbo.[Nashvil Housing]

UPDATE [Nashvil Housing]
SET SaleDate = CONVERT(date, SaleDate)

Alter Table [Nashvil Housing]
Add SaleDateConverted Date;

UPDATE [Nashvil Housing]
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT * FROM DataDB.dbo.[Nashvil Housing]

-- Populate Property address Data 
select * 
FROM DataDB.dbo.[Nashvil Housing]
where PropertyAddress is NULL
order by ParcelID
/* Here property address is null in many places.
We are using order by parcelId to know that there some repeated
parcel ids and we need to check if they have same addresses
*/

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
FROM DataDB.dbo.[Nashvil Housing] a
join DataDB.dbo.[Nashvil Housing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL
/* As we guessed there were repeated parcel ids with same property addresses
so now we will use 'join' function using unique id as key .
This way we can get the values of other columns from another table which has similar value for our column*.
We basically have values for null values but thses are not populated.
So we will use ISNULL function to populate them, ISNULL basically says
if this condition is null then put this on that place */

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataDB.dbo.[Nashvil Housing] a
join DataDB.dbo.[Nashvil Housing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from DataDB.dbo.[Nashvil Housing] a 
JOIN DataDB.dbo.[Nashvil Housing] b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-- Breaking out address into individual columns (addres, city, State)
select PropertyAddress
FROM DataDB.dbo.[Nashvil Housing]

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as address
FROM DataDB.dbo.[Nashvil Housing]
/* Here this code is selecting substring from the property address column,
which is at 1st index & CHARINDEX returns the string/string-position of the 
1st occurance string, now we added -1 in query bcuz we want string befor ',' .
before adding -1 output was something like- (1400 ROSA L PARKS BLVD,) and we dont 
really want that comma so we used -1 to remove last string which is comma */

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as address
,SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as address
FROM DataDB.dbo.[Nashvil Housing]
/* Here if we take that +1 after proprty address we will comma in our next column
which we dont want therefor we are skiping that comma and directly taking next string.
also in 2nd substring we are replacing 1 with charindex .
Now we have two different columns */

Alter Table [Nashvil Housing]
Add PropertySplitAddress NVARCHAR(255);

UPDATE [Nashvil Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table [Nashvil Housing]
Add PropertySplitCity NVARCHAR(255);

UPDATE [Nashvil Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
/* We cant seperate two values from one column without creating two other columns .
so here we created we two new column and add values into them. 
Same thing we did while standardizing date format in above code. */

SELECT *
from DataDB.dbo.[Nashvil Housing]

SELECT OwnerAddress
FROM DataDB.dbo.[Nashvil Housing]

-- 2nd method for seperating columns using "PARSENAME"
select 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)
from DataDB.dbo.[Nashvil Housing]

ALTER TABLE [Nashvil Housing]
Add OwnerSplitAddress NVARCHAR(255);

UPDATE [Nashvil Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)

Alter Table [Nashvil Housing]
Add OwnerSplitCity NVARCHAR(255);

UPDATE [Nashvil Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)

ALTER TABLE [Nashvil Housing]
Add OwnerSpliState NVARCHAR(255);

UPDATE [Nashvil Housing]
SET OwnerSpliState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)

SELECT *
from DataDB.dbo.[Nashvil Housing]

-- Change Y and N to Yes snd No in 'Sold as Vacant' field
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataDB.dbo.[Nashvil Housing]
GROUP BY SoldAsVacant
ORDER BY 2 
/* Here order by 2 query gives result in aescending order 
If we want it in descending order we can use order by 2 DESC */

SELECT SoldAsVacant
, CASE when SoldAsVacant = 'Y' Then 'Yes'
       when SoldAsVacant = 'N' Then 'No'
       Else SoldAsVacant
       END
from DataDB.dbo.[Nashvil Housing]

update [Nashvil Housing]
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
        when SoldAsVacant = 'N' Then 'No'
        Else SoldAsVacant
        END

SELECT SoldAsVacant
FROM DataDB.dbo.[Nashvil Housing]


-- Remove Duplicates
WITH RowNumCTE AS (
select *,
    ROW_NUMBER() OVER(
        PARTITION BY ParcelID,
                     PropertyAddress,
                     SalePrice,
                     SaleDate,
                     LegalReference
                     ORDER BY
                         UniqueID 
                        ) row_num

from DataDB.dbo.[Nashvil Housing]
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

SELECT *
FROM DataDB.dbo.[Nashvil Housing]


-- Delete Unused Columns
SELECT *
FROM DataDB.dbo.[Nashvil Housing]

ALTER TABLE DataDB.dbo.[Nashvil Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

SELECT *
FROM DataDB.dbo.[Nashvil Housing]

ALTER TABLE DataDB.dbo.[Nashvil Housing]
DROP COLUMN SaleDate

SELECT *
FROM DataDB.dbo.[Nashvil Housing]
