-- =============================================================================
-- Stored-procedure parameter sync: C# (Bussiness/*.cs) vs procs in the DB.
-- Found by a static checker comparing the SqlParameter names each call passes
-- with the procedure headers. Two kinds of runtime failure are fixed here:
--   (a) proc requires a parameter that C# does not send (also: SqlParameter
--       created with SqlDbType only, Value == null, which SqlClient omits)
--       -> "Procedure ... expects parameter '@X', which was not supplied."
--       Fix: give the parameter a default; for UPDATEs default NULL and
--       Col = ISNULL(@X, Col), so an omitted value keeps the stored data.
--   (b) C# passes a parameter the proc does not declare
--       -> "@X is not a parameter for procedure ...".
--       Fix: declare it as an optional, ignored parameter (= NULL).
-- Each proc is the original OBJECT_DEFINITION with only the marked changes.
-- Idempotent: safe to re-run (CREATE OR ALTER).
-- =============================================================================
USE [Project_Player34];
GO
-- keep the original procs' settings (sqlcmd defaults to QUOTED_IDENTIFIER OFF)
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- -----------------------------------------------------------------------------
-- SP_Users_Update
--   PlayerBussiness.UpdatePlayer (the periodic / logout player save) does not pass
--   @GhostEquipList, @fineSuitExp -> "expects parameter ... not supplied", the
--   player row was never saved. Both now default to NULL and the UPDATEs keep
--   the stored value when NULL (ISNULL(@p, Col)).
-- -----------------------------------------------------------------------------
-- =============================================
-- Author:		<Ken>
-- ALTER  date: <2009-10-22>
-- Description:	<用户信息：用户信息更新，从内存中更新到DB中，采用定时或离开时操作>
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[SP_Users_Update]
@UserID int,
@Attack int,
@Defence int,
@Luck int,
@Agility int,
@Gold int,
@Money int,
@Style Nvarchar(200),
@Colors Nvarchar(200),
@Hide int,
@Grade int,
@GP int,
@State int,
@ConsortiaID int,
@ExpendDate datetime,
@Win int,
@Total int,
@Escape int,
@Skin Nvarchar(50),
@Offer int,
@AntiAddiction int output,
@RichesOffer int,
@RichesRob int,
@CheckCount int output,
@MarryInfoID int,
@DayLoginCount int,
@Nimbus int,
@LastAward datetime,
@GiftToken int,
@QuestSite  varbinary(200),
@PvePermission nvarchar(50),
@FightPower int,
@AnswerSite int,
@LastAuncherAward datetime,
@hp int,
	@ChatCount int ,
	@SpaPubGoldRoomLimit int ,
	@LastSpaDate DateTime ,
    @FightLabPermission nvarchar(50) ,
    @SpaPubMoneyRoomLimit int ,
    @IsInSpaPubGoldToday bit ,
    @IsInSpaPubMoneyToday bit ,
	@AchievementPoint int ,			
    @LastWeekly datetime ,           
    @LastWeeklyVersion int , 
    @WeaklessGuildProgressStr nvarchar(1000),
    @IsOldPlayer bit,
    @VIPLevel int,
    @VIPExp int,
    @Score int,
	   @OptionOnOff int
      ,@isOldPlayerHasValidEquitAtLogin bit
      ,@badLuckNumber int
      ,@luckyNum int
      ,@lastLuckyNumDate datetime
      ,@lastLuckNum int
      ,@IsShowConsortia bit
      ,@NewDay datetime
      ,@Medal int
      ,@Honor nvarchar(50)
	  ,@VIPNextLevelDaysNeeded int
	  ,@IsRecharged bit
	  ,@IsGetAward bit
	  ,@typeVIP int
	  ,@evolutionGrade int
	  ,@evolutionExp int
	  ,@hardCurrency int
	  ,@EliteScore int
	  ,@UseOffer int
	  ,@ShopFinallyGottenTime datetime
	  ,@MoneyLock int
	  ,@LastGetEgg datetime
	  ,@IsFistGetPet bit
	  ,@LastRefreshPet datetime
	  ,@petScore int
	  ,@accumulativeLoginDays int
      ,@accumulativeAwardDays int
	  ,@honorId int
	  ,@Repute int
	  ,@damageScores int
	  ,@totemId int
	  ,@myHonor int
	  ,@MaxBuyHonor int
	  ,@necklaceExp int
	  ,@necklaceExpAdd int
	  ,@GhostEquipList nvarchar(max) = NULL
	  ,@fineSuitExp int = NULL
as

declare @IsExist bit
declare @ForbidDate datetime
declare @OrdState int
declare @AntiDate datetime
declare @OnlineTime int
set @OnlineTime =0
select @OrdState=State,@AntiDate=AntiDate,@AntiAddiction=AntiAddiction,@ForbidDate=ForbidDate,@IsExist=IsExist from Sys_Users_Detail where UserID=@UserID

if DAY(@AntiDate)<>DAY(getdate())
begin
	set @AntiDate=getdate()
	set @AntiAddiction=0
	set @CheckCount=0
