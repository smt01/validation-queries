USE [dbASOMS_Validation]
GO

/****** Object:  View [validations].[vwMainReleaseFacts]    Script Date: 6/14/2019 2:12:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [validations].[vwCheckScopeAndReleaseDateForEvents] AS
select distinct * from (select * from [dbASOMS_Validation].[validations].[fnCheckEventForScopeAndRateStartDate]()) as tempTable

GO