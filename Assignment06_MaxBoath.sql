--*************************************************************************--
-- Title: Assignment06
-- Author: MaxBoath
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,Max Boath,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_MaxBoath')
	 Begin 
	  Alter Database [Assignment06DB_MaxBoath] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_MaxBoath;
	 End
	Create Database Assignment06DB_MaxBoath;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_MaxBoath;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
Go
CREATE -- DROP
VIEW vCategories
WITH SCHEMABINDING
AS
	SELECT CategoryID, CategoryName
	FROM dbo.Categories;
Go

Select * from dbo.vCategories


Go
CREATE -- DROP
VIEW vProducts
WITH SCHEMABINDING
AS
	SELECT ProductId, ProductName, CategoryID, UnitPrice
	From dbo.Products;
Go
Select * from dbo.vProducts


Go
CREATE -- DROP
VIEW vEmployees
WITH SCHEMABINDING
AS
	SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	FROM dbo.Employees
Go
Select * from dbo.vEmployees


Go
CREATE -- DROP
VIEW vInventories
WITH SCHEMABINDING
AS
	SELECT InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
	FROM dbo.Inventories
Go
Select * from dbo.vInventories



-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On dbo.Categories to Public;
Grant Select On dbo.vCategories to Public;

Deny Select On dbo.Products to Public;
Grant Select On dbo.vProducts to Public;

Deny Select On dbo.Employees to Public;
Grant Select On dbo.vEmployees to Public;

Deny Select On dbo.Inventories to Public;
Grant Select On dbo.vInventories to Public;



-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
Go
CREATE -- DROP
VIEW vProductsByCategories
AS
	SELECT TOP 10000000000
	CategoryName, ProductName, UnitPrice
	FROM vCategories vC
	LEFT JOIN vProducts vP ON
	vC.CategoryID = vP.CategoryID
	ORDER BY 1, 2;
Go
SELECT * from vProductsByCategories


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Go
CREATE -- DROP
VIEW vInventoriesByProductsByDates
AS
	SELECT TOP 10000000000
	ProductName, InventoryDate, [Count]
	FROM vProducts as vP
	LEFT JOIN vInventories as vI ON
	vP.ProductID = vI.ProductID
	ORDER BY 1,3,2
Go
Select * from vInventoriesByProductsByDates

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

Go
CREATE -- DROP
VIEW vInventoriesByEmployeesByDates
AS
	SELECT DISTINCT TOP 100000000000
	InventoryDate, EmployeeName = EmployeeFirstName + ' ' + EmployeeLastName
	FROM vEmployees as vE
	INNER JOIN vInventories as vI ON
	vE.EmployeeID = vI.EmployeeID
	ORDER BY 1
GO
SELECT * from vInventoriesByEmployeesByDates



-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Go
CREATE -- DROP
VIEW vInventoriesByProductsByCategories
AS
	SELECT TOP 100000000
	CategoryName, ProductName, InventoryDate, [Count]
	FROM vCategories as vc
	INNER JOIN vProducts as vP ON
	vC.CategoryID = vP.CategoryID
	INNER JOIN vInventories as vI ON
	vP.ProductID = vI.ProductID
	ORDER BY 1, 2, 3, 4
GO
SELECT * from vInventoriesByProductsByCategories

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Go
CREATE -- DROP
VIEW vInventoriesByProductsByEmployees
AS
	SELECT TOP 100000000
	CategoryName, ProductName, InventoryDate, [Count], EmployeeName = EmployeeFirstName + ' ' + EmployeeLastName
	FROM vCategories as vc
	INNER JOIN vProducts as vP ON
	vC.CategoryID = vP.CategoryID
	INNER JOIN vInventories as vI ON
	vP.ProductID = vI.ProductID
	INNER JOIN vEmployees as vE ON
	vE.EmployeeID = vI.EmployeeID
	ORDER BY 3, 1, 2, 5
GO
SELECT * from vInventoriesByProductsByEmployees



-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Go
CREATE -- DROP
VIEW vInventoriesForChaiAndChangByEmployees
AS
	SELECT TOP 100000000
	CategoryName, ProductName, InventoryDate, [Count], EmployeeName = EmployeeFirstName + ' ' + EmployeeLastName
	FROM vCategories as vc
	INNER JOIN vProducts as vP ON
	vC.CategoryID = vP.CategoryID
	INNER JOIN vInventories as vI ON
	vP.ProductID = vI.ProductID
	INNER JOIN vEmployees as vE ON
	vE.EmployeeID = vI.EmployeeID
	WHERE vP.ProductName IN ('Chai', 'Chang')
	ORDER BY 3, 1, 2, 5
GO
SELECT * from vInventoriesForChaiAndChangByEmployees


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

GO
CREATE -- DROP
VIEW vEmployeesByManager
AS
	SELECT TOP 10000000000
	Manager = Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName,
	Employee = Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName
	FROM vEmployees as Emp
	INNER JOIN vEmployees as Mgr
	ON Emp.ManagerID = Mgr.EmployeeID
	ORDER BY 1, 2
GO
SELECT * FROM vEmployeesByManager


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.


-- NOTE: Ordered by ProductID, not ProductName, to match answer key.
Go
CREATE -- DROP
VIEW vInventoriesByProductsByCategoriesByEmployees
AS
	SELECT TOP 100000000
	vC.CategoryID,
	vC.CategoryName,
	vP.ProductID,
	vP.ProductName,
	vP.UnitPrice,
	vI.InventoryID,
	vI.InventoryDate,
	[Count],
	vEmp.EmployeeID,
	Employee = vEmp.EmployeeFirstName + ' ' + vEmp.EmployeeLastName,
	Manager = vMgr.EmployeeFirstName + ' ' + vMgr.EmployeeLastName
	FROM vCategories as vc
	INNER JOIN vProducts as vP ON
	vC.CategoryID = vP.CategoryID
	INNER JOIN vInventories as vI ON
	vP.ProductID = vI.ProductID
	INNER JOIN vEmployees as vEmp ON
	vEmp.EmployeeID = vI.EmployeeID
	INNER JOIN vEmployees as vMgr ON
	vEmp.ManagerID = vMgr.EmployeeID
	ORDER BY 2, 3, 6, 10
GO
SELECT * from vInventoriesByProductsByCategoriesByEmployees





-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories] -- 3
Select * From [dbo].[vInventoriesByProductsByDates] --4
Select * From [dbo].[vInventoriesByEmployeesByDates] --5
Select * From [dbo].[vInventoriesByProductsByCategories] --6
Select * From [dbo].[vInventoriesByProductsByEmployees] --7
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees] --8
Select * From [dbo].[vEmployeesByManager] --9 
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees] --10

/***************************************************************************************/