end
else
begin
	if @OrdState<>0 
	begin
	set @OnlineTime = isnull(datediff(mi,@AntiDate,Getdate()),0)
	set @AntiAddiction =@AntiAddiction + @OnlineTime
	           end
	set @AntiDate=getdate()
end

set xact_abort on
begin tran

if @ExpendDate = ''
begin 
	
 		 update Sys_Users_Detail set Gold = @Gold,Money = @Money,Style=@Style,Colors=@Colors,Grade=@Grade,GP=@GP,State=@State,
		AntiDate=@AntiDate,OnlineTime = OnlineTime + @OnlineTime,RichesOffer=@RichesOffer,RichesRob=@RichesRob,ForbidDate=@ForbidDate,IsExist=@IsExist,
		Hide=@Hide,Win=@Win,Total=@Total,[Escape]=@Escape,Skin=@Skin,Offer=@Offer,AntiAddiction = @AntiAddiction,CheckCount=@CheckCount,MarryInfoID=@MarryInfoID,
		DayLoginCount=@DayLoginCount ,Nimbus=@Nimbus,LastAward=@LastAward,GiftToken=@GiftToken,QuestSite=@QuestSite,PvePermission=@PvePermission,FightPower=@FightPower,
		AnswerSite=@AnswerSite,LastAuncherAward=@LastAuncherAward,
		Medal = @Medal ,
		ChatCount =	@ChatCount ,
		SpaPubGoldRoomLimit = @SpaPubGoldRoomLimit ,
		LastSpaDate  = @LastSpaDate  ,
		FightLabPermission = @FightLabPermission  ,
		SpaPubMoneyRoomLimit = @SpaPubMoneyRoomLimit ,
		IsInSpaPubGoldToday = @IsInSpaPubGoldToday  ,
		IsInSpaPubMoneyToday = @IsInSpaPubMoneyToday ,
		AchievementPoint = @AchievementPoint ,			
		LastWeekly = @LastWeekly,           
		LastWeeklyVersion = @LastWeeklyVersion ,  
		WeaklessGuildProgressStr = @WeaklessGuildProgressStr,
		IsOldPlayer = @IsOldPlayer,
		[Score] = @Score,
		[OptionOnOff] = @OptionOnOff
      ,[isOldPlayerHasValidEquitAtLogin] = @isOldPlayerHasValidEquitAtLogin
      ,[badLuckNumber] = @badLuckNumber
      ,[luckyNum] = @luckyNum
      ,[lastLuckyNumDate] = @lastLuckyNumDate
      ,[lastLuckNum] = @lastLuckNum
      ,[IsShowConsortia] = @IsShowConsortia
      ,[NewDay]=@NewDay
      ,[Honor] =@Honor
	  ,IsRecharged = @IsRecharged
	  ,IsGetAward = @IsGetAward
	  ,evolutionGrade = @evolutionGrade
	  ,evolutionExp = @evolutionExp
	  ,hardCurrency = @hardCurrency
	  ,EliteScore = @EliteScore
	  ,UseOffer = @UseOffer
	  ,ShopFinallyGottenTime = @ShopFinallyGottenTime
	  ,MoneyLock = @MoneyLock
	  ,LastGetEgg = @LastGetEgg
	  ,IsFistGetPet = @IsFistGetPet
	  ,LastRefreshPet =@LastRefreshPet
	  ,petScore = @petScore
      ,[accumulativeLoginDays] = @accumulativeLoginDays
      ,[accumulativeAwardDays] = @accumulativeAwardDays
	  ,honorId = @honorId  
	  ,Repute = @Repute
	  ,damageScores = @damageScores
	  ,totemId= @totemId
	  ,myHonor = @myHonor
	  ,MaxBuyHonor = @MaxBuyHonor
	  ,necklaceExp = @necklaceExp
	  ,necklaceExpAdd = @necklaceExpAdd
	  ,GhostEquipList = ISNULL(@GhostEquipList, GhostEquipList)
	  ,fineSuitExp = ISNULL(@fineSuitExp, fineSuitExp)
		where UserID = @UserID
