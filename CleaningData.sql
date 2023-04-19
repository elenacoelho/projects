/* 
Limpeza de Dados utilizando SQL
*/

Select * 
from Portifolio..NashivileHousing



-- Padronização do formato da data

Select SaleDate2, CONVERT (date, SaleDate)
from Portifolio..NashivileHousing

ALTER table NashivileHousing
Add SaleDate2 Date 

UPDATE NashivileHousing
SET SaleDate2 = CONVERT (date, SaleDate)


-- Preencher dados do endereço da propiedade

Select *
from Portifolio..NashivileHousing
order by ParcelID 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portifolio..NashivileHousing a
JOIN Portifolio..NashivileHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portifolio..NashivileHousing a
JOIN Portifolio..NashivileHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- Dividindo o Endereço em diferentes colunas (cidade, estado, rua)

Select PropertyAddress
from Portifolio..NashivileHousing


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as City
from Portifolio..NashivileHousing

ALTER table NashivileHousing
Add SplitPropertyAddress nvarchar(255) 

UPDATE NashivileHousing
SET SplitPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER table NashivileHousing
Add SplitPropertyCity nvarchar(255) 

UPDATE NashivileHousing
SET SplitPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))

SELECT SplitPropertyCity, SplitPropertyAddress
FROM NashivileHousing



Select OwnerAddress
from Portifolio..NashivileHousing

Select
PARSENAME(REPLACE(OwnerAddress,',', '.'),3) -- rua
, PARSENAME(REPLACE(OwnerAddress,',', '.'),2) -- cidade
, PARSENAME(REPLACE(OwnerAddress,',', '.'),1) --estado
from Portifolio..NashivileHousing

ALTER table NashivileHousing
Add Owner_address nvarchar(255) 

UPDATE NashivileHousing
SET Owner_address = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER table NashivileHousing
Add owner_city nvarchar(255) 

UPDATE NashivileHousing
SET owner_city = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER table NashivileHousing
Add owner_state nvarchar(255) 

UPDATE NashivileHousing
SET owner_state = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)


-- Modificar "Y" e "N" para "Yes" ou "Não" no campo "vendido como vazio"

Select Distinct (soldasvacant), count(soldasvacant)
from Portifolio..NashivileHousing
Group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE 
When SoldAsVacant = 'Y' then 'Yes'
When SoldAsVacant = 'N' then 'No'
else SoldAsVacant
End
from Portifolio..NashivileHousing

UPDATE Portifolio..NashivileHousing
SET SoldAsVacant = CASE 
When SoldAsVacant = 'Y' then 'Yes'
When SoldAsVacant = 'N' then 'No'
else SoldAsVacant
End



-- Remover dados duplicados

With RowNumCte as(
Select *,
	ROW_NUMBER() over (
	PARTITION BY ParcelId, 
	PropertyAddress, 
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY UniqueId
	) row_num
from Portifolio..NashivileHousing
) 

DELETE
From RowNumCte
Where row_num>1



-- Apagar colunas não utilizadas
Select *
from Portifolio..NashivileHousing

ALTER TABLE Portifolio..NashivileHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate