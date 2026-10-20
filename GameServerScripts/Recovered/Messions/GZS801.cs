// Recovered by decompiling the original Game.Server.dll (Road.Service/bin/Release/net48, commit b1a26bc);
// no source for this script survived. It was compiled against this engine version.
using Game.Logic;
using Game.Logic.AI;
using Game.Logic.Phy.Object;

namespace GameServerScript.AI.Messions;

public class GZS801 : AMissionControl
{
	private int npcId1 = 8101;

	private int npcId2 = 8102;

	private int npcId3 = 8104;

	private int ballId = 37;

	private Player apprenticePlayer;

	private Player masterPlayer;

	private SimpleBoss simpleBoss_0;

	private int int_4;

	public override int CalculateScoreGrade(int score)
	{
		base.CalculateScoreGrade(score);
		if (score > 930)
		{
			return 3;
		}
		if (score > 850)
		{
			return 2;
		}
		if (score > 775)
		{
			return 1;
		}
		return 0;
	}

	public override void OnPrepareNewSession()
	{
		base.OnPrepareNewSession();
		int[] npcIds = new int[3] { npcId1, npcId2, npcId3 };
		base.Game.LoadResources(npcIds);
		base.Game.LoadNpcGameOverResources(npcIds);
		base.Game.AddLoadingFile(1, $"bombs/{ballId}.swf", $"tank.resource.bombs.Bomb{ballId}");
		base.Game.AddLoadingFile(2, "image/game/effect/5/cuipao.swf", "asset.game.4.cuipao");
		base.Game.AddLoadingFile(2, "image/game/effect/5/mubiao.swf", "asset.game.4.mubiao");
		base.Game.SetMap(1186);
	}

	public override void OnNewTurnStarted()
	{
		base.OnNewTurnStarted();
		if (apprenticePlayer != null)
		{
			apprenticePlayer.SetBall(ballId);
		}
	}

	public override void OnPrepareNewGame()
	{
		base.OnPrepareNewGame();
		loadPlayers();
		apprenticePlayer.BoltMove(1497, 838, 0);
		masterPlayer.BoltMove(388, 851, 0);
	}

	public override void OnStartGame()
	{
		base.OnStartGame();
		LivingConfig livingConfig = base.Game.BaseLivingConfig();
		livingConfig.MinBlood = 1;
		simpleBoss_0 = base.Game.CreateBoss(npcId1, 60, 826, -1, 1, "born", livingConfig);
		simpleBoss_0.ChangeDirection(1, 4000);
	}

	public override void OnBeginNewTurn()
	{
		base.OnBeginNewTurn();
	}

	public override bool CanGameOver()
	{
		if (base.Game.GetAllLivingPlayers().Count < 2)
		{
			return true;
		}
		SimpleBoss simpleBoss = base.Game.FindSingleSimpleBossID(npcId2);
		if (simpleBoss != null && !simpleBoss.IsLiving)
		{
			int_4 = 1;
			return true;
		}
		return false;
	}

	public override int UpdateUIData()
	{
		base.UpdateUIData();
		return int_4;
	}

	public override void OnGameOver()
	{
		base.OnGameOver();
		if (int_4 >= base.Game.MissionInfo.TotalCount && base.Game.GetLivedLivings().Count == 0)
		{
			base.Game.IsWin = true;
		}
		else
		{
			base.Game.IsWin = false;
		}
	}

	private void loadPlayers()
	{
		foreach (Player allLivingPlayer in base.Game.GetAllLivingPlayers())
		{
			if (allLivingPlayer.PlayerDetail.PlayerCharacter.masterID != 0 && allLivingPlayer.PlayerDetail.PlayerCharacter.Grade < 20)
			{
				apprenticePlayer = allLivingPlayer;
			}
			else
			{
				masterPlayer = allLivingPlayer;
			}
		}
	}
}