end
else
begin
  		update Sys_Users_Detail set Gold = @Gold,Money = @Money,Style=@Style,Colors=@Colors,Grade=@Grade,GP=@GP,State=@State,
		AntiDate=@AntiDate,OnlineTime = OnlineTime + @OnlineTime,RichesOffer=@RichesOffer,RichesRob=@RichesRob,ForbidDate=@ForbidDate,IsExist=@IsExist,
		Hide=@Hide,ExpendDate=@ExpendDate,Win=@Win,Total=@Total,[Escape]=@Escape,Skin=@Skin,Offer=@Offer,AntiAddiction = @AntiAddiction,CheckCount=@CheckCount,MarryInfoID=@MarryInfoID,
        DayLoginCount=@DayLoginCount ,Nimbus=@Nimbus,LastAward=@LastAward,GiftToken=@GiftToken,QuestSite=@QuestSite,PvePermission=@PvePermission,FightPower=@FightPower,
        AnswerSite=@AnswerSite,LastAuncherAward=@LastAuncherAward,
        Medal = @Medal ,
		ChatCount =	@ChatCount ,
		SpaPubGoldRoomLimit = @SpaPubGoldRoomLimit ,
		LastSpaDate  = @LastSpaDate  ,
		FightLabPermission = @FightLabPermission  ,
		SpaPubMoneyRoomLimit = @SpaPubMoneyRoomLimit ,
		IsInSpaPubGoldToday = @IsInSpaPubGoldToday  ,
		IsInSpaPubMoneyToday = @IsInSpaPubMoneyToday ,
		AchievementPoint = @AchievementPoint ,			
		LastWeekly = @LastWeekly,           
		LastWeeklyVersion = @LastWeeklyVersion ,  
		WeaklessGuildProgressStr = @WeaklessGuildProgressStr,
		IsOldPlayer = @IsOldPlayer,
		[Score] = @Score,
		[OptionOnOff] = @OptionOnOff
      ,[isOldPlayerHasValidEquitAtLogin] = @isOldPlayerHasValidEquitAtLogin
      ,[badLuckNumber] = @badLuckNumber
      ,[luckyNum] = @luckyNum
      ,[lastLuckyNumDate] = @lastLuckyNumDate
      ,[lastLuckNum] = @lastLuckNum
      ,[IsShowConsortia] = @IsShowConsortia
      ,[NewDay]=@NewDay
      ,[Honor] =@Honor
	   ,IsRecharged = @IsRecharged
	  ,IsGetAward = @IsGetAward
	  ,evolutionGrade = @evolutionGrade
	  ,evolutionExp = @evolutionExp
	  ,hardCurrency = @hardCurrency
	  ,EliteScore = @EliteScore
	  ,UseOffer = @UseOffer
	  ,ShopFinallyGottenTime = @ShopFinallyGottenTime
	  ,MoneyLock = @MoneyLock
	  ,LastGetEgg = @LastGetEgg
	  ,IsFistGetPet = @IsFistGetPet
	  ,LastRefreshPet =@LastRefreshPet
	  ,petScore = @petScore
      ,[accumulativeLoginDays] = @accumulativeLoginDays
      ,[accumulativeAwardDays] = @accumulativeAwardDays
	  ,honorId = @honorId  
	  ,Repute = @Repute
	  ,damageScores = @damageScores
	  ,totemId= @totemId
	  ,myHonor = @myHonor
	  ,MaxBuyHonor = @MaxBuyHonor
	  ,necklaceExp = @necklaceExp
	  ,necklaceExpAdd = @necklaceExpAdd
	  ,GhostEquipList = ISNULL(@GhostEquipList, GhostEquipList)
	  ,fineSuitExp = ISNULL(@fineSuitExp, fineSuitExp)
        where UserID = @UserID
end

if @@error <> 0
begin
  rollback tran
  return @@error
end

update Sys_Users_Fight set Attack=@Attack,Defence=@Defence,Luck=@Luck,Agility=@Agility,hp=@hp where UserID = @UserID
if @@error <> 0
begin 
  rollback tran
  return @@error
end
--/*
update Sys_VIP_Info set VIPLevel=@VIPLevel, VIPExp=@VIPExp, VIPNextLevelDaysNeeded=@VIPNextLevelDaysNeeded, typeVIP = @typeVIP where UserID = @UserID
if @@error <> 0
begin 
  rollback tran
  return @@error
end
--*/
update Sys_Users_Extra set TotalCaddyOpen = @badLuckNumber where UserID = @UserID
if @@error <> 0
begin 
  rollback tran
  return @@error
end
--*/
commit tran
set xact_abort off
return 0
GO

