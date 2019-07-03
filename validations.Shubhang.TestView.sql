USE [dbASOMS_Validation]
GO

/****** Object:  View [validations].[vwMainReleaseFacts]    Script Date: 6/14/2019 2:12:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [validations].[shubhangTest] AS
select * from validations.fnMaterialDescriptionShouldBeginWithAZ() UNION
select * from validations.fnCheckPreviewEAPortalFriendlyName() UNION
select * from validations.fnNonGLLinkedCNMetersDevTest() UNION
select * from validations.fnCheckMeterUoMStartsWithANumber() UNION
select * from validations.fnCheckDiscontinueDatesBeforePLDate() UNION
select * from validations.fnCheckRevenueSKUOfMeterIsNotNull() UNION
select * from validations.fnCheckNoChangeUoMAndRatesMeters() UNION
select * from validations.fnCheckNoChangeUoMAndRatesSKU() UNION
select * from validations.fnCheckMatDesAndEAPortalFriendlyNameStringInSkuSubType() UNION
select * from validations.fnCheckSKUAndPartNumber() UNION
select * from validations.fnCheckNewSKUShouldNotHaveDiscontinueDate() UNION
select distinct * from validations.fnCheckEventForScopeAndRateStartDate();

GO