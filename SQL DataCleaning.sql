-- cleaning Data in SQL Queries


-- How to standardize Date Format:

SELECT saledateconverted, CONVERT(date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing


update NashvilleHousing
set SaleDate=CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
add saledateconverted date;

update NashvilleHousing
set saledateconverted=CONVERT(date,SaleDate)


-- populate Property address Data:

---Verifying Null Values

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

--- Self Join Table :


SELECT old.ParcelID,old.PropertyAddress,new.ParcelID,new.PropertyAddress, ISNULL(old.propertyAddress,new.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing old
join PortfolioProject.dbo.NashvilleHousing new
on old.ParcelID= new.ParcelID
and old.[UniqueID ]<>new.[UniqueID ]
where old.PropertyAddress is null

update old
set PropertyAddress=ISNULL(old.propertyAddress,new.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing old
join PortfolioProject.dbo.NashvilleHousing new
on old.ParcelID=new.ParcelID
and old.[UniqueID ]<>new.[UniqueID ]
where old.PropertyAddress is null

--Breaking out address into individual columns (address,city,state)

---Working on property Address and City Using substring

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing


select
SUBSTRING(propertyAddress,1, CHARINDEX(',',propertyAddress)-1) as address,
SUBSTRING(propertyAddress, CHARINDEX(',',propertyAddress) +1, LEN(propertyAddress)) as city
FROM PortfolioProject.dbo.NashvilleHousing


--Creating Columns (Address and City)

ALTER TABLE NashvilleHousing
add PropertySplitAddress NVARCHAR (255);

update NashvilleHousing
set PropertySplitAddress= SUBSTRING(propertyAddress,1, CHARINDEX(',',propertyAddress)-1) 

ALTER TABLE NashvilleHousing
add Porpertysplitcity NVARCHAR (255);

update NashvilleHousing
set Porpertysplitcity = SUBSTRING(propertyAddress, CHARINDEX(',',propertyAddress) +1, LEN(propertyAddress))


--Working on owner Address Using Parsename

SELECT owneraddress
FROM PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing


Updating Information Using Parsename

ALTER TABLE NashvilleHousing
add ownerSplitAddress NVARCHAR (255);

update NashvilleHousing
set ownerSplitAddress= PARSENAME(replace(owneraddress,',','.'),3)

ALTER TABLE NashvilleHousing
add ownersplitcity NVARCHAR (255);

update NashvilleHousing
set ownersplitcity = PARSENAME(replace(owneraddress,',','.'),2)

ALTER TABLE NashvilleHousing
add ownersplistate NVARCHAR (255);

update NashvilleHousing
set ownersplistate = PARSENAME(replace(owneraddress,',','.'),1)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


--- Changing Y and N to yes and No in 'sold as vacant' field

select distinct(soldasvacant),COUNT(soldasvacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
CASE when soldasvacant= 'Y' THEN 'Yes'
     when soldasvacant= 'N' THEN 'No'
	 Else soldasvacant
	 End

from PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =CASE when soldasvacant= 'Y' THEN 'Yes'
     when soldasvacant= 'N' THEN 'No'
	 Else soldasvacant
	 End

--- Remove duplicates using CTE


WITH RowNumCTE as (
SELECT *,
 row_number () over(
         partition by parcelid,
		       propertyAddress,
	               SalePrice,
			SaleDate,
			LegalReference
			order by 
			uniqueid
			) row_num
FROM PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select*
from RowNumCTE
where row_num>1 
order by PropertyAddress


--Deleting Duplicates

WITH RowNumCTE as (
SELECT *,
 row_number () over(
         partition by parcelid,
		       propertyAddress,
	               SalePrice,
			SaleDate,
			LegalReference
			order by 
			uniqueid
			) row_num
FROM PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Delete*
from RowNumCTE
where row_num>1 



-- Delete unused columns

select*
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP column owneraddress,TaxDistrict, PropertyAddress,SaleDate