-- -----------------------------------------------------------------------------
-- SP_Users_Items_Update
--   PlayerBussiness.UpdateGoods (every item save) does not pass @curExp,
--   @cellLocked. Default NULL; the UPDATE keeps the stored value when NULL.
-- -----------------------------------------------------------------------------
-- =============================================
-- Author:		<Ken>
-- ALTER  date: <2009-10-22>
-- Description:	<用户信息：更新人物物品信息>
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[SP_Users_Items_Update]   
  @ItemID int, 
 @UserID int, 
 @TemplateID int, 
 @Place int, 
 @Count int, 
 @IsJudge bit, 
 @Color nvarchar(100), 
 @IsExist bit, 
 @StrengthenLevel int, 
 @AttackCompose int, 
 @DefendCompose int, 
 @LuckCompose int, 
 @AgilityCompose int, 
 @IsBinds bit, 
 @BeginDate DateTime, 
 @ValidDate int,
 @BagType int,
 @Skin nvarchar(50),
 @IsUsed bit,
 @RemoveDate datetime,
 @RemoveType int,
 @Hole1 int,
 @Hole2 int,
 @Hole3 int,
 @Hole4 int,
 @Hole5 int,
 @Hole6 int,
 @StrengthenTimes int,
 @Hole5Level int,
 @Hole5Exp int,
 @Hole6Level int,
 @Hole6Exp int,
 @IsGold bit,
 @goldBeginTime datetime,
 @goldValidDate int,
 @StrengthenExp int,
 @Blood int,
 @latentEnergyCurStr nvarchar(50),
 @latentEnergyNewStr nvarchar(50),
 @latentEnergyEndTime DateTime,
 @curExp int = NULL,
 @cellLocked bit = NULL
 
 AS    
   begin 
	if (@BagType=-1 and @Place = -1 and @IsExist = 0)
	begin		
     
     DELETE FROM [dbo].[Sys_Users_Goods]
       WHERE ItemID =@ItemID
       
	end
	
    else
    
    begin
     UPDATE Sys_Users_Goods Set UserID=@UserID,BagType=@BagType, TemplateID=@TemplateID, Place=@Place, Count=@Count, IsJudge=@IsJudge, Color=@Color, IsExist=@IsExist, StrengthenLevel=@StrengthenLevel, AttackCompose=@AttackCompose, DefendCompose=@DefendCompose, LuckCompose=@LuckCompose, AgilityCompose=@AgilityCompose, IsBinds=@IsBinds, BeginDate=@BeginDate, ValidDate=@ValidDate,Skin=@Skin,IsUsed=@IsUsed,RemoveDate=@RemoveDate,RemoveType=@RemoveType,Hole1=@Hole1,Hole2=@Hole2,Hole3=@Hole3,Hole4=@Hole4,Hole5=@Hole5,Hole6=@Hole6,StrengthenTimes=@StrengthenTimes,Hole5Level=@Hole5Level,Hole5Exp=@Hole5Exp,Hole6Level=@Hole6Level,Hole6Exp=@Hole6Exp,IsGold=@IsGold,
     goldBeginTime=@goldBeginTime,
     goldValidDate=@goldValidDate,
	 StrengthenExp=@StrengthenExp,
	 Blood=@Blood,
	 latentEnergyCurStr =@latentEnergyCurStr,
     latentEnergyNewStr =@latentEnergyNewStr,
     latentEnergyEndTime = @latentEnergyEndTime,
	 curExp = ISNULL(@curExp, curExp),
	 cellLocked = ISNULL(@cellLocked, cellLocked)
     WHERE ItemID =@ItemID
   end
end
GO

-- -----------------------------------------------------------------------------
-- SP_Users_Items_Add
--   PlayerBussiness.AddGoods (every new item) does not pass @curExp,
--   @cellLocked; PlayerBussiness.AddStore passes only the first 14 params.
--   Missing params default to the Sys_Users_Goods column defaults
--   (datetime ones: NULL in the header, GETDATE() in the INSERT).
-- -----------------------------------------------------------------------------
-- =============================================
-- Author:		<Ken>
-- ALTER  date: <2009-10-22>
-- Description:	<用户信息：用户新增一个物品>
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[SP_Users_Items_Add]   
 @ItemID int output, 
 @UserID int, 
 @TemplateID int, 
 @Place int, 
 @Count int, 
 @IsJudge bit, 
 @Color nvarchar(100), 
 @IsExist bit, 
 @StrengthenLevel int = 0, 
 @AttackCompose int, 
 @DefendCompose int, 
 @LuckCompose int, 
 @AgilityCompose int, 
 @IsBinds bit, 
 @BeginDate DateTime, 
 @ValidDate int = 10,
 @BagType int = 0,
 @Skin nvarchar(50) = N'',
 @IsUsed bit = 0,
 @RemoveType int = 0,
 @Hole1 int = -1,
 @Hole2 int = -1,
 @Hole3 int = -1,
 @Hole4 int = -1,
 @Hole5 int = -1,
 @Hole6 int = -1,
 @StrengthenTimes int = 0,
 @Hole5Level int = 0,
 @Hole5Exp int = 0,
 @Hole6Level int = 0,
 @Hole6Exp int = 0,
 @IsGold bit = 0, 
 @goldValidDate int = 0,
 @StrengthenExp int = 0,
 @goldBeginTime DateTime = NULL,
 @Blood int = 0,
 @latentEnergyCurStr nvarchar(50) = N'0,0,0,0',
 @latentEnergyNewStr nvarchar(50) = N'0,0,0,0',
 @latentEnergyEndTime DateTime = NULL,
 @curExp int = 0,
 @cellLocked bit = 0
