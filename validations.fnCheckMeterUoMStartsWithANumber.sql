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
	[Test ID] nvarchar(max) NOT NULL,
	[Result ID] INT	NOT NULL,
	[Flagged Column Name] nvarchar(max) NULL,
	[Direct Unit of Measure] nvarchar(max) not null,
	[EA Unit of Measure] nvarchar(max) not null,
	[State] nvarchar(max) NULL,
	[Meter ID] INT NULL,
	[Event ID] INT NULL,
	[SAP Rate Start Date] datetime NULL,
	[Cayman Release] nvarchar(max) NULL,	
	[Meter Status] nvarchar(max) NULL
	
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
		INSERT INTO @rtnTable
		SELECT
		[Test ID] = 'Meter Direct UoM field and EA UoM field should start with a number',
		[Result ID] = 1,
		[Flagged Column Name] = CASE WHEN ( ISNUMERIC(SUBSTRING(LTRIM(m.[Direct Unit of Measure]), 1, 1))) <> 1  THEN 'Direct Unit of Measure' ELSE 'EA Unit of Measure' END,
		[Direct Unit of Measure] = m.[Direct Unit of Measure],
		[EA Unit of Measure] = m.[EA Unit of Measure],
		[State] = s.[State],
		[Meter ID] = m.[MeterID],
		[Event ID] = e.[ID],
		[SAP Rate Start Date] = e.[SAP Rate Start Date],
		[Cayman Release] = e.[Cayman Release],
		[Meter Status]  = m.[Meter Status]
	
FROM 

		[dbASOMS_Production].[Prod].[vwASOMSEvent] e (NOLOCK) 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSMeter] m (NOLOCK)				ON m.[Parent id] = e.[ID] 
		JOIN [dbASOMS_Production].[Prod].[vwASOMSConsumptionSKUHist] s (NOLOCK)		ON s.[Parent ID] = m.[MeterID]


where 
		 ISNUMERIC(SUBSTRING(LTRIM(m.[Direct Unit of Measure]), 1, 1)) <> 1
		 OR ISNUMERIC(SUBSTRING(LTRIM(m.[EA Unit of Measure]), 1, 1)) <> 1
	
RETURN 
END
GO