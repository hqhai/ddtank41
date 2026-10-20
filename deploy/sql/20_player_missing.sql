-- =============================================================================
-- Project_Player34 (AppSetting "conString"): objects used by
-- Bussiness/PlayerBussiness.cs (BaseBussiness) that are missing.
-- Idempotent: safe to re-run.
-- =============================================================================
USE [Project_Player34];
GO

-- -----------------------------------------------------------------------------
-- SYNONYM Shop_Goods -> Project_Game34.dbo.Shop_Goods
-- Existing procs in this DB reference an unqualified Shop_Goods:
--   SP_Admin_SendUserItem, SP_Admin_SendAllItem(_UserID/_UserName/_MultiSupport),
--   SP_Items_All, SP_Items_Single, SP_Items_Category_Single.
-- -----------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.Shop_Goods') IS NULL
    CREATE SYNONYM [dbo].[Shop_Goods] FOR [Project_Game34].[dbo].[Shop_Goods];
GO

-- -----------------------------------------------------------------------------
-- SP_Account_Register  (PlayerBussiness.RegisterUser <- Tank.Request/AccountRegister.ashx)
--   RETURN 0 = created, 1 = user name already exists, other = error.
-- Creates the game account the same way SP_Users_Active does, then credits
-- Money/GiftToken/Gold. NickName is intentionally left empty (IsFirst = 0) so
-- the normal first-login character creation (SP_Users_RegisterNotValidate)
-- still runs and its nickname-uniqueness check does not collide with this row.
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[SP_Account_Register]
    @UserName  nvarchar(200),
    @Password  nvarchar(200),
    @NickName  nvarchar(50) = NULL,
    @Sex       bit = 0,
    @Money     int = 0,
    @GiftToken int = 0,
    @Gold      int = 0
AS
BEGIN
    SET NOCOUNT ON;
    IF @UserName IS NULL OR LEN(@UserName) = 0
        RETURN 2;
    IF EXISTS (SELECT 1 FROM dbo.Sys_Users_Detail WHERE UserName = @UserName)
        RETURN 1;

    DECLARE @UserID int, @rc int;
    EXEC @rc = dbo.SP_Users_Active
        @UserID = @UserID OUTPUT,
        @Attack = 0, @Colors = N',,,,,,', @ConsortiaID = 0, @Defence = 0,
        @Gold = 0, @GP = 1, @Grade = 1, @Luck = 0, @Money = 0,
        @Style = N',,,,,,', @Agility = 0, @State = 0,
        @UserName = @UserName, @PassWord = @Password, @Sex = @Sex,
        @Hide = 1111111111, @ActiveIP = N'', @Skin = N'', @Site = N'';
    IF ISNULL(@rc, 1) <> 0 OR ISNULL(@UserID, 0) = 0
        RETURN ISNULL(NULLIF(@rc, 0), 3);

    UPDATE dbo.Sys_Users_Detail
       SET [Money]   = ISNULL(@Money, 0),
           GiftToken = ISNULL(@GiftToken, 0),
           Gold      = ISNULL(@Gold, 0)
     WHERE UserID = @UserID;
    RETURN 0;
END
GO

-- -----------------------------------------------------------------------------
-- SP_Active_Add  (PlayerBussiness.AddActive <- ActiveMgr.UpdateCurrentServerActive,
-- triggered by the Center "reload active" command right after SP_Active_Delete
-- truncates Project_Game34.dbo.Active / Active_Award). Re-inserts one activity.
-- All parameters default to NULL because C# sends a null EndDate/strings as
-- "parameter omitted".
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[SP_Active_Add]
    @ActiveID           int,
    @Description        nvarchar(2000) = NULL,
    @Content            nvarchar(2000) = NULL,
    @AwardContent       nvarchar(2000) = NULL,
    @HasKey             int = 0,
    @EndDate            datetime = NULL,
    @IsOnly             int = 0,
    @StartDate          datetime = NULL,
    @Title              nvarchar(200) = NULL,
    @Type               int = 0,
    @ActiveType         int = 0,
    @ActionTimeContent  nvarchar(50) = NULL,
    @IsAdvance          bit = 0,
    @GoodsExchangeTypes nvarchar(50) = NULL,
    @GoodsExchangeNum   nvarchar(50) = NULL,
    @limitType          nvarchar(50) = NULL,
    @limitValue         nvarchar(50) = NULL,
    @IsShow             bit = 0,
    @IconID             int = 0
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM [Project_Game34].[dbo].[Active] WHERE ActiveID = @ActiveID;
    INSERT INTO [Project_Game34].[dbo].[Active]
        (ActiveID, Title, [Description], Content, AwardContent, HasKey, StartDate, EndDate,
         IsOnly, [Type], ActionTimeContent, IsAdvance, GoodsExchangeTypes, GoodsExchangeNum,
         limitType, limitValue, IsShow, ActiveType, IconID)
    VALUES
        (@ActiveID, ISNULL(@Title, N''), @Description, @Content, @AwardContent, ISNULL(@HasKey, 0),
         ISNULL(@StartDate, GETDATE()), @EndDate, ISNULL(@IsOnly, 0), ISNULL(@Type, 0),
         @ActionTimeContent, ISNULL(@IsAdvance, 0), @GoodsExchangeTypes, @GoodsExchangeNum,
         @limitType, @limitValue, ISNULL(@IsShow, 0), ISNULL(@ActiveType, 0), ISNULL(@IconID, 0));
    RETURN 0;
END
GO

-- -----------------------------------------------------------------------------
-- SP_Active_Award  (PlayerBussiness.AddActiveAward, same reload path as above)
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[SP_Active_Award]
    @ActiveID        int,
    @ItemID          int,
    @Count           int = 1,
    @ValidDate       int = 0,
    @StrengthenLevel int = 0,
    @AttackCompose   int = 0,
    @DefendCompose   int = 0,
    @LuckCompose     int = 0,
    @AgilityCompose  int = 0,
    @Gold            int = 0,
    @Money           int = 0,
    @Sex             int = 0,
    @Mark            int = 0
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [Project_Game34].[dbo].[Active_Award]
        (ActiveID, ItemID, [Count], ValidDate, StrengthenLevel, AttackCompose, DefendCompose,
         LuckCompose, AgilityCompose, Gold, [Money], Sex, Mark)
    VALUES
        (@ActiveID, @ItemID, ISNULL(@Count, 1), ISNULL(@ValidDate, 0), ISNULL(@StrengthenLevel, 0),
         ISNULL(@AttackCompose, 0), ISNULL(@DefendCompose, 0), ISNULL(@LuckCompose, 0),
         ISNULL(@AgilityCompose, 0), ISNULL(@Gold, 0), ISNULL(@Money, 0), ISNULL(@Sex, 0), ISNULL(@Mark, 0));
    RETURN 0;
END
GO