AS  
declare  @temp int
select @temp = count(*) from Sys_Users_Goods where ItemID=@ItemID
if @temp=0 
 begin 
	/*if @Place>-1
	begin
		update Sys_Users_Goods set Place=-2 where UserID=@UserID and BagType=@BagType and Place=@Place and IsExist=1
	end*/

     INSERT INTO Sys_Users_Goods( UserID, BagType,TemplateID, Place, Count, IsJudge, Color, IsExist, StrengthenLevel, AttackCompose, DefendCompose, LuckCompose, AgilityCompose, IsBinds, BeginDate, ValidDate,Skin,IsUsed,RemoveType,Hole1,Hole2,Hole3,Hole4,Hole5,Hole6,StrengthenTimes,Hole5Level,Hole5Exp,Hole6Level,Hole6Exp,IsGold,
	 goldBeginTime,
	 goldValidDate,
	 StrengthenExp,
	 Blood,
	 latentEnergyCurStr,
	 latentEnergyNewStr,
	 latentEnergyEndTime,
	 curExp,
	 cellLocked) 
     VALUES( @UserID, @BagType,@TemplateID, @Place, @Count, @IsJudge, @Color, @IsExist, @StrengthenLevel, @AttackCompose, @DefendCompose, @LuckCompose, @AgilityCompose, @IsBinds, @BeginDate, @ValidDate,@Skin,@IsUsed,@RemoveType,@Hole1,@Hole2,@Hole3,@Hole4,@Hole5,@Hole6,@StrengthenTimes, @Hole5Level, @Hole5Exp, @Hole6Level, @Hole6Exp, @IsGold, 
     ISNULL(@goldBeginTime, GETDATE()), 
     @goldValidDate, 
     @StrengthenExp,
	 @Blood,
	 @latentEnergyCurStr,
	 @latentEnergyNewStr,
	 ISNULL(@latentEnergyEndTime, GETDATE()),
	 @curExp,
	 @cellLocked)
     
     select @@identity as 'identity'
     set @ItemID=@@identity    
 end
GO

-- -----------------------------------------------------------------------------
-- SP_UpdateVIPInfo
--   PlayerBussiness.UpdateVIPInfo does not pass @typeVIP and creates
--   @VIPOnlineDays/@VIPOfflineDays with SqlDbType only (Value == null -> not
--   sent). Default NULL; the UPDATE keeps the stored values when NULL.
-- -----------------------------------------------------------------------------
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[SP_UpdateVIPInfo]
--@NickName Nvarchar(200),
@ID int,
@typeVIP int = NULL,
@VIPLevel int,
@VIPExp int,
@VIPOnlineDays int = NULL,
@VIPOfflineDays int = NULL,
@VIPExpireDay datetime,
@VIPLastDate datetime,
@VIPNextLevelDaysNeeded int,
@CanTakeVipReward bit

AS
update [Sys_VIP_Info] set 
	   [typeVIP] = ISNULL(@typeVIP, [typeVIP])
      ,[VIPLevel] = @VIPLevel
      ,[VIPExp] = @VIPExp
      ,[VIPOnlineDays] = ISNULL(@VIPOnlineDays, [VIPOnlineDays])
      ,[VIPOfflineDays] = ISNULL(@VIPOfflineDays, [VIPOfflineDays])
      ,[VIPExpireDay] = @VIPExpireDay
      ,[VIPLastDate] = @VIPLastDate
      ,[VIPNextLevelDaysNeeded] = @VIPNextLevelDaysNeeded
      ,[CanTakeVipReward] = @CanTakeVipReward
      where [UserID] = @ID
GO

-- -----------------------------------------------------------------------------
-- SP_Admin_SendAllItem
--   PlayerBussiness.SendMailAndItem creates @GiftToken with SqlDbType only
--   (Value == null -> not sent). Default 0 = no gift tokens attached.
-- -----------------------------------------------------------------------------
-- =============================================
-- Author:		<Ken，Xiaov>
-- ALTER  date: <2009-10-22>
-- Description:	<后台赠送物品：新版GM后台使用>
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[SP_Admin_SendAllItem]
 @Title nvarchar(1000), 
 @Content nvarchar(2000), 
 @UserID int, 
 @Gold int, 
 @Money int, 
 @GiftToken int = 0,
 @Param nvarchar(2000)
As 

/*第一步：设置User信息*/
Declare @NickName varchar(50)
Set @NickName=''
Select @NickName=NickName from  Sys_Users_Detail where UserID = @UserID
If @NickName = ''
   Begin
     Return 2
   End

/*第二步：设置物品信息*/
Declare @temp int
Declare @maxCount int
Declare @ItemID int
Declare @TemplateID int
Declare @Place int
Declare @Count int
Declare @IsJudge bit
Declare @Color nvarchar(100)
Declare @IsExist bit
Declare @StrengthenLevel int
Declare @AttackCompose int
Declare @DefendCompose int
Declare @LuckCompose int
Declare @AgilityCompose int
Declare @IsBinds bit
Declare @BeginDate DateTime
Declare @ValidDate int
Declare @BagType int
Set @BeginDate=getdate()
Set @Place=-1
Set @IsJudge =1
Set @Color=''
Set @IsExist=1
Set @BagType=-1

/*第三步:设置邮件信息*/
Declare @SenderID int
Declare @Sender nvarchar(100)
Declare @ReceiverID int
Declare @Receiver nvarchar(100)
Declare @SendTime DateTime
Declare @IsRead bit
Declare @IsDelR bit
Declare @IfDelS bit
Declare @IsDelete bit
Declare @Annex1 nvarchar(100)
Declare @Annex2 nvarchar(100)
Declare @Remark nvarchar(200)
Declare @Annex3 nvarchar(100)
Declare @Annex4 nvarchar(100)
Declare @Annex5 nvarchar(100)
Declare @AnnexIndex int
Set @SenderID =0
Set @Sender = dbo.GetTranslation('SP_Active_PullDown.Sender')--'系统管理员' 
Set @ReceiverID = @UserID
Set @Receiver = @NickName
Set @SendTime  = getdate()
Set @IsRead  = 0
Set @IsDelR = 0
Set @IfDelS = 0
Set @IsDelete =0
Set @Annex1 =''
Set @Annex2 =''
Set @Annex3 =''
Set @Annex4 =''
Set @Annex5 =''
Set @AnnexIndex=0
Declare @locationItem int
Declare @startItem int
Declare @values nvarchar(200)
Declare @locationValue int
Declare @startValue int
Declare @value nvarchar(200)
Declare @indexValue int
Set @Param=ltrim(rtrim(@Param))
Set @startItem=1


