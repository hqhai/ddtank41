-- =============================================================================
-- Project_Game34 (AppSetting "crosszoneString"): objects used by
-- Bussiness/ProduceBussiness.cs (BaseCrossBussiness) that are missing here.
-- Idempotent: safe to re-run.
-- =============================================================================
USE [Project_Game34];
GO

-- -----------------------------------------------------------------------------
-- SP_Daily_League_Award_All  (ProduceBussiness.GetAllDailyLeagueAward
--   <- Tank.Request/DailyLeagueAwardList.ashx, DailyLeagueAwardMgr)
-- Columns read by ProduceBussiness.InitDailyLeagueAwardInfo. Built from
-- DailyLeagueAwardItems (rewards per Class) + DailyLeagueAwardList (Grade per Class).
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[SP_Daily_League_Award_All]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        CAST(ISNULL(l.Grade, 0) AS int)       AS [Level],
        CAST(ISNULL(i.Class, 0) AS int)       AS [Class],
        CAST(ISNULL(i.[Count], 1) AS int)     AS [Count],
        CAST(ISNULL(i.TemplateID, 0) AS int)  AS TemplateID,
        CAST(i.ID AS int)                     AS RewardID,
        CAST(ISNULL(i.StrengthLevel, 0) AS int)  AS StrengthenLevel,
        CAST(ISNULL(i.ValidDate, 0) AS int)      AS ItemValid,
        CAST(ISNULL(i.IsBind, 0) AS bit)         AS IsBind,
        CAST(ISNULL(i.AgilityCompose, 0) AS int) AS AgilityCompose,
        CAST(ISNULL(i.AttackCompose, 0) AS int)  AS AttackCompose,
        CAST(ISNULL(i.DefendCompose, 0) AS int)  AS DefendCompose,
        CAST(ISNULL(i.LuckCompose, 0) AS int)    AS LuckCompose,
        0 AS Hole1, 0 AS Hole2, 0 AS Hole3, 0 AS Hole4,
        0 AS Hole5, 0 AS Hole5Exp, 0 AS Hole5Level,
        0 AS Hole6, 0 AS Hole6Exp, 0 AS Hole6Level
    FROM dbo.DailyLeagueAwardItems i
    OUTER APPLY (SELECT TOP (1) Grade FROM dbo.DailyLeagueAwardList l
                 WHERE l.Class = i.Class ORDER BY l.Grade) l
    ORDER BY i.Class, i.ID;
END
GO

-- -----------------------------------------------------------------------------
-- SP_Suit_Manager_Update / SP_Suit_Manager_Reset
-- ProduceBussiness.Update_Suit_Kill / Reset_Suit_Kill (PlayerEquipInventory, on
-- equip/property recalculation) call these on the crosszone (Game) connection,
-- but they and table Suit_Manager only exist in Project_Player34.
-- Forward to the Player DB implementation.
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[SP_Suit_Manager_Update]
    @kill   nvarchar(200),
    @UserID int
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [Project_Player34].[dbo].[SP_Suit_Manager_Update] @kill = @kill, @UserID = @UserID;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_Suit_Manager_Reset]
    @UserID int
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [Project_Player34].[dbo].[SP_Suit_Manager_Reset] @UserID = @UserID;
END
GO

-- -----------------------------------------------------------------------------
-- Item_Refinery.Equip4: ProduceBussiness.GetAllRefineryInfo (RefineryMgr.Init at
-- Road start) reads reader["Equip4"] from "select * from Item_Refinery"; the
-- column is missing, so every row would throw. Add it (default 0).
-- -----------------------------------------------------------------------------
IF COL_LENGTH(N'dbo.Item_Refinery', N'Equip4') IS NULL
    ALTER TABLE dbo.Item_Refinery ADD Equip4 int NOT NULL
        CONSTRAINT DF_Item_Refinery_Equip4 DEFAULT (0);
GO
