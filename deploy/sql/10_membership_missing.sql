-- =============================================================================
-- Db_Membership: stored procedures called by Bussiness/MemberShipBussiness.cs
-- (AppSetting "membershipDb") that are missing from the restored database.
-- Idempotent: safe to re-run.
-- =============================================================================
USE [Db_Membership];
GO

-- -----------------------------------------------------------------------------
-- Check_User  (MemberShipBussiness.CheckUsername <- Tank.Flash/checkuser.ashx)
--   @UserName, @password IN ; @UserId OUTPUT (>0 on success, 0 otherwise)
-- Accepted password forms:
--   * direct match (case-insensitive) - legacy rows store UPPER(MD5(plain)) and
--     the browser sends lower(MD5(plain)), so this branch covers them;
--   * UPPER(MD5(@password)) - auth/register.ashx stores
--     HashPasswordForStoringInConfigFile(<browser md5 string>, "md5").
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[Check_User]
    @UserName nvarchar(256),
    @password nvarchar(256),
    @UserId   int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @UserId = 0;

    IF @UserName IS NULL OR @password IS NULL OR LEN(@password) = 0
        RETURN 0;

    DECLARE @hashed nvarchar(128) =
        CONVERT(varchar(32), HASHBYTES('MD5', CONVERT(varchar(256), @password)), 2);

    SELECT TOP (1) @UserId = ISNULL(TRY_CAST(u.UserId AS int), 0)
    FROM dbo.Mem_Users u
    INNER JOIN dbo.Mem_UserInfo i ON i.UserId = u.UserId
    WHERE u.UserName = @UserName
      AND ISNULL(i.IsLockedOut, 0) = 0
      AND (i.[Password] = @password OR i.[Password] = @hashed)
    ORDER BY u.ApplicationId;

    SET @UserId = ISNULL(@UserId, 0);

    IF @UserId > 0
    BEGIN
        UPDATE dbo.Mem_Users    SET LastActivityDate = GETDATE() WHERE UserId = CAST(@UserId AS nvarchar(256));
        UPDATE dbo.Mem_UserInfo SET LastLoginDate    = GETDATE() WHERE UserId = CAST(@UserId AS nvarchar(256));
    END
    RETURN 0;
END
GO

-- -----------------------------------------------------------------------------
-- Mem_UserInfo_Addmin  (MemberShipBussiness.CheckAdmin <- Tank.Flash/checkuser.ashx)
--   @UserName IN ; @UserCOUNT OUTPUT (>0 => user is a game admin)
-- A user is considered admin when any of these is true:
--   * an account with that name exists in the "GameAdmin" application;
--   * the user's id is assigned a role in Mem_UsersInRoles;
--   * the user's id has rights in Mem_UserRight for the GameAdmin application.
-- -----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[Mem_UserInfo_Addmin]
    @UserName  nvarchar(256),
    @UserCOUNT int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @UserCOUNT = 0;

    DECLARE @AdminAppId nvarchar(20);
    SELECT TOP (1) @AdminAppId = ApplicationId
    FROM dbo.Mem_Application
    WHERE LowerApplicationName = N'gameadmin';

    DECLARE @ids TABLE (UserId nvarchar(256) PRIMARY KEY);
    INSERT INTO @ids (UserId)
    SELECT DISTINCT UserId FROM dbo.Mem_Users WHERE UserName = @UserName;

    SELECT @UserCOUNT =
          (SELECT COUNT(*) FROM dbo.Mem_Users
            WHERE UserName = @UserName AND @AdminAppId IS NOT NULL AND ApplicationId = @AdminAppId)
        + (SELECT COUNT(*) FROM dbo.Mem_UsersInRoles r
            WHERE r.UserID IN (SELECT TRY_CAST(UserId AS int) FROM @ids))
        + (SELECT COUNT(*) FROM dbo.Mem_UserRight ur
            WHERE ur.UserID COLLATE DATABASE_DEFAULT IN (SELECT UserId COLLATE DATABASE_DEFAULT FROM @ids)
              AND (ur.ApplicationId = @AdminAppId OR ur.ApplicationId = N'GameAdmin'));

    SET @UserCOUNT = ISNULL(@UserCOUNT, 0);
    RETURN 0;
END
GO
