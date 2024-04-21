--Cleaning data in SQL Queries 
select * from ..NashvilleHousing

--Populate Property Address data 
select *
from ..NashvilleHousing
where PropertyAddress is NULL
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from ..NashvilleHousing a
join ..NashvilleHousing b 
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from ..NashvilleHousing a
join ..NashvilleHousing b 
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL

--Breaking out Address Into Individual Columns (Addr, city, state)
select PropertyAddress
from ..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City
From ..NashvilleHousing

ALTER TABLE NashvilleHousing
add PropertySplitAddress NVARCHAR(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
add PropertySplitCity NVARCHAR(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

--Using parsename
select PARSENAME(replace(OwnerAddress, ',', '.') ,3)
, PARSENAME(replace(OwnerAddress, ',', '.') ,2)
, PARSENAME(replace(OwnerAddress, ',', '.') ,1)
from ..NashvilleHousing

ALTER TABLE NashvilleHousing
add OwnerSplitAddress NVARCHAR(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
add OwnerSplitCity NVARCHAR(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
add OwnerSplitState NVARCHAR(255)

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.') ,1)

--Change Y and N to Yes and No in SoldasVacant
select distinct(SoldasVacant), count(SoldasVacant)
from ..NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
    case when soldasvacant = 'Y' then 'Yes'
        when soldasvacant = 'N' then 'No'
    else SoldAsVacant
    END
from ..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
                        when soldasvacant = 'N' then 'No'
                        else SoldAsVacant
                    END

--Remove Duplicates 
WITH row_numCTE as(
select * , 
ROW_NUMBER() OVER (
    PARTITION BY ParcelID, 
    PropertyAddress,
    SalePrice,
    SaleDate, 
    LegalReference
    ORDER by UniqueID) ROW_NUM
from ..NashvilleHousing)

Delete from row_numCTE
where row_num > 1

--Delete unused Columns 
alter table ..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

select * from ..NashvilleHousing