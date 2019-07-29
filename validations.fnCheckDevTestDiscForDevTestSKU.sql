-- ================================================
-- Template generated from Template Explorer using:
-- Create Multi-Statement Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tripathi, Shubhang
-- Create date: 29 July 2019
-- Description:	Returns a list of Dev/Test SKU's which do not have a Dev/Test discount
--				More description could be found at https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/115
-- =============================================
CREATE FUNCTION [validations].[fnCheckDevTestDiscForDevTestSKU]
(
	
)
RETURNS @rtnTable TABLE (
	[Event ID] INT NULL,
	[Work Item Type] nvarchar(max) null,
	[Work Item ID] INT NULL,
	[Validation Name] nvarchar(max) NOT NULL,	
	[Flagged Column Name] nvarchar(max) NULL,
	[Flagged Column Value] nvarchar(max) null,
	[Remarks] nvarchar(max) NULL,
	[SKU State] nvarchar(max) NULL,	
	[SAP Rate Start Date] datetime NULL,
	[Cayman Release] nvarchar(max) NULL,	
	[Meter Status] nvarchar(max) NULL	
	
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
		INSERT into @rtnTable
		SELECT
		[Event ID] = e.[ID],
		[Work Item Type] = 'Meter',
	[Work Item ID] = m.[MeterID],

	[Validation Name] = 'Dev/Test items should have a Dev/Test discount',	
	[Flagged Column Name] = CASE 
							WHEN (m.[DevTest Discount Rate] >= m.[Direct Rate])  THEN 'DevTest Discount Rate' 
							WHEN (ISNULL(m.[DevTest Discount Percentage],'') ='' OR (m.[DevTest Discount Percentage] = 0)) THEN 'DevTest Discount Percentage' END,
	[Flagged Column Value] = CASE 
							WHEN (m.[DevTest Discount Rate] >= m.[Direct Rate])  THEN CAST(m.[DevTest Discount Rate] AS NVARCHAR(MAX)) 
							WHEN (ISNULL(m.[DevTest Discount Percentage],'') ='' OR (m.[DevTest Discount Percentage] = 0)) THEN CAST(m.[DevTest Discount Percentage] AS NVARCHAR(MAX)) END,
	[Remarks] = CASE 
							WHEN (m.[DevTest Discount Rate] > m.[Direct Rate])  
							THEN 'Meter DevTest Discount Rate of '+CAST(m.[DevTest Discount Rate] AS NVARCHAR(MAX))+' is higher than the Meter Direct Rate of '+ CAST(m.[Direct Rate] AS NVARCHAR(MAX))
							WHEN (ISNULL(m.[DevTest Discount Percentage],'') ='' OR (m.[DevTest Discount Percentage] = 0) OR (m.[DevTest Discount Rate] = m.[Direct Rate])) 
							THEN 'Meter DevTest Discount Pecentage is zero or empty' END  ,
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
		
	
FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]
where 
		
		m.[Has DevTest Sku] = 'Yes'
and		( 
(m.[DevTest Discount Rate] > m.[Direct Rate])
OR
(ISNULL(m.[DevTest Discount Percentage],'') ='' OR (m.[DevTest Discount Percentage] = 0)) -- fOR BLANK OR EMPTY DISCOUNT PERCENTAGE
OR 
( m.[DevTest Discount Rate]  = m.[Direct Rate])
)
and     e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight

RETURN 
END
GO
