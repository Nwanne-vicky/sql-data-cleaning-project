 select *
from PortfolioVicky.dbo.NashvilleData

--standardize date
select saleDate, SaleDateConverted
from portfolioVicky.dbo.NashvilleData

Alter TABLE NashvilleData
Add SaleDateConverted date

update NashvilleData
set SaleDateConverted = CONVERT(DATE, SaleDate)


--populate property address data
select * 
from PortfolioVicky.dbo.NashvilleData
--where PropertyAddress is NOT null
order by ParcelID

select a.parcelID, b.parcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleData a
join NashvilleData b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set a.propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleData a
join NashvilleData b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


--spliting the propertyAddress

select *
from PortfolioVicky.dbo.NashvilleData


select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))
from NashvilleData

Alter TABLE NashvilleData
Add ProperysplitAddress nvarchar(300)

update NashvilleData
set ProperysplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter TABLE NashvilleData
Add ProperysplitCity nvarchar(300)

update NashvilleData
set ProperysplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))


--splitting the ownerAddress
select *
from PortfolioVicky.dbo.NashvilleData
order by ParcelID

select PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from PortfolioVicky.dbo.NashvilleData

Alter TABLE NashvilleData
Add OwnersplitAddress nvarchar(300)

update NashvilleData
set OwnersplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)


Alter TABLE NashvilleData
Add OwnersplitCity nvarchar(300)

update NashvilleData
set OwnersplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)


Alter TABLE NashvilleData
Add OwnersplitState nvarchar(300)

update NashvilleData
set OwnersplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


--changing  Y and N TO YES AND NO
Select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioVicky.dbo.NashvilleData
Group by SoldAsVacant
order by 2

select  Distinct(SoldAsVacant), 
case When SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant 
End
from PortfolioVicky.dbo.NashvilleData

update NashvilleData
set SoldAsVacant = case When SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant 
End


--Removing duplicate
With RowNumCTE AS(
select *,
ROW_NUMBER() over (
Partition by ParcelID,
              PropertyAddress, 
              SaleDate,
              SalePrice,
              LegalReference 
              order by UniqueID
              ) row_num
from PortfolioVicky.dbo.NashvilleData
)

Delete 
from RowNumCTE
where row_num > 1


--deleting unnecessary column
select *
from PortfolioVicky.dbo.NashvilleData

Alter Table portfolio.dbo.NashvilleData
drop column PropertyAddress, OwnerAddress

--Deleting unnecessary row
select *
from PortfolioVicky.dbo.NashvilleData
where OwnerName is Null
    And OwnerAddress is Null
    And Acreage is Null
    And TaxDistrict is Null
    And LandValue is Null
    And BuildingValue is Null
    And TotalValue is Null


 BEGIN TRANSACTION;

DELETE FROM PortfolioVicky.dbo.NashvilleData
where OwnerName is Null
    And OwnerAddress is Null
    And Acreage is Null
    And TaxDistrict is Null
    And LandValue is Null
    And BuildingValue is Null
    And TotalValue is Null

    COMMIT;

    ROLLBACK;