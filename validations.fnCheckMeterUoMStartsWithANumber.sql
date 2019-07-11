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
-- Create date: 10 June 2019
-- Description:	Checks whether the Unit of Measure (UoM) field value starts with a number
--				Select *** where ISNUMERIC (Left(EUoM,1)) = 0 UNION
--				Select *** where ISNUMERIC (Left(Direct UoM,1)) = 0 
--				Checks to be added at Meter Level i.e. m.[Direct Unit of Measure]

-- =============================================
CREATE FUNCTION [validations].[fnCheckMeterUoMStartsWithANumber]
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
		[Work Item Type] = 'Meter',
	[Work Item ID] = m.[MeterID],
		[Validation Name] = 'Meter Direct UoM field and EA UoM field should start with a number',	
	[Flagged Column Name] = CASE WHEN ( ISNUMERIC(SUBSTRING(LTRIM(m.[Direct Unit of Measure]), 1, 1))) <> 1 
							THEN 'Direct Unit of Measure'
							ELSE 'EA Unit of Measure' END,
	[Flagged Column Value] = CASE WHEN ( ISNUMERIC(SUBSTRING(LTRIM(m.[Direct Unit of Measure]), 1, 1))) <> 1 
							 THEN CAST(m.[Direct Unit of Measure] AS NVARCHAR(MAX)) 
							 ELSE CAST(m.[EA Unit of Measure] AS NVARCHAR(MAX)) END,
	[Remarks] = CASE WHEN ( ISNUMERIC(SUBSTRING(LTRIM(m.[Direct Unit of Measure]), 1, 1))) <> 1 
				THEN'The meters Direct UoM should begin with a numeral'
				ELSE 'The meters EA UoM should begin with a numeral' END,
	[SKU State] = s.[State],	
	[SAP Rate Start Date] = e.[SAP Rate Start Date],
	[Cayman Release] = e.[Cayman Release],
	[Meter Status]  = m.[Meter Status]
		
FROM 

		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeterHist] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]


where 
		( ISNUMERIC(SUBSTRING(LTRIM(m.[Direct Unit of Measure]), 1, 1)) <> 1
		 OR ISNUMERIC(SUBSTRING(LTRIM(m.[EA Unit of Measure]), 1, 1)) <> 1)
	    AND e.[State] in ('Submitted', 'Reviewed', 'Approved', 'In Progress', 'On Hold') -- for things in flight
RETURN 
END
GO