/*第四步：循环发邮件*/
Set Xact_Abort On 
Begin Tran
If len(@Param)>0
  Begin
    Set @Param=@Param+'|'
    Set @locationItem=charindex('|',@Param)
    while @locationItem<>0
          Begin
            Set @values=substring(@Param,@startItem,@locationItem-@startItem)
            Set @startItem=@locationItem+1
            Set @indexValue=0   

            --templateID,count,validDate,StrengthenLevel,AttackCompose,DefendCompose,AgilityCompose,LuckCompose,isBinds
            Set @values=ltrim(rtrim(@values))
            Set @values = @values+','
            Set @locationValue=charindex(',',@values)

            Set @ItemID =0
            Set @TemplateID =0 
            Set @Count =0
            Set @StrengthenLevel =0
            Set @AttackCompose =0
            Set @DefendCompose =0
            Set @LuckCompose =0
            Set @AgilityCompose =0
            Set @IsBinds =1
            Set @ValidDate =1

            Set @startValue=1
            While @locationValue<>0
                  Begin
                    Set @indexValue = @indexValue+1
                    Set @value=substring(@values,@startValue,@locationValue-@startValue)
                    Set @startValue=@locationValue+1

                    If @indexValue=1
                       Begin
                         Set @TemplateID=@value
                       End
                    Else If @indexValue=2
                       Begin
                         Set @Count=@value
                       End
                    Else If @indexValue=3
                       Begin
                         set @ValidDate=@value
                       End
                    Else If @indexValue=4
                       Begin
                         Set @StrengthenLevel=@value
                       End
                    Else If @indexValue=5
                       Begin
                         Set @AttackCompose=@value
                       End
                    Else If @indexValue=6
                       Begin
                         Set @DefendCompose=@value
                       End
                    Else If @indexValue=7
                       Begin
                         Set @AgilityCompose=@value
                       End
                    Else If @indexValue=8
                       Begin
                         Set @LuckCompose=@value
                       End
                    Else If @indexValue=9
                       Begin
                         Set @IsBinds=@value
                       End	
    	            Set @locationValue=charindex(',',@values,@startValue)	
                  End

            --数量拆分
            Set @temp = 0
            Select @temp=isnull(TemplateID,0),@maxCount=isnull(MaxCount,1) from Shop_Goods where TemplateID = @TemplateID
            If @temp = 0
               Begin
                 Set @TemplateID = 0
               End
            If @TemplateID <>0
               Begin
                 declare @getCount int
                 While @Count > 0
                       Begin   
                         If @Count > @maxCount
                            Begin
                              Set @getCount = @maxCount
                            End
                         Else
                            Begin
                              Set @getCount = @Count
                            End
                         Set @Count = @Count-@getCount
                         Set @AnnexIndex = @AnnexIndex+1
                         Insert Into Sys_Users_Goods( UserID, BagType,TemplateID, Place, Count, IsJudge, Color, IsExist, StrengthenLevel, AttackCompose, DefendCompose, LuckCompose, AgilityCompose, IsBinds, BeginDate, ValidDate) 
                                Values( 0, @BagType,@TemplateID, @Place, @getCount, @IsJudge, @Color, @IsExist, @StrengthenLevel, @AttackCompose, @DefendCompose, @LuckCompose, @AgilityCompose, @IsBinds, @BeginDate, @ValidDate)
                         Select @@identity as 'identity'
                         Set @ItemID=@@identity    
                         If @@error<>0
                            Begin
                              Rollback tran
                              Return @@error
                            End
                         If @AnnexIndex=1
                            Begin
                              Set @Annex1=cast(@ItemID as varchar(20))
                            End
                         If @AnnexIndex=2
                            Begin
                              Set @Annex2=cast(@ItemID as varchar(20))
                            End
                         If @AnnexIndex=3
                            Begin
                              Set @Annex3=cast(@ItemID as varchar(20))
                            End
                         If @AnnexIndex=4
                            Begin
                              Set @Annex4=cast(@ItemID as varchar(20))
                            End
                         If @AnnexIndex=5
                            Begin
                              Set @Annex5=cast(@ItemID as varchar(20))
                              Set @Remark = 'Gold:0,Money:0,Annex1:'+@Annex1+',Annex2:'+@Annex2+',Annex3:'+@Annex3+',Annex4:'+@Annex4+',Annex5:'+@Annex5+',GiftToken:0'
                              Insert Into User_Messages( SenderID, Sender, ReceiverID, Receiver, Title, Content, SendTime, IsRead, IsDelR, IfDelS, IsDelete, Annex1, Annex2, Gold, Money, IsExist,Type,Remark,Annex3,Annex4,Annex5,GiftToken) 
                                     Values( @SenderID, @Sender, @ReceiverID, @NickName, @Title, @Content, @SendTime, @IsRead, @IsDelR, @IfDelS, @IsDelete, @Annex1, @Annex2, 0, 0, @IsExist,51,@Remark,@Annex3,@Annex4,@Annex5,0)
                              If @@error<>0
                                 Begin  
                                   Rollback Tran
                                   Return @@error
                                 End
                              Set @AnnexIndex=0
                              Set @Annex1 =''
                              Set @Annex2 =''
                              Set @Annex3 =''
                              Set @Annex4 =''
                              Set @Annex5 =''
                            End
                       End
               End
               Set @locationItem=charindex('|',@Param,@startItem)
          End
  End
 
