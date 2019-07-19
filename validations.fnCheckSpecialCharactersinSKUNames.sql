-- ================================================
-- Template generated from Template Explorer using:
-- Create Inline Function (New Menu).SQL
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
-- Create date: 18 July 2019
-- Description:	Checks name fields for the existence of special characters
--				https://dev.azure.com/AzureReleaseOperation/Release%20Implementation/_workitems/edit/99
-- =============================================
ALTER FUNCTION [validations].[fnCheckSpecialCharactersinSKUNames] 
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
	INSERT INTO @rtnTable
SELECT 
[Event ID] = e.[ID],
[Work Item Type] = 'Consumption SKU',
	[Work Item ID] = s.[ConsumptionSkuID],	
	[Validation Name] = 'The SKUs Naming fields should not have  special characters',	
	[Flagged Column Name] = Case
							WHEN s.[Product Family]  LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' THEN 'Product Family' 
							WHEN s.[Service Name] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' THEN 'Service Name'
							WHEN s.[Service Type] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' THEN 'Service Type'
							WHEN s.[Resource Name] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' THEN 'Resource Name'
							WHEN s.[Region Name] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' THEN 'Region Name'
							WHEN s.[EA Unit of Measure] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' THEN 'EA Unit of Measure'
							WHEN s.[EA Portal Friendly Name] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' THEN 'EA Portal Friendly Name'
							WHEN s.[Material Description]LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' THEN 'Material Description'
							END,
	[Flagged Column Value] = Case
							WHEN s.[Product Family]  LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' THEN s.[Product Family]
							WHEN s.[Service Name] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' THEN s.[Service Name]
							WHEN s.[Service Type] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' THEN s.[Service Type]
							WHEN s.[Resource Name] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' THEN s.[Resource Name]
							WHEN s.[Region Name] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' THEN s.[Region Name]
							WHEN s.[EA Unit of Measure] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' THEN s.[EA Unit of Measure]
							WHEN s.[EA Portal Friendly Name] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' THEN s.[EA Portal Friendly Name]
							WHEN s.[Material Description] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' THEN s.[Material Description]
							END,
	[Remarks] = 'The SKUs region name is not valid',
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
	FROM 
		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]
where 
 e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight
AND (
	s.[Product Family]  LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' OR
	s.[Service Name] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' OR
	s.[Service Type] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' OR
	s.[Resource Name] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' OR
	s.[Region Name] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' OR
	s.[EA Unit of Measure] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' OR
	s.[EA Portal Friendly Name] LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' OR
	s.[Material Description]LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' 

)

RETURN 
END