-- =============================================================================
-- Starting money for new characters.
-- SP_Users_Active (creates the game account on first entry) takes @Gold/@Money,
-- which Tank.Request passes from its DefaultGold/DefaultMoney settings
-- (STARTING_GOLD / STARTING_MONEY in server.env), but inserted 0,0 instead.
-- Patch the stored definition in place; does nothing once applied.
-- =============================================================================
USE [Project_Player34];
GO
DECLARE @def nvarchar(max) = OBJECT_DEFINITION(OBJECT_ID(N'dbo.SP_Users_Active'));
DECLARE @old nvarchar(100) = N'@GP,'''',0,0,@Style';
DECLARE @new nvarchar(100) = N'@GP,'''',@Gold,@Money,@Style';
IF CHARINDEX(@old, @def) > 0
BEGIN
    SET @def = REPLACE(@def, @old, @new);
    SET @def = STUFF(@def, CHARINDEX(N'CREATE Procedure', @def), LEN(N'CREATE'), N'ALTER');
    EXEC (@def);
END
GO