/*第五步：发最后一封邮件*/
If  (@AnnexIndex<>0) And (len(@Param) <> 0 )
    Begin
     Set @Remark = 'Gold:0,Money:0,Annex1:'+@Annex1+',Annex2:'+@Annex2+',Annex3:'+@Annex3+',Annex4:'+@Annex4+',Annex5:'+@Annex5+',GiftToken:0'
     Insert Into User_Messages( SenderID, Sender, ReceiverID, Receiver, Title, Content, SendTime, IsRead, IsDelR, IfDelS, IsDelete, Annex1, Annex2, Gold, Money, IsExist,Type,Remark,Annex3,Annex4,Annex5,GiftToken) 
            Values( @SenderID, @Sender, @ReceiverID, @NickName, @Title, @Content, @SendTime, @IsRead, @IsDelR, @IfDelS, @IsDelete, @Annex1, @Annex2, 0,0, @IsExist,8,@Remark,@Annex3,@Annex4,@Annex5,0)
     If @@error<>0
        Begin  
          Rollback tran
          Return @@error
        End
    End

If(@Gold>0 or @Money>0 or @GiftToken>0)
  Begin
    Set @Remark = 'Gold:'+cast(@Gold as varchar(20))+',Money:'+cast(@Money as varchar(20))+',Annex1:,Annex2:,Annex3:,Annex4:,Annex5:,GiftToken:'+cast(@GiftToken as varchar(20))
    Insert Into User_Messages( SenderID, Sender, ReceiverID, Receiver, Title, Content, SendTime, IsRead, IsDelR, IfDelS, IsDelete, Annex1, Annex2, Gold, Money, IsExist,Type,Remark,Annex3,Annex4,Annex5,GiftToken) 
           VALUES( @SenderID, @Sender, @ReceiverID, @NickName, @Title, @Content, @SendTime, @IsRead, @IsDelR, @IfDelS, @IsDelete, '', '', @Gold, @Money, @IsExist,8,@Remark,'','','',@GiftToken) 
    If @@error<>0
       Begin  
         Rollback tran
         Return @@error
       End
  End


Commit Tran
Set xact_abort off
 
/*
If @AnnexIndex<>0 or  @Gold>0 or @Money>0 or @GiftToken>0
   Begin
     If @AnnexIndex=4 and @Gold>0 and @Money>0 and @GiftToken>0
        Begin
          return
          Set @Remark = 'Gold:0,Money:'+cast(@Money as varchar(20))+',Annex1:,Annex2:,Annex3:,Annex4:,Annex5:'
          print @Remark

          INSERT INTO User_Messages( SenderID, Sender, ReceiverID, Receiver, Title, Content, SendTime, IsRead, IsDelR, IfDelS, IsDelete, Annex1, Annex2, Gold, Money, IsExist,Type,Remark,Annex3,Annex4,Annex5) 
                 VALUES( @SenderID, @Sender, @ReceiverID, @NickName, @Title, @Content, @SendTime, @IsRead, @IsDelR, @IfDelS, @IsDelete, '', '', 0, @Money, @IsExist,51,@Remark,'','','') 
          If @@error<>0
             Begin  
               Rollback tran
               Return @@error
             End
          Set @Money=0
          Set @GiftToken=0
        End
     Set @Remark = 'Gold:'+cast(@Gold as varchar(20))+',Money:'+cast(@Money as varchar(20))+',Annex1:'+@Annex1+',Annex2:'+@Annex2+',Annex3:'+@Annex3+',Annex4:'+@Annex4+',Annex5:'+@Annex5+',GiftToken'+@GiftToken
     Insert Into User_Messages( SenderID, Sender, ReceiverID, Receiver, Title, Content, SendTime, IsRead, IsDelR, IfDelS, IsDelete, Annex1, Annex2, Gold, Money, IsExist,Type,Remark,Annex3,Annex4,Annex5,GiftToken) 
            Values( @SenderID, @Sender, @ReceiverID, @NickName, @Title, @Content, @SendTime, @IsRead, @IsDelR, @IfDelS, @IsDelete, @Annex1, @Annex2, @Gold, @Money, @IsExist,51,@Remark,@Annex3,@Annex4,@Annex5,@GiftToken)
     print '3'
     If @@error<>0
        Begin  
          Rollback tran
          Return @@error
        End  
   End
   Else If len(@Param) = 0 
        Begin
          Set @Remark = 'Gold:0,Money:0,Annex1:,Annex2:,Annex3:,Annex4:,Annex5:,GiftToken:0'
          Insert Into User_Messages( SenderID, Sender, ReceiverID, Receiver, Title, Content, SendTime, IsRead, IsDelR, IfDelS, IsDelete, Annex1, Annex2, Gold, Money, IsExist,Type,Remark,Annex3,Annex4,Annex5) 
                 Values( @SenderID, @Sender, @ReceiverID, @NickName, @Title, @Content, @SendTime, @IsRead, @IsDelR, @IfDelS, @IsDelete, @Annex1, @Annex2, 0, 0, @IsExist,51,@Remark,@Annex3,@Annex4,@Annex5)
          If @@error<>0
             Begin  
               Rollback tran
               Return @@error
             End
        End
Commit Tran
Set xact_abort off
Return 0
*/
GO

