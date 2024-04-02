--CLEANING DATA IN SQL

Select SaleDateConverted from Housing

Alter Table Housing
add SaleDateConverted Date;

Update Housing
SET SaleDateConverted = CONVERT(DATE,SaleDate)


--Populate Property Address Data

Select a.ParcelID, a.PropertyAddress, B.PropertyAddress, B.ParcelID, ISNULL(a.PropertyAddress,b.PropertyAddress) from Housing A
JOIN Housing B
	on A.ParcelID = B.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
WHere A.PropertyAddress is null

Update a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress) from Housing A
JOIN Housing B
	on A.ParcelID = B.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
WHere A.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)

Select
SUBSTRING(PropertyAddress,1,CHARIndex(',', PropertyAddress)-1) As Address,
SUBSTRING(PropertyAddress,CHARIndex(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address 

From Housing

Alter Table Housing
add PropertySplitAddress Nvarchar(255)

Update Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARIndex(',', PropertyAddress)-1)

Alter Table Housing
Add PropertySplitCity Nvarchar(255)

Update Housing 
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARIndex(',', PropertyAddress) +1, LEN(PropertyAddress))


--Spliting out the Owner address column using PARSENAME

Alter Table Housing
Add OwnerSplitAddress Nvarchar(255)

Update Housing 
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

Alter Table Housing
Add OwnerSplitCity Nvarchar(255)

Update Housing 
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

Alter Table Housing
Add OwnerSplitState Nvarchar(255)

Update Housing 
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

--Change Y and N to Yes and No in 'Sold as Vacant field

UPDATE Housing
Set SoldAsVacant =
CASE when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
END


Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From Housing
group by SoldAsVacant


--Remove Duplicates
WITH CTE AS(
Select *, ROW_NUMBER() Over(
Partition By ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
Order By ParcelID)RowNum
From Housing)
Delete from CTE Where RowNum > 1

--Delete Unused Columns

Alter Table Housing
Drop Column  OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
