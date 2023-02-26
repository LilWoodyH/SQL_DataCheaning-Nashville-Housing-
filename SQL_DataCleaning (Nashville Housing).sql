
--Cleaning data in SQL

Select*
From Demo_1..NashvilleHousing

--1. Standardize data format

Select SaleDate, CONVERT(date, SaleDate)
From Demo_1..NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)


alter table NashvilleHousing
add Date date

update NashvilleHousing
set Date = CONVERT(date, SaleDate)

Select*
From Demo_1..NashvilleHousing
where PropertyAddress is null


-- 2. Deal the missing values of the PropertyAddress

select a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress
From Demo_1..NashvilleHousing a
join Demo_1..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Demo_1..NashvilleHousing a
join Demo_1..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Select PropertyAddress
From NashvilleHousing
where PropertyAddress is null


--3. Breaking out the address into Individual Colunms (Address, City, State)
select
substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
From Demo_1..NashvilleHousing

select substring(PropertyAddress,  CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress)) as City
From Demo_1..NashvilleHousing

alter table NashvilleHousing
add Address nvarchar(255)

update NashvilleHousing
set Address = substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing
add City nvarchar(255)

update NashvilleHousing
set City = substring(PropertyAddress,  CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress))

select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
--PARSENAME(OwnerAddress,1),
--PARSENAME(OwnerAddress,2),
--PARSENAME(OwnerAddress,3)
From Demo_1..NashvilleHousing
where OwnerAddress is not null

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerCity nvarchar(255)

update NashvilleHousing
set OwnerCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerState nvarchar(255)

update NashvilleHousing
set OwnerState = PARSENAME(Replace(OwnerAddress,',','.'),1)

select*
From Demo_1..NashvilleHousing


-- 4.Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
From Demo_1..NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
case when SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'Y' then 'Yes'
	else SoldAsVacant
	end
From Demo_1..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'Y' then 'Yes'
	else SoldAsVacant
	end

--5. Removing the duplicates

with RownumCTE as (
select*,
	ROW_NUMBER() over (
	partition by Parcelid,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
From Demo_1..NashvilleHousing)

select*
From RownumCTE
where row_num > 1

-- 6.Delete Unused Columns

Select*
From Demo_1..NashvilleHousing

Alter table Demo_1..NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, SaleDate, TaxDistrict