-- -----------------------------------------------------------------------------
-- SP_User_Consortia_Buff_All
--   PlayerBussiness.GetUserConsortiaBufferLess also passes @LessID, which the
--   proc did not declare ("... is not a parameter for procedure"). Accepted as
--   an ignored optional parameter (the method has no callers and its intended
--   filter is unknown); GetUserConsortiaBuffer (no @LessID) is unaffected.
-- -----------------------------------------------------------------------------
-- =============================================
-- Author:		<Ken>
-- ALTER  date: <2009-10-22>
-- Description:	<用户信息：获取当前用户的Buff>
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[SP_User_Consortia_Buff_All]
 @ConsortiaID int,
 @LessID int = NULL  -- passed by PlayerBussiness.GetUserConsortiaBufferLess; not used
 AS  
   begin 
     select * from Consortia_Buffer  where ConsortiaID = @ConsortiaID and IsOpen = 1
   end
GO

-- -----------------------------------------------------------------------------
-- SP_Users_LoginWeb
--   PlayerBussiness.LoginGame also passes @ActiveIP, which the proc did not
--   declare -> every game login failed with "... is not a parameter for
--   procedure". Accepted as an ignored optional parameter: the column
--   Sys_Users_Detail.ActiveIP holds the activation IP (set by SP_Users_Active)
--   and LoginGame never reads it back, so it is not overwritten here.
-- -----------------------------------------------------------------------------
-- =============================================
-- Author:		<Ken>
-- ALTER  date: <2009-10-22>
-- Description:	<用户信息：从Web页面登陆过来的验证>
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[SP_Users_LoginWeb]
@UserName Nvarchar(200),
@PassWord Nvarchar(200),
@FirstValidate bit,
@NickName Nvarchar(200),
@ActiveIP Nvarchar(100) = NULL  -- passed by PlayerBussiness.LoginGame; not used

as
declare @forbidDate datetime
declare @isExist bit 
declare @lastDate datetime 
declare @lastDateSecond datetime
declare @lastDateThird datetime
declare @loginCount int
declare @isFirst int 
declare @DayLoginCount int
select @forbidDate=ForbidDate,@isExist=IsExist,@lastDate=LastDate,@loginCount=LoginCount,@lastDateSecond=LastDateSecond,@lastDateThird=LastDateThird,@isFirst=IsFirst,@DayLoginCount=DayLoginCount from Sys_Users_Detail where UserName =@UserName and NickName=@NickName

  if MONTH(@lastDate) = MONTH(getdate()) 
  begin
     if DAY(@lastDate)<>DAY(getdate())
        begin
    	set @loginCount = @loginCount+1
           set @DayLoginCount=0
       end
     else
       begin
	set @lastDate=@lastDateSecond
	set @lastDateSecond=@lastDateThird
       end
  end
  else
  begin
    set @loginCount = 1
    set @DayLoginCount=0
  end

if @isFirst=1
begin
   set @DayLoginCount=1
end

if @isFirst>0
begin
   set @isFirst=@isFirst+1
end

if @isExist = 0  

begin
 if datediff(ss,getdate(),@forbidDate)<0 
   begin
     update Sys_Users_Detail set [PassWord] =@PassWord,LastDate = getdate(),IsExist=1,LastDateSecond = @lastDate,LastDateThird = @lastDateSecond,LoginCount=@loginCount,IsFirst=@isFirst,DayLoginCount=@DayLoginCount where UserName =@UserName and NickName=@NickName
    end
end
else
begin
  update Sys_Users_Detail set [PassWord] =@PassWord,LastDate = getdate(),LastDateSecond = @lastDate,LastDateThird = @lastDateSecond,LoginCount=@loginCount,IsFirst=@isFirst,DayLoginCount=@DayLoginCount where UserName =@UserName and NickName=@NickName
end

if @@Error <> 0
begin
  return null
end

select * from V_Sys_Users_Detail where UserName =@UserName and NickName=@NickName
